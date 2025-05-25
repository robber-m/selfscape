# Backend Setup

1.  **Create and activate a virtual environment:**
    ```bash
    python -m venv venv
    source venv/bin/activate  # On Windows use `venv\Scripts\activate`
    ```
2.  **Install dependencies:**
    ```bash
    pip install -r requirements.txt
    ```
3.  **Firebase Setup (Important for Firestore Integration):**
    *   Ensure you have a Firebase project and a service account key JSON file.
    *   Set the `GOOGLE_APPLICATION_CREDENTIALS` environment variable to the path of your service account key file.
        ```bash
        export GOOGLE_APPLICATION_CREDENTIALS="/path/to/your/serviceAccountKey.json"
        ```
    *   On Windows, you might use:
        ```powershell
        $env:GOOGLE_APPLICATION_CREDENTIALS="C:\path\to\your\serviceAccountKey.json"
        ```
    *   Set the `FIREBASE_STORAGE_BUCKET` environment variable to your Firebase project's storage bucket URL (e.g., `your-project-id.appspot.com`).
        ```bash
        export FIREBASE_STORAGE_BUCKET="your-project-id.appspot.com"
        ```
    *   On Windows, you might use:
        ```powershell
        $env:FIREBASE_STORAGE_BUCKET="your-project-id.appspot.com"
        ```
    *   Without these, the application might not be able to connect to Firestore or Firebase Storage.

4.  **Run the FastAPI application:**
    ```bash
    uvicorn main:app --reload --app-dir backend
    ```
    The application will be available at `http://127.0.0.1:8000`.
    Note the addition of `--app-dir backend` to ensure Uvicorn runs from the project root
    and can find the `backend` module correctly.

5.  **Accessing API Documentation:**
    Once the server is running, you can access the auto-generated OpenAPI documentation:
    *   Swagger UI: `http://127.0.0.1:8000/docs`
    *   ReDoc: `http://127.0.0.1:8000/redoc`
