# LearnX - Mobile Learning Marketplace

A starter template for building high-quality Flutter applications. Designed with scalability, maintainability, and clean architecture.

## 🚀 Features

*   **Robust Authentication**: Pre-configured Providers for Login, Signup, and Forgot Password flows.
*   **Dependency Injection**: Centralized Service Locator using `get_it` for efficient dependency management.
*   **Networking**: Pre-configured `Dio` client with Interceptors (Auth, Logging) and `flutter_dotenv` for environment configuration.
*   **Navigation**: Service-based navigation allowing navigation from anywhere (even business logic) without Context.
*   **Internationalization (i18n)**:
    *   Full support for **English, Spanish, Arabic**.
    *   **RTL Support** for Arabic.
    *   Auto-generation of Dart localization classes.
*   **Theming**:
    *   Light & Dark mode support.
    *   Persisted user preference.
    *   Tailored Material 3 design system.
*   **State Management**: Simple and effective state management using `Provider`.
*   **Secure & Local Storage**: Unified `StorageService` for both `SharedPreferences` and `FlutterSecureStorage`.

## 🛠 Tech Stack

*   **Framework**: Flutter & Dart
*   **State Management**: Provider
*   **Networking**: Dio
*   **Dependency Injection**: GetIt
*   **Storage**: Flutter Secure Storage & Shared Preferences
*   **Icons**: Ionicons

## 📂 Project Structure

The project structure is designed to be intuitive and scalable.

```
lib/
├── constants/             # Global constants files
│   └── storage_keys.dart  # Keys used for local/secure storage
├── l10n/                  # Localization ARB files
├── providers/             # State Management (Logic & State)
│   ├── auth_provider.dart     # Authentication logic
│   └── settings_provider.dart # Theme & Language logic
├── screens/               # UI Screens (Pages)
├── services/              # Infrastructure & External Services
│   ├── api_service.dart       # API Client wrapper
│   ├── auth_interceptor.dart  # Auto-injects Bearer token
│   ├── navigation_service.dart# Context-less navigation 
│   ├── service_locator.dart   # GetIt DI Setup
│   └── storage_service.dart   # Unified Storage wrapper
├── theme/                 # Design System & Theme Config
├── widgets/               # Reusable UI Components
├── app.dart               # Root Widget
└── main.dart              # Entry Point
```

## ⚡ Getting Started

### 1. Requirements

*   Flutter SDK (Latest Stable)
*   VS Code or Android Studio

### 2. Setup

clone the repo and install dependencies:

```bash
flutter pub get
```

### 3. Environment Config

Creation a `.env` file in the root directory don't forget to add it to `.gitignore` if haven't already:

```env
API_BASE_URL=https://api.yourdomain.com
```

### 4. Run the App

```bash
flutter run
```

## 📖 Development Guide

### How to Add a New Page

1.  Create the screen file in `lib/screens/my_new_screen.dart`.
2.  Register the route in `lib/app.dart` inside the `routes` map.
    ```dart
    '/my-new-screen': (context) => const MyNewScreen(),
    ```
3.  Navigate to given route:
    ```dart
    getIt<Navigation>().navigateTo('/my-new-screen');
    ```

### How to Add/Edit Translations

1.  Open `lib/l10n/app_en.arb` (English is the template).
2.  Add your new key-value pair:
    ```json
    "helloWorld": "Hello World",
    "@helloWorld": {
      "description": "Greeting text"
    }
    ```
3.  Add the same key to `app_es.arb` and `app_ar.arb` with translations.
4.  Run the app. Flutter will auto-generate the Dart code.
5.  Use it in code: `AppLocalizations.of(context)!.helloWorld`.

### How to Add a New Service

1.  Create your service class in `lib/services/`.
2.  Register it in `lib/services/service_locator.dart`:
    ```dart
    getIt.registerLazySingleton<MyService>(() => MyService());
    ```
3.  Access it anywhere:
    ```dart
    final myService = getIt<MyService>();
    ```

### Networking

The `ApiService` is already set up with `Dio`.

```dart
// Example usage
final api = getIt<ApiService>();
try {
  final response = await api.get('/users');
} catch (e) {
  print(e);
}
```

## 🧹 Maintenance

*   **Linting**: The project uses `flutter_lints`. Run `flutter analyze` to check for issues.
*   **Testing**: Basic test setup is in `test/`. Run `flutter test` to execute.
