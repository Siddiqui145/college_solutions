# College Solutions 📚

**College Solutions** is a cross-platform mobile application built using **Flutter** and **Dart**. The app aims to improve the efficiency of college operations, reduce the workload on student sections, and provide students with a centralized platform for accessing essential resources and updates. With an intuitive UI and powerful features, College Solutions bridges the gap between students and administrative services, ensuring smoother communication and resource accessibility.

---

## Features 🚀

### 1. **User Authentication**
- **Login, Signup, and Reset Password**: Users can securely log in, sign up, and reset their passwords using Firebase Authentication.

### 2. **User Roles**
- **Admin**:
  - Add and remove notifications related to college updates like exam results, events, or other important announcements.
- **User**:
  - View the latest notifications and updates shared by the admin.

### 3. **College-Specific Notifications**
- Admins can broadcast notifications about college events, examination updates, fee reminders, and more.
- Users receive these notifications in real time, thanks to Firebase Firestore integration.

### 4. **Useful Links Section**
A curated list of essential resources for students, including:
- **University Website**: Direct access to the official university site.
- **Fees Portal**: Quick access to the fee payment platform.
- **Feedback Link**: Submit feedback directly to the college administration.
- **Previous Year Question Papers**: Access a repository of previous year exam papers.

### 5. **Gemini API Integration (Fine-Tuned for College Use)**
- A chatbot powered by **Gemini API**, fine-tuned with college-specific data.
- Handles queries like:
  - College name and location.
  - Fees structure and payment deadlines.
  - Examination dates and schedules.
  - Any other college-specific information.

### 6. **Cross-Platform Support**
- The app runs seamlessly on both **iOS** and **Android**, ensuring accessibility for all students.

---

## Tech Stack 🛠️

- **Framework**: Flutter
- **Programming Language**: Dart
- **Backend**: Firebase (Authentication and Firestore)
- **AI Chatbot**: Gemini API (Fine-Tuned for college-specific responses)

---

## Installation & Setup 🔧

Follow these steps to get the project running locally:

### Prerequisites
- Install Flutter: [Flutter Installation Guide](https://docs.flutter.dev/get-started/install)
- Set up Firebase for your project:
  - Firebase Authentication
  - Firestore Database

### Steps
1. Clone the repository:
   ```bash
   git clone https://github.com/Siddiqui145/college_solutions.git
   cd college_solutions
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Configure Firebase:
   - Add your `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) to the respective folders in the project.
4. Run the app:
   ```bash
   flutter run
   ```

---

## Demo 🎥

Here’s a short demo video showcasing the app's functionalities: [Demo Video Link](https://youtu.be/your-demo-link)

---

## Folder Structure 📂

```
lib/
├── main.dart              # Entry point of the application
├── screens/               # Contains all the screens (e.g., Login, Profile, etc.)
├── widgets/               # Reusable widgets like the Drawer
├── services/              # Firebase and API service integrations
└── models/                # Data models for structured data handling
└── providers/             # Chat and message providers
└── routes/                # Router for Auto routing in the app

```

---

## Screenshots 📸


Chat Screen :
 ![Screenshot_20250108_121342](https://github.com/user-attachments/assets/00d009d5-7d58-4f26-b611-0bb9d859ed63)

---

## Future Enhancements 🛠️

- Add push notifications for instant updates.
- Include more interactive features in the chatbot.
- Introduce user feedback analytics for the admin.
- Enhance the UI/UX for better accessibility.

---

## Contributing 🤝

We welcome contributions! Follow the steps below:
1. Fork the repository.
2. Create a new branch for your feature/bugfix.
3. Commit your changes and push to your fork.
4. Create a pull request.

---

## License 📜

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Acknowledgments 🙏

- **Flutter**: For providing a robust framework for cross-platform app development.
- **Firebase**: For powering the backend with real-time data capabilities.
- **Gemini API**: For enabling college-specific AI chatbot functionalities.

---

Let us know your feedback and suggestions for improvement! 😊
