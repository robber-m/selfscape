import firebase_admin
from firebase_admin import credentials, firestore, storage
import os

# Placeholder for your Firebase Storage Bucket URL
# In a real setup, this might come from environment variables or config
FIREBASE_STORAGE_BUCKET = os.getenv("FIREBASE_STORAGE_BUCKET", "your-project-id.appspot.com") # Default placeholder

def _initialize_firebase_app():
    if not firebase_admin._apps:
        # Ensure GOOGLE_APPLICATION_CREDENTIALS is set in the environment
        try:
            cred = credentials.ApplicationDefault()
            firebase_admin.initialize_app(cred, {
                'storageBucket': FIREBASE_STORAGE_BUCKET
            })
            print(f"Firebase Admin SDK initialized with storage bucket: {FIREBASE_STORAGE_BUCKET}")
        except Exception as e:
            print(f"Warning: Could not initialize Firebase Admin SDK with Application Default Credentials: {e}")
            print("Please ensure GOOGLE_APPLICATION_CREDENTIALS and potentially FIREBASE_STORAGE_BUCKET are set for a real environment.")
            # Allow app to run for non-Firebase dependent parts if creds fail
            pass

def get_firestore_client():
    _initialize_firebase_app()
    # Check if app was initialized successfully before trying to get client
    if firebase_admin._apps:
        db = firestore.client()
        return db
    else:
        print("Error: Firebase Admin SDK is not initialized. Firestore client cannot be created.")
        return None

def get_firebase_storage_bucket():
    _initialize_firebase_app()
    # Check if app was initialized successfully before trying to get bucket
    if firebase_admin._apps:
        try:
            bucket = storage.bucket()
            return bucket
        except Exception as e:
            # This can happen if the bucket name in initialize_app is invalid or not accessible
            print(f"Error getting storage bucket (name: {FIREBASE_STORAGE_BUCKET}): {e}")
            return None
    else:
        print("Error: Firebase Admin SDK is not initialized. Storage bucket cannot be retrieved.")
        return None
