# LearnX - Educational Platform

LearnX is a powerful Learning Management System (LMS) built with Flutter. It bridges the gap between instructors and learners, offering a seamless experience for creating, distributing, and consuming educational content.

## 🌟 Features

### 👨‍🏫 For Instructors
*   **Course Management**: Create, edit, and delete courses with ease.
*   **Content Creation**: Build structured curriculums with Modules and Lessons.
*   **Rich Media Support**: Upload Videos and Images for lessons.
*   **Dashboard**: Track performance with real-time statistics (Revenue, Total Students, Course Count).
*   **Student Insights**: View enrolled students and their details.

### 👨‍🎓 For Students
*   **Course Discovery**: Browse courses by category or search by title.
*   **Enrollment System**: Purchase and enroll in courses (Mock Payment integrated).
*   **Offline Learning**: Download lessons for offline access (User-scoped downloads).
*   **Progress Tracking**: Track purchased courses via **Purchase History**.
*   **Interactive Player**: Built-in video player with note-taking capabilities.
*   **Personalization**: Manage profile, view downloads, and review courses.

## 🛠 Tech Stack

*   **Framework**: Flutter & Dart
*   **State Management**: Provider
*   **Architecture**: Service-Locator pattern (GetIt) with Repository pattern concepts.
*   **Storage**: 
    *   `shared_preferences`: for local database (Courses, Users, Enrollments).
    *   `path_provider`: for local file storage.
*   **Media**: `video_player`, `chewie` for video playback; `image_picker` for content uploads.
*   **Navigation**: Custom role-based routing.

## 📂 Project Structure

```
lib/
├── constants/             # App-wide constants (Keys, Strings)
├── l10n/                  # Localization files
├── models/                # Data Models (Course, User, Lesson, etc.)
├── providers/             # State Management (Auth, Theme)
├── screens/               # UI Screens
│   ├── auth/              # Login, Register, Splash
│   ├── instructor/        # Dashboard, Course Builder
│   ├── learner/           # Home, Player, Course Details
│   ├── payments/          # Checkout, Purchase History
│   └── ...
├── services/              # Logic Layer (Auth, Course, Storage)
├── theme/                 # App Theme Configuration
├── utils/                 # Helpers and Extensions
├── widgets/               # Reusable UI Components
└── main.dart              # Entry Point
```

## ⚡ Getting Started

### 1. Prerequisites
*   Flutter SDK (3.0+)
*   Dart SDK

### 2. Installation

Clone the repository and install dependencies:

```bash
git clone https://github.com/your-username/learnx.git
cd learnx
flutter pub get
```

### 3. Run the App

```bash
flutter run
```

*   **Login as Instructor**: Register a account with "Instructor" role.
*   **Login as Student**: Register a account with "Student" role.

## 📱 Screenshots

| Student Home | Course Detail | Lesson Player |
|:---:|:---:|:---:|
| *(Place screenshot here)* | *(Place screenshot here)* | *(Place screenshot here)* |

## 🤝 Contributing

Contributions are welcome! Please fork the repository and submit a pull request.

## 📄 License

This project is licensed under the MIT License.
