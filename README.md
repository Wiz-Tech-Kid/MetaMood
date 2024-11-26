# hacks

AI Mental Health Chatbot Application
Welcome to the AI Mental Health Chatbot Application! This Flutter application serves as a virtual assistant that provides mental health support. It leverages AI for conversational responses and integrates various Firebase services for user authentication, data storage, and analytics.

Features
-AI-Powered Conversations: Uses OpenAI's API to simulate a mental health chatbot.
-User Authentication: Firebase Authentication for secure user sign-in via email, Google, or anonymous methods.
-Database Integration: Firebase Realtime Database and Cloud Firestore for data persistence.
-Remote Configurations: Manage app behavior dynamically with Firebase Remote Config.
-Analytics: Track user activity using Firebase Analytics.
-Image Uploads: Allow users to upload and retrieve images using Firebase Storage.
-Interactive UI: Charts and animations for enhanced user engagement.
-Personalization: Store user preferences locally using Shared Preferences.

Getting Started

Prerequisites
-Flutter SDK
-Firebase project (set up for Android/iOS)
-OpenAI API key for AI responses

Installation
Clone the repository:

bash
git clone https://github.com/Wiz-Tech-Kid/MetaMood.git
cd 

Install dependencies:

bash
flutter pub get

Set up Firebase:
Download the google-services.json (for Android) and GoogleService-Info.plist (for iOS) from the Firebase console.

Place them in the respective directories:
Android: /android/app/
iOS: /ios/Runner/

Configure OpenAI:
Create an .env file at the root of the project:

env
OPENAI_API_KEY=your_openai_api_key
