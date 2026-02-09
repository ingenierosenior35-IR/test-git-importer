
# 🏆 Rival - Sports Performance Tracking App

A modern Flutter application for tracking sports performance, managing matches, analyzing player statistics, and building a competitive sports community.

## 🎯 Features

- **🔐 Authentication**: Phone OTP, Google, and Facebook login
- **👤 Smart Onboarding**: Sport selection, profile setup, photo upload with avatar creation
- **🏠 Home Dashboard**: Player card, scoreboards, match agenda, quick actions
- **⚽ Matches**: Create and manage matches, invite players, track status
- **🎥 Video Analysis**: Upload match videos, processing status tracking
- **📊 Performance Analysis**: Player metrics, match history, highlights
- **👥 Profile**: User stats, evolution charts, rating system

## 🎨 Design System

**Theme**: Dark mode with neon yellow accent
- Primary: #CDFF4D (Neon Yellow)
- Background: #000000 (Black)
- Cards: #192126, #252D32 (Dark Grey)

## 🏗️ Architecture

Built with **Clean Architecture** and feature-first organization:

```
lib/
├── app/              # App configuration, routes, bindings
├── core/             # Constants, utilities, network
├── features/         # Feature modules (auth, home, matches, etc.)
│   └── [feature]/
│       ├── domain/   # Entities, repositories, use cases
│       ├── data/     # Models, datasources, implementations
│       └── presentation/  # Screens, controllers, widgets
├── services/         # Global services (Auth, Firestore, etc.)
└── shared/           # Shared widgets and utilities
```

## 📋 Tech Stack

- **Framework**: Flutter 3.5.3+
- **State Management**: GetX
- **Backend**: Firebase (Auth, Firestore, Storage)
- **UI Components**: Material Design + Custom widgets
- **Image Handling**: Image Picker, Cached Network Image
- **Permissions**: Permission Handler


### Table of contents
- [System requirements](#system-requirements)
- [Figma design guidelines for better UI accuracy](#figma-design-guideline-for-better-accuracy)
- [Check the UI of the entire app](#app-navigations)
- [Application structure](#project-structure)
- [How to format your code?](#how-you-can-do-code-formatting)
- [How you can improve code readability?](#how-you-can-improve-the-readability-of-code)
- [Libraries and tools used](#libraries-and-tools-used)
- [Support](#support)

### System requirements

- Dart SDK Version 3.5.3 or greater
- Flutter SDK Version 3.3.0 or greater
- iOS 12.0+ / Android 21+ (API Level 21)

## 🚀 Getting Started

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/ingenierosenior35-IR/test-git-importer.git
   cd test-git-importer
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Add `google-services.json` to `android/app/`
   - Add `GoogleService-Info.plist` to `ios/Runner/`
   - Enable Auth methods (Phone, Google, Facebook) in Firebase Console
   - Enable Cloud Firestore and Storage
   - See `FIREBASE_SETUP.md` for detailed instructions

4. **Run the app**
   ```bash
   flutter run
   ```

### Build for Production

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## 📱 App Flow

1. **Splash Screen** (3s) → Check authentication status
2. **Welcome/Login** → Phone OTP, Google, or Facebook
3. **Onboarding** (first-time users):
   - Sport Selection (up to 5 sports)
   - Gender Selection
   - Height (metric only, cm)
   - Weight (metric only, kg)
   - Photo Upload (camera/gallery)
   - Congratulations (avatar creation animation)
4. **Main App** (bottom navigation):
   - Home
   - Matches
   - Video
   - Analysis
   - Profile

## 🎬 Key Screens

### Authentication
- `WelcomeScreen`: Modal design with social login options
- `OTPVerificationScreen`: 6-digit PIN input with Pinput widget
- `SportSelectionScreen`: Grid of sports with max 5 selection

### Onboarding
- `HeightScreen`: Scroll picker for height (100-250 cm)
- `WeightScreen`: Scroll picker for weight (30-200 kg)
- `PhotoUploadScreen`: Camera/gallery with permission handling
- `CongratulationsScreen`: Avatar creation animation + success

### Main Features
- `HomeScreen`: Player card, scoreboards, matches agenda
- `MatchesListScreen`: Upcoming and past matches
- `CreateMatchScreen`: Match details, pitch, time, players
- `VideoUploadScreen`: Upload and link videos to matches
- `MatchHistoryScreen`: Statistics and player metrics
- `ProfileScreen`: User info, stats, settings

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/widget_test.dart

# Code coverage
flutter test --coverage
```

## 🔧 Development

### Code Formatting
```bash
dart format .
```

### Code Analysis
```bash
flutter analyze
```

### Useful Commands
```bash
# Clean build cache
flutter clean && flutter pub get

# Check Flutter version
flutter doctor -v

# Update dependencies
flutter pub upgrade
```

## 📖 Documentation

- **[REFACTOR_SUMMARY.md](REFACTOR_SUMMARY.md)** - Complete refactoring overview
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Architecture documentation
- **[FIREBASE_SETUP.md](FIREBASE_SETUP.md)** - Firebase configuration guide
- **[BUG_FIXES_SUMMARY.md](BUG_FIXES_SUMMARY.md)** - Bug fixes changelog

## 🤝 Contributing

This is a private project. For questions or issues, contact the development team.


## 📚 Libraries and Tools Used

### Core
- **[get](https://pub.dev/packages/get)** - State management & navigation
- **[firebase_core](https://pub.dev/packages/firebase_core)** - Firebase initialization
- **[firebase_auth](https://pub.dev/packages/firebase_auth)** - Authentication
- **[cloud_firestore](https://pub.dev/packages/cloud_firestore)** - Database
- **[firebase_storage](https://pub.dev/packages/firebase_storage)** - File storage

### UI & Media
- **[google_fonts](https://pub.dev/packages/google_fonts)** - Typography
- **[cached_network_image](https://pub.dev/packages/cached_network_image)** - Image caching
- **[flutter_svg](https://pub.dev/packages/flutter_svg)** - SVG support
- **[image_picker](https://pub.dev/packages/image_picker)** - Camera & gallery
- **[permission_handler](https://pub.dev/packages/permission_handler)** - Permissions

### Authentication & Input
- **[google_sign_in](https://pub.dev/packages/google_sign_in)** - Google login
- **[flutter_facebook_auth](https://pub.dev/packages/flutter_facebook_auth)** - Facebook login
- **[pinput](https://pub.dev/packages/pinput)** - PIN input for OTP
- **[pin_code_fields](https://pub.dev/packages/pin_code_fields)** - Alternative PIN input

### Utilities
- **[shared_preferences](https://pub.dev/packages/shared_preferences)** - Local storage
- **[connectivity_plus](https://pub.dev/packages/connectivity_plus)** - Network status
- **[intl](https://pub.dev/packages/intl)** - Internationalization
- **[dartz](https://pub.dev/packages/dartz)** - Functional programming
- **[equatable](https://pub.dev/packages/equatable)** - Value equality

## 📄 License

Copyright © 2024 Rival. All rights reserved.

---

Made with ❤️ using Flutter
