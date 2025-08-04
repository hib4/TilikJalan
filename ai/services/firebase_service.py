import firebase_admin
from firebase_admin import credentials, firestore, storage
from typing import List, Dict, Optional, Tuple
from PIL import Image
import io
import uuid
from datetime import datetime, timedelta
from dotenv import load_dotenv
import os

# --- The Refactored Service Class ---


class FirebaseService:
    """A service class to handle all Firebase interactions."""

    def __init__(self):
        """
        Initializes the Firebase app and service clients (Firestore, Storage).
        """
        if not firebase_admin._apps:
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
        self, image: Image.Image, prefix: str
    ) -> Optional[str]:
        """
        Uploads a single image and returns a long-lived signed URL.
        """
        try:
            img_byte_arr = io.BytesIO()
            image.save(img_byte_arr, format="JPEG")
            img_byte_arr = img_byte_arr.getvalue()

            filename = f"{prefix}/{uuid.uuid4()}.jpg"
            blob = self.bucket.blob(filename)
            blob.upload_from_string(img_byte_arr, content_type="image/jpeg")

            # --- SECURITY: Use signed URLs instead of making blobs public ---
            # Generate a URL that expires in 10 years for long-term access.
            expiration = timedelta(days=365 * 10)
            return blob.generate_signed_url(expiration=expiration)
        except Exception as e:
            print(f"Error uploading image to '{prefix}': {e}")
            return None

    def _prepare_defect_document(
        self, original_url: str, annotated_url: str, meta: Dict
    ) -> Dict:
        """
        Prepares a dictionary with all required fields for a Firestore document.
        """
        # Make a copy to avoid modifying the original metadata dict
        document_data = meta.copy()

        document_data["images"] = {
            "original_url": original_url,
            "annotated_url": annotated_url,
        }
        document_data["upload_timestamp"] = datetime.now()
        document_data["id"] = str(uuid.uuid4())
        return document_data

    def upload_batch_defects(
        self,
        original_images: List[Image.Image],
        annotated_images: List[Image.Image],
        metadata_list: List[Dict],
    ) -> List[Dict]:
        """
        Processes a batch of defects, uploads images, and saves records to Firestore.
        Uses a Firestore batch for atomic writes.
        """
        batch = self.db.batch()
        defects_collection = self.db.collection("road_defects")
        uploaded_records = []

        for original, annotated, meta in zip(
            original_images, annotated_images, metadata_list
        ):
            original_url = self._upload_image_and_get_url(original, "original")
            annotated_url = self._upload_image_and_get_url(annotated, "annotated")

            if original_url and annotated_url:
                doc_data = self._prepare_defect_document(
                    original_url, annotated_url, meta
                )
                doc_ref = defects_collection.document(doc_data["id"])
                batch.set(doc_ref, doc_data)
                uploaded_records.append(doc_data)
                print(f"Prepared defect for batch: {doc_data['id']}")

        try:
            batch.commit()
            print(f"Successfully committed batch of {len(uploaded_records)} records.")
            return uploaded_records
        except Exception as e:
            print(f"Error committing batch to Firestore: {e}")
            return []

    def upload_single_report(
        self, original_image: Image.Image, annotated_image: Image.Image, metadata: Dict
    ) -> Optional[Dict]:
        """
        Processes a single user report, uploads images, and saves the record to Firestore.
        """
        reports_collection = self.db.collection("defect_reports")

        original_url = self._upload_image_and_get_url(original_image, "original_report")
        annotated_url = self._upload_image_and_get_url(
            annotated_image, "annotated_report"
        )

        if original_url and annotated_url:
            doc_data = self._prepare_defect_document(
                original_url, annotated_url, metadata
            )
            try:
                reports_collection.document(doc_data["id"]).set(doc_data)
                print(f"Successfully uploaded report: {doc_data['id']}")
                return doc_data
            except Exception as e:
                print(f"Error uploading single report to Firestore: {e}")

        return None

    def fetch_all_defects(self) -> List[Dict]:
        """
        Retrieves all road defects from Firestore.
        """
        try:
            defects_ref = self.db.collection("road_defects").stream()
            defects = []
            for doc in defects_ref:
                data = doc.to_dict()
                if "upload_timestamp" in data and isinstance(
                    data["upload_timestamp"], datetime
                ):
                    data["upload_timestamp"] = data["upload_timestamp"].strftime(
                        "%Y-%m-%d %H:%M:%S"
                    )
                defects.append(data)
            return defects
        except Exception as e:
            print(f"Error retrieving defects: {str(e)}")
            return []


# # --- Example Usage ---
# if __name__ == "__main__":
#     load_dotenv()

#     # 1. Create a service instance (this handles initialization)
#     firebase_service = FirebaseService()

#     # 2. Create some dummy data for a single report
#     dummy_image = Image.new("RGB", (100, 100), color="red")
#     dummy_metadata = {"lat": -6.9826, "lon": 110.4092, "street_name": "Jl. Pahlawan"}

#     # 3. Use the service to upload a single report
#     print("\n--- Testing Single Report Upload ---")
#     result = firebase_service.upload_single_report(
#         original_image=dummy_image, annotated_image=dummy_image, metadata=dummy_metadata
#     )
#     if result:
#         print("Upload successful!")
#         print(result)

#     # 4. Use the service to fetch all defects
#     print("\n--- Testing Fetching All Defects ---")
#     all_defects = firebase_service.fetch_all_defects()
#     print(f"Found {len(all_defects)} defects in the database.")
