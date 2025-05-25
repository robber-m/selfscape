from fastapi import FastAPI, HTTPException, UploadFile, File, Form, Depends, status
from datetime import datetime
from typing import List, Optional
import uuid

from .models import AcquisitionModel, AcquisitionCreate
from .firestore_client import get_firestore_client, get_firebase_storage_bucket # Ensure bucket getter is also available if needed directly
from .image_handler import upload_image, delete_image

# Initialize FastAPI app
app = FastAPI(title="Inventory & Curation Module API")

# Dependency for Firestore client
def get_db():
    db = get_firestore_client()
    if db is None:
        raise HTTPException(status_code=503, detail="Firestore client is not available.")
    return db

# --- API Endpoints ---

@app.post("/acquisitions/", response_model=AcquisitionModel, status_code=status.HTTP_201_CREATED)
async def create_acquisition(
    name: str = Form(...),
    description: str = Form(...),
    dateAcquired: datetime = Form(...),
    source: str = Form(...),
    tags: str = Form(""),  # Comma-separated string, default to empty
    image: UploadFile = File(...),
    db = Depends(get_db)
):
    acquisition_id = str(uuid.uuid4())
    
    try:
        image_url = upload_image(file=image, acquisition_id=acquisition_id)
    except HTTPException as e:
        # Forward HTTPException from upload_image or wrap it
        raise HTTPException(status_code=e.status_code, detail=f"Image upload failed: {e.detail}")
    except Exception as e: # Catch any other unexpected error from upload_image
        # Log e
        raise HTTPException(status_code=500, detail=f"An unexpected error occurred during image upload: {str(e)}")

    parsed_tags = [tag.strip() for tag in tags.split(',') if tag.strip()] if tags else []

    acquisition_data = AcquisitionModel(
        id=acquisition_id,
        name=name,
        description=description,
        imageUrl=image_url,
        dateAcquired=dateAcquired,
        source=source,
        tags=parsed_tags
    )

    try:
        db.collection('acquisitions').document(acquisition_id).set(acquisition_data.dict())
    except Exception as e:
        # Attempt to delete uploaded image if Firestore operation fails
        try:
            delete_image(image_url)
        except Exception as del_e:
            # Log del_e: Failed to clean up image after Firestore error
            pass
        # Log e
        raise HTTPException(status_code=500, detail=f"Failed to save acquisition to database: {str(e)}")
    
    return acquisition_data


@app.get("/acquisitions/", response_model=List[AcquisitionModel])
async def get_all_acquisitions(db = Depends(get_db)):
    acquisitions_list = []
    try:
        acquisitions_ref = db.collection('acquisitions').stream()
        for doc in acquisitions_ref:
            acquisitions_list.append(AcquisitionModel(**doc.to_dict()))
    except Exception as e:
        # Log e
        raise HTTPException(status_code=500, detail=f"Failed to retrieve acquisitions: {str(e)}")
    return acquisitions_list


@app.get("/acquisitions/{acquisition_id}", response_model=AcquisitionModel)
async def get_acquisition(acquisition_id: str, db = Depends(get_db)):
    try:
        doc_ref = db.collection('acquisitions').document(acquisition_id)
        doc = doc_ref.get()
        if doc.exists:
            return AcquisitionModel(**doc.to_dict())
        else:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Acquisition not found")
    except Exception as e:
        # Log e
        raise HTTPException(status_code=500, detail=f"Error fetching acquisition: {str(e)}")


@app.put("/acquisitions/{acquisition_id}", response_model=AcquisitionModel)
async def update_acquisition(
    acquisition_id: str,
    name: Optional[str] = Form(None),
    description: Optional[str] = Form(None),
    dateAcquired: Optional[datetime] = Form(None),
    source: Optional[str] = Form(None),
    tags: Optional[str] = Form(None), # Comma-separated string
    image: Optional[UploadFile] = File(None),
    db = Depends(get_db)
):
    try:
        doc_ref = db.collection('acquisitions').document(acquisition_id)
        doc = doc_ref.get()
        if not doc.exists:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Acquisition not found")

        existing_data = AcquisitionModel(**doc.to_dict())
        update_data = {}
        old_image_url = existing_data.imageUrl

        if name is not None: update_data["name"] = name
        if description is not None: update_data["description"] = description
        if dateAcquired is not None: update_data["dateAcquired"] = dateAcquired
        if source is not None: update_data["source"] = source
        if tags is not None:
            update_data["tags"] = [tag.strip() for tag in tags.split(',') if tag.strip()] if tags else []

        new_image_url = None
        if image:
            try:
                new_image_url = upload_image(file=image, acquisition_id=acquisition_id)
                update_data["imageUrl"] = new_image_url
            except HTTPException as e:
                raise HTTPException(status_code=e.status_code, detail=f"Image upload failed: {e.detail}")
            except Exception as e:
                # Log e
                raise HTTPException(status_code=500, detail=f"An unexpected error occurred during image upload: {str(e)}")

        if not update_data and not new_image_url: # Nothing to update
             raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No update data provided.")

        if update_data: # Only update if there's something to change apart from image
            doc_ref.update(update_data)
        
        # If new image was uploaded and old one exists, delete old image
        if new_image_url and old_image_url and new_image_url != old_image_url:
            try:
                delete_image(old_image_url)
            except Exception as e:
                # Log e: "Failed to delete old image, but acquisition was updated."
                print(f"Warning: Failed to delete old image {old_image_url}: {e}")
        
        # Fetch the updated document to return
        updated_doc = doc_ref.get()
        return AcquisitionModel(**updated_doc.to_dict())

    except HTTPException: # Re-raise known HTTP exceptions
        raise
    except Exception as e:
        # Log e
        raise HTTPException(status_code=500, detail=f"Error updating acquisition: {str(e)}")


@app.delete("/acquisitions/{acquisition_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_acquisition_endpoint(acquisition_id: str, db = Depends(get_db)):
    try:
        doc_ref = db.collection('acquisitions').document(acquisition_id)
        doc = doc_ref.get()
        if not doc.exists:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Acquisition not found")

        acquisition_data = AcquisitionModel(**doc.to_dict())
        image_url_to_delete = acquisition_data.imageUrl

        # Delete Firestore document first
        doc_ref.delete()

        # Then attempt to delete the image
        if image_url_to_delete:
            try:
                success = delete_image(image_url_to_delete)
                if not success:
                    # Log this: "Image deletion might have failed for URL: {image_url_to_delete}"
                    print(f"Warning: Image deletion for {image_url_to_delete} returned false or failed.")
            except Exception as e:
                # Log e: "Error during image deletion after Firestore record removal."
                print(f"Error: Failed to delete image {image_url_to_delete} during acquisition deletion: {e}")
        
        return None # FastAPI will return 204 No Content

    except HTTPException: # Re-raise known HTTP exceptions
        raise
    except Exception as e:
        # Log e
        raise HTTPException(status_code=500, detail=f"Error deleting acquisition: {str(e)}")

# Placeholder for the root endpoint from the original main.py, if needed
@app.get("/")
async def root():
    return {"message": "Inventory & Curation Module Backend - API Active"}

# The following lines are for Uvicorn to run this app directly if this file is executed.
# However, the README suggests `uvicorn main:app --reload --app-dir backend`
# This is usually not included in the main.py when using uvicorn CLI.
# if __name__ == "__main__":
#     import uvicorn
#     # Note: running with `python main.py` will make . (current dir) the app_dir.
#     # This might cause import issues if not run from project root.
#     # `uvicorn backend.main:app --reload` is preferred.
#     uvicorn.run(app, host="0.0.0.0", port=8000)
