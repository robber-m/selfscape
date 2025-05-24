# Phase 1: MVP - The Vocal Snapshot & Basic Workshop

This document outlines the design and implementation steps for the Minimum Viable Product (MVP) of the Vocal Workshop module for the "My Anthropos" (or "SelfScape") application. The goal is to allow a user to record their voice, have it cloned, and then use that cloned voice to speak provided text.

## A. Research & Decision Making

1.  **Select a Voice Cloning Technology:**
    * **Key Task:** Evaluate and choose a suitable voice cloning service or model.
    * **Prominent Options:**
        * ElevenLabs API
        * Coqui TTS (Open-source or Cloud)
        * Resemble AI
        * Descript
    * **Evaluation Criteria:**
        * **Quality of Cloned Voice:** Naturalness, expressiveness.
        * **Ease of Integration:** API developer-friendliness, SDK availability (especially for Dart/Flutter or backend language).
        * **Latency:** Speed of cloning and speech synthesis.
        * **Pricing Model:** Costs, free tiers, trial options.
        * **Ethical Guidelines & Terms of Service:** Alignment with project values.
        * **Input Requirements:** Amount and format of audio needed for cloning.
    * **Action:** Conduct research, review documentation, and perform tests if possible.

## B. Design (Flutter UI/UX - Initial Screens)

1.  **Screen 1: "Create Vocal Snapshot"**
    * **Content:**
        * Clear title (e.g., "Create Your Vocal Snapshot").
        * Brief instructional text.
        * Prominent "Start Recording" button.
        * Optional: Note on ideal recording conditions.
2.  **Screen 2: Recording Interface**
    * **Features:**
        * Visual feedback during recording (e.g., waveform display, timer).
        * "Stop Recording" button.
        * Option to playback the current recording.
        * "Submit for Cloning" or "Use This Recording" button.
        * Clear instructions for the recording process (e.g., script to read, duration).
3.  **Screen 3: "Voice Workshop" (Basic)**
    * **Features:**
        * Text input field for speech synthesis.
        * "Speak" or "Synthesize" button.
        * Audio playback controls for the generated speech.
        * Indication of the active voice model (e.g., "Your Cloned Voice").

## C. Backend Development (Initial AI Agent Logic)

* **Approach:** Develop server-side functions/services that the Flutter app will call. These represent the initial, simplified versions of the "Vocal Snapshot Agent" and "Expression Synthesis Agent."
1.  **Setup Basic Backend Environment:**
    * **Technology Choice:** Python (Flask/FastAPI), Node.js, or other suitable backend framework.
    * **API Design:** Define API endpoints for Flutter app communication (e.g., using REST or gRPC).
2.  **"Vocal Snapshot Service" Logic:**
    * **Endpoint:** To receive audio data from the Flutter app.
    * **Functionality:**
        * Basic validation of received audio (e.g., file size, format).
        * Interact with the chosen voice cloning service's API:
            * Upload the audio.
            * Initiate the cloning process.
            * Securely store the resulting voice ID or model identifier.
        * Return a success/failure response (including voice ID if successful) to the Flutter app.
3.  **"Expression Synthesis Service" Logic:**
    * **Endpoint:** To receive text and the voice ID from the Flutter app.
    * **Functionality:**
        * Interact with the voice cloning service's API:
            * Send the text and voice ID for Text-to-Speech (TTS) synthesis.
            * Receive the generated audio data.
        * Return the audio data (or a link to it) to the Flutter app.

## D. Flutter Frontend Development

1.  **Project Setup:**
    * Initialize a new Flutter project.
2.  **UI Implementation:**
    * Build the three screens detailed in section B.
3.  **Audio Recording Functionality:**
    * Integrate a Flutter package for audio recording (e.g., `record`, `flutter_sound`).
    * Implement recording controls and data handling.
4.  **API Integration:**
    * Develop Dart code for making HTTP requests (or other protocol if chosen) to the backend endpoints.
    * Handle API responses, including errors and successful data retrieval (e.g., audio for playback).
5.  **Audio Playback Functionality:**
    * Integrate a Flutter package for audio playback (e.g., `just_audio`, `audioplayers`).
    * Implement controls for playing synthesized speech.
6.  **State Management:**
    * Choose and implement a state management solution (e.g., Provider, BLoC, Riverpod, GetX).
    * Manage application state related to recording, cloning status, voice ID, and text input.

## E. Immediate Next Steps & Discussion Points

* **Voice Cloning Technology Selection:** Prioritize research and decision on the voice cloning service. This impacts backend and frontend integration significantly.
* **Core User Flow Refinement:** Confirm the basic user journey for Phase 1: Record -> Submit for Cloning -> Receive Confirmation (Voice ID) -> Enter Text in Workshop -> Hear Cloned Voice.
* **Resource Planning:** Identify if this will be a solo or team effort to plan task allocation.
* **Detailed API Contract:** Define the specific request/response formats between the Flutter app and the backend services.