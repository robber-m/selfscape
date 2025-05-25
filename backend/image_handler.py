import uuid
from fastapi import UploadFile, HTTPException
from backend.firestore_client import get_firebase_storage_bucket # Corrected import path
import os

# Define allowed content types and max size for image uploads
ALLOWED_IMAGE_TYPES = ["image/jpeg", "image/png", "image/gif"]
MAX_IMAGE_SIZE_MB = 5
MAX_IMAGE_SIZE_BYTES = MAX_IMAGE_SIZE_MB * 1024 * 1024

def upload_image(file: UploadFile, acquisition_id: str) -> str:
    """
    Uploads an image to Firebase Storage.
    """
    if not file.content_type in ALLOWED_IMAGE_TYPES:
        raise HTTPException(status_code=400, detail=f"Invalid image type. Allowed types: {', '.join(ALLOWED_IMAGE_TYPES)}")

    # Check file size by reading the file content into memory.
    # For very large files, a streaming check would be better, but UploadFile reads it into memory/spool anyway.
    contents = file.file.read()
    if len(contents) > MAX_IMAGE_SIZE_BYTES:
        raise HTTPException(status_code=400, detail=f"Image size exceeds the maximum limit of {MAX_IMAGE_SIZE_MB}MB.")
    
    # Reset file pointer after reading
    file.file.seek(0)

    bucket = get_firebase_storage_bucket()
    if not bucket:
        raise HTTPException(status_code=500, detail="Firebase Storage bucket not available. Check server configuration.")

    original_filename = file.filename if file.filename else "unknown"
    file_extension = os.path.splitext(original_filename)[1]
    unique_filename = f"acquisitions/{acquisition_id}/{uuid.uuid4()}{file_extension}"

    try:
        blob = bucket.blob(unique_filename)
        blob.upload_from_file(file.file, content_type=file.content_type)
        blob.make_public()
        return blob.public_url
    except Exception as e:
        # Log the exception e
        print(f"Error during image upload: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to upload image: {e}")


def delete_image(image_url: str) -> bool:
    """
    Deletes an image from Firebase Storage based on its public URL.
    """
    if not image_url:
        return False

    bucket = get_firebase_storage_bucket()
    if not bucket:
        # Log this error: "Firebase Storage bucket not available for deletion."
        print("Error: Firebase Storage bucket not available for image deletion.")
        return False

    try:
        # Extract blob name from URL. Example URL: https://storage.googleapis.com/bucket_name/object_path
        # We need to ensure this parsing is robust.
        if image_url.startswith(f"https://storage.googleapis.com/{bucket.name}/"):
            blob_name = image_url.split(f"https://storage.googleapis.com/{bucket.name}/", 1)[1]
        else:
            # Log this: "Invalid image URL format or does not match bucket."
            print(f"Error: Invalid image URL format or URL does not match configured bucket {bucket.name}.")
            return False
        
        blob = bucket.blob(blob_name)
        if not blob.exists():
            # Log this: f"Blob {blob_name} does not exist."
            print(f"Info: Blob {blob_name} does not exist, cannot delete.")
            return False # Or True if "already deleted" is considered success

        blob.delete()
        return True
    except Exception as e:
        # Log the exception e
        print(f"Error during image deletion (URL: {image_url}, Blob: {blob_name if 'blob_name' in locals() else 'unknown'}): {e}")
        return False
