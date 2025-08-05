from io import BytesIO
import os
import requests
from dotenv import load_dotenv
from PIL import Image

# --- Constants ---
STREET_VIEW_URL = "https://maps.googleapis.com/maps/api/streetview"
GEOCODING_URL = "https://maps.googleapis.com/maps/api/geocode/json"
STREET_VIEW_METADATA_URL = "https://maps.googleapis.com/maps/api/streetview/metadata"

# --- API Key Setup ---
load_dotenv()
API_KEY = os.getenv("MAPS_API_KEY")


def _get_street_name(lat, lng):
    """
    Gets the street name for a given coordinate.
    Returns "Unknown Street" if not found or if an error occurs.
    """
    if not API_KEY:
        print("Error: MAPS_API_KEY not found.")
        return "Unknown Street"

    params = {"latlng": f"{lat},{lng}", "key": API_KEY}

    try:
        response = requests.get(GEOCODING_URL, params=params)
        response.raise_for_status()  # Raises an exception for bad status codes (4xx or 5xx)
        data = response.json()

        if data["status"] == "OK":
            # Typically, the first result is the most relevant for a specific coordinate
            for component in data["results"][0]["address_components"]:
                if "route" in component["types"]:
                    return component["long_name"]
        else:
            # Log the specific reason for failure from the API
            print(f"Geocoding API failed with status: {data['status']}")

    except requests.exceptions.RequestException as e:
        print(f"An error occurred during geocoding request: {e}")

    return "Unknown Street"


def _get_street_view_image(lat, lng, heading):
    """
    Gets a single Street View image. Returns a PIL image or None on failure.
    """
    params = {
        "size": "640x640",
        "location": f"{lat},{lng}",
        "heading": heading,
        "fov": 90,
        "pitch": -30,  # A pitch of -30 is good for looking at the road
        "source": "outdoor",  # Ensures you get outdoor imagery
        "key": API_KEY,
    }

    try:
        response = requests.get(STREET_VIEW_URL, params=params)
        response.raise_for_status()

        # Google's "no image" placeholder has a specific content length
        if len(response.content) < 1000:
            print(f"No Street View image found for heading {heading}")
            return None

        return Image.open(BytesIO(response.content))

    except requests.exceptions.RequestException as e:
        print(f"An error occurred during street view request: {e}")
        return None

def _get_taken_date(lat, lng):
    try:
        response_meta = requests.get(STREET_VIEW_METADATA_URL, params={
            "location": f"{lat},{lng}", "key": API_KEY
        })
        response_meta.raise_for_status()
        metadata = response_meta.json()
        
        # Extract the date (e.g., "2023-11")
        image_date = metadata.get("date", "Unknown Date")
        return image_date
    except requests.exceptions.RequestException as e:
        print(f"An error occurred during metadata request: {e}")
        return None

def capture_road_images(lat, lng):
    """
    Captures street view images of the road in 4 directions for a specified coordinate.
    """
    # 1. Get the street name only ONCE.
    street_name = _get_street_name(lat, lng)
    
    # 2. Get the taken date
    taken_date = _get_taken_date(lat, lng)

    # 3. Get images in 4 directions (North, East, South, West)
    images = []
    for heading in [0, 90, 180, 270]:
        image = _get_street_view_image(lat, lng, heading)

        # 3. Only append if the image was successfully retrieved
        if image:
            images.append(image)
    
    result = {
        "street_name": street_name,
        "taken_date": taken_date,
        "images": images
    }

    return result