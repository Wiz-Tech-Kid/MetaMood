# AI Mental Health Chatbot Application

Welcome to the **AI Mental Health Chatbot Application**! This Flutter application serves as a virtual assistant that provides mental health support. It leverages AI for conversational responses and integrates various Firebase services for user authentication, data storage, and analytics.

---

## Features
- **AI-Powered Conversations:** Uses OpenAI's API to simulate a mental health chatbot.
- **User Authentication:** Firebase Authentication for secure user sign-in via email, Google, or anonymous methods.
- **Database Integration:** Firebase Realtime Database and Cloud Firestore for data persistence.
- **Remote Configurations:** Manage app behavior dynamically with Firebase Remote Config.
- **Analytics:** Track user activity using Firebase Analytics.
- **Image Uploads:** Allow users to upload and retrieve images using Firebase Storage.
- **Interactive UI:** Charts and animations for enhanced user engagement.
- **Personalization:** Store user preferences locally using Shared Preferences.

---

## Getting Started

### Prerequisites
- Flutter SDK
- Firebase project (set up for Android/iOS)
- OpenAI API key for AI responses

---

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/your-repo/flutter-ai-mental-health-chatbot.git
   cd flutter-ai-mental-health-chatbot
2. Install dependencies:
   ```bash
   flutter pub get
3. Set up Firebase:
- Download the google-services.json (for Android) and GoogleService-Info.plist (for iOS) from the Firebase console.
- Place them in the respective directories:
   - Android: /android/app/
   - iOS: /ios/Runner/
4. Configure OpenAI:
- Create an .env file at the root of the project:
  ```env
  OPENAI_API_KEY=your_openai_api_key

---

### Dependencies
Below is a list of dependencies and their use cases:

| Dependency                 | Version  | Purpose                                                |
|----------------------------|----------|--------------------------------------------------------|
| `http`                     | ^1.2.2   | Makes HTTP requests to OpenAI API.                     |
| `shared_preferences`       | ^2.3.3   | Stores user preferences locally.                       |
| `firebase_core`            | ^3.8.0   | Connects the app to Firebase.                          |
| `flutter_animate`          | ^4.2.0   | Adds animations to UI elements.                        |
| `provider`                 | ^6.1.2	 | State management for the application.                  |
| `firebase_auth`	           | ^5.3.3	 | Handles user authentication.                           |
| `firebase_database`	     | ^11.1.6	 | Manages real-time data with Firebase Realtime Database.|
| `cloud_firestore`	        | ^5.5.0	 | Stores structured data in Cloud Firestore.             |
| `firebase_storage`	        | ^12.3.6	 | Uploads and retrieves images and files.                |
| `persistent_bottom_nav_bar`| ^6.2.1   | Provides a customizable bottom navigation bar.         |
| `intl`                     | ^0.19.0	 | Formats dates and times.                               |
| `flutter_animate`	        | ^4.2.0	 | Adds animations to UI elements.                        |
| `uuid`	                    | ^3.0.7	 | Generates unique identifiers for user sessions.        |
| `font_awesome_flutter`     | ^10.8.0	 | Adds icons for a polished UI.                          |
| `google_sign_in`	        | ^6.2.2	 | Allows Google sign-in integration.                     |
| `fl_chart`	              | ^0.69.2	 | Displays data using graphs and charts.                 |
| `dart_openai`              | ^5.1.0	 | Integrates OpenAI for conversational AI.               |
| `firebase_remote_config`	  | ^5.1.5	 | Enables dynamic configuration updates.                 |
| `image_picker`	           | ^1.1.2	 | Enables image selection from the gallery or camera.    |
| `firebase_analytics`	     | ^11.3.5	 | Tracks user interactions and app usage.                |

---

### Folder Structure

---

### Usage
1. Run the app:
     ```bash
     flutter run
2. Explore the chatbot interface and interact with the AI for mental health support.
3. Sign in or sign up using email or Google.
4. Save and retrieve data, upload images, and view user activity through charts.

---

### Firebase Setup
Ensure the following services are enabled in your Firebase project:

- Authentication
- Realtime Database
- Firestore Database
- Storage
- Analytics
- Remote Config

---

### Contributing
Contributions are welcome! Please fork the repository, make changes, and submit a pull request.

---

### License
This project is licensed under the MIT License. See LICENSE for details.
