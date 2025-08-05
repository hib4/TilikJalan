import firebase_admin
from firebase_admin import credentials, firestore, storage
from typing import List, Dict, Optional
from PIL import Image
import io
import uuid
from datetime import datetime, timedelta
from dotenv import load_dotenv
import os
import base64

class FirebaseService:
    """A service class to handle all Firebase interactions."""

    def __init__(self):
        """
        Initializes the Firebase app and service clients (Firestore, Storage).
        """
        if not firebase_admin._apps:
            load_dotenv() # Load env variables here for clean initialization
            cred_path = os.getenv("FIREBASE_CREDENTIAL_KEY")
            bucket_path = os.getenv("FIREBASE_BUCKET_PATH")
            if not cred_path or not bucket_path:
                raise ValueError(
                    "Firebase credentials or bucket path not set in .env file"
                )

            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred, {"storageBucket": bucket_path})
            print("Firebase Initialized.")

        self.db = firestore.client()
        self.bucket = storage.bucket()

    def _upload_image_and_get_url(
        self, image: str, prefix: str
    ) -> Optional[str]:
        """
        (Private) Uploads a single image and returns a long-lived signed URL.
        """
        try:
            img_bytes = base64.b64decode(image)

            filename = f"{prefix}/{uuid.uuid4()}.jpg"
            blob = self.bucket.blob(filename)
            blob.upload_from_string(img_bytes, content_type="image/jpeg")

            expiration = timedelta(days=365 * 10)
            return blob.generate_signed_url(expiration=expiration)
        except Exception as e:
            print(f"Error uploading image to '{prefix}': {e}")
            return None

    def _prepare_document(
        self, original_urls: List[str], annotated_urls: List[str], meta: Dict
    ) -> Dict:
        """
        (Private) Prepares a dictionary for a Firestore document.
        """
        document_data = meta.copy()
        document_data["images"] = {
            "original_urls": original_urls,
            "annotated_urls": annotated_urls,
        }
        document_data["upload_timestamp"] = datetime.now()
        document_data["id"] = str(uuid.uuid4())
        return document_data

    def upload_sensor_report(
        self,
        original_images: List[str],
        annotated_images: List[str],
        metadata: Dict,
    ) -> Optional[str]:
        """
        Processes a sensor-triggered defect, uploading all associated images
        and creating a single Firestore document.
        """
        original_urls = []
        annotated_urls = []
        for original, annotated in zip(original_images, annotated_images):
            org_url = self._upload_image_and_get_url(original, "original_sensor")
            ann_url = self._upload_image_and_get_url(annotated, "annotated_sensor")
            if org_url and ann_url:
                original_urls.append(org_url)
                annotated_urls.append(ann_url)

        # Only proceed if we have successfully uploaded images
        if not original_urls:
            print("Failed to upload any images for the sensor report.")
            return None

        doc_data = self._prepare_document(original_urls, annotated_urls, metadata)
        
        try:
            doc_ref = self.db.collection("road_defects").document(doc_data["id"])
            doc_ref.set(doc_data)
            print(f"Successfully uploaded sensor report: {doc_data['id']}")
            return doc_data['id']
        except Exception as e:
            print(f"Error committing sensor report to Firestore: {e}")
            return None


    def upload_manual_report(
        self, original_image: Image.Image, annotated_image: Image.Image, metadata: Dict
    ) -> Optional[Dict]:
        """
        Processes a single user-submitted manual report.
        """
        reports_collection = self.db.collection("manual_reports")

        original_url = self._upload_image_and_get_url(original_image, "original_manual")
        annotated_url = self._upload_image_and_get_url(
            annotated_image, "annotated_manual"
        )

        if original_url and annotated_url:
            # **FIX:** Wrap the single URLs in lists to match the expected structure.
            doc_data = self._prepare_document(
                [original_url], [annotated_url], metadata
            )
            try:
                reports_collection.document(doc_data["id"]).set(doc_data)
                print(f"Successfully uploaded manual report: {doc_data['id']}")
                return doc_data
            except Exception as e:
                print(f"Error uploading manual report to Firestore: {e}")

        return None

    def fetch_all_defects(self, collection_name: str = "road_defects") -> List[Dict]:
        """
        Retrieves all documents from a specified collection.
        """
        try:
            docs_ref = self.db.collection(collection_name).stream()
            results = []
            for doc in docs_ref:
                data = doc.to_dict()
                if "upload_timestamp" in data and isinstance(
                    data["upload_timestamp"], datetime
                ):
                    data["upload_timestamp"] = data["upload_timestamp"].strftime(
                        "%Y-%m-%d %H:%M:%S"
                    )
                results.append(data)
            return results
        except Exception as e:
            print(f"Error retrieving from '{collection_name}': {str(e)}")
            return []


# # # --- Example Usage ---
# if __name__ == "__main__":
#     # 1. Create a service instance (this handles initialization)
#     firebase_service = FirebaseService()

#     # 2. Create dummy data for a manual report
#     print("\n--- Testing Manual Report Upload ---")
#     dummy_image = Image.new("RGB", (100, 100), color="blue")
#     manual_meta = {"lat": -6.9826, "lon": 110.4092, "street_name": "Jl. Pahlawan", "user_id": "user123"}
    
#     result = firebase_service.upload_manual_report(
#         original_image=dummy_image, annotated_image=dummy_image, metadata=manual_meta
#     )
#     if result:
#         print("Manual upload successful!")

#     # 3. Create dummy data for a sensor report (with multiple images)
#     print("\n--- Testing Sensor Report Upload ---")
#     sensor_images = [Image.new("RGB", (100, 100), color=c) for c in ["red", "green", "yellow"]]
#     sensor_meta = {"lat": -6.9922, "lon": 110.4237, "street_name": "Simpang Lima"}

#     result = firebase_service.upload_sensor_report(
#         original_images=sensor_images,
#         annotated_images=sensor_images,
#         metadata=sensor_meta
#     )
#     if result:
#         print("Sensor upload successful!")


#     # 4. Fetch all defects
#     print("\n--- Testing Fetching All Defects ---")
#     all_defects = firebase_service.fetch_all_defects(collection_name="road_defects")
#     print(f"Found {len(all_defects)} sensor defects in the database.")
