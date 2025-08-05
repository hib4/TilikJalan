from io import BytesIO
import os
import requests
from dotenv import load_dotenv
from PIL import Image
from typing import List, Dict, Optional, Tuple

# --- Constants ---
# NEW: Added metadata URL
STREET_VIEW_METADATA_URL = "https://maps.googleapis.com/maps/api/streetview/metadata"
STREET_VIEW_IMAGE_URL = "https://maps.googleapis.com/maps/api/streetview"

# --- API Key Setup ---
load_dotenv()
API_KEY = os.getenv("MAPS_API_KEY")


def _get_street_name(lat: float, lng: float) -> str:
    """
    Gets the street name for a given coordinate.
    """
    if not API_KEY:
        print("Error: MAPS_API_KEY not found.")
        return "Unknown Street"

    params = {"latlng": f"{lat},{lng}", "key": API_KEY}
    try:
        response = requests.get("https://maps.googleapis.com/maps/api/geocode/json", params=params)
        response.raise_for_status()
        data = response.json()
        if data["status"] == "OK":
            for component in data["results"][0]["address_components"]:
                if "route" in component["types"]:
                    return component["long_name"]
    except requests.exceptions.RequestException as e:
        print(f"An error occurred during geocoding request: {e}")
    return "Unknown Street"


def _fetch_image_and_date(
    lat: float, lng: float, heading: int
) -> Optional[Tuple[Image.Image, str]]:
    """
    Fetches both the Street View image and its capture date.

    Returns:
        A tuple of (PIL Image, date string) or None if not found.
    """
    metadata_params = {"location": f"{lat},{lng}", "key": API_KEY}
    
    # --- STEP 1: Get metadata first to check for image existence and date. ---
    try:
        response_meta = requests.get(STREET_VIEW_METADATA_URL, params=metadata_params)
        response_meta.raise_for_status()
        metadata = response_meta.json()

        if metadata["status"] != "OK":
            # This is the correct way to check if an image exists.
            print(f"No Street View metadata found for heading {heading}")
            return None
        
        # Extract the date (e.g., "2023-11")
        image_date = metadata.get("date", "Unknown Date")

    except requests.exceptions.RequestException as e:
        print(f"An error occurred during metadata request: {e}")
        return None

    # --- STEP 2: If metadata is valid, download the actual image. ---
    image_params = {
        "size": "640x640",
        "location": f"{lat},{lng}",
        "heading": heading,
        "fov": 90,
        "pitch": -30,
        "source": "outdoor",
        "key": API_KEY,
    }
    try:
        response_img = requests.get(STREET_VIEW_IMAGE_URL, params=image_params)
        response_img.raise_for_status()
        image = Image.open(BytesIO(response_img.content))
        return image, image_date

    except requests.exceptions.RequestException as e:
        print(f"An error occurred during image request: {e}")
        return None


def capture_road_images(lat: float, lng: float) -> List[Dict]:
    """
    Captures street view images and metadata (including date) in 4 directions.
    """
    street_name = _get_street_name(lat, lng)
    results = []

    for heading in [0, 90, 180, 270]:
        # Fetch both image and date together
        fetched_data = _fetch_image_and_date(lat, lng, heading)

        if fetched_data:
            image, image_date = fetched_data
            results.append({
                "lat": lat,
                "lon": lng,
                "heading": heading,
                "street_name": street_name,
                "img": image,
                "image_date": image_date, # Add the date to your results
            })

    return results

# # --- Example Usage ---
# if __name__ == "__main__":
#     # Simpang Lima, Semarang
#     test_lat = -6.992236
#     test_lng = 110.423719
    
#     image_data = capture_road_images(test_lat, test_lng)
    
#     if image_data:
#         print(f"\nSuccessfully captured {len(image_data)} images for '{image_data[0]['street_name']}'.")
#         # Print details of the first successful capture
#         first_image_details = image_data[0]
#         print(f"  - Heading: {first_image_details['heading']}")
#         print(f"  - Image Date: {first_image_details['image_date']}")
        
#         # Save the first image as an example
#         first_image_details['img'].save("street_view_with_date.jpg")
#         print("Saved 'street_view_with_date.jpg'")
#     else:
#         print("Could not capture any images for the given coordinates.")