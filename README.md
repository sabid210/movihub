<div align="center">

# 🎬 MoviHub

### Your Personal Movie Discovery & Tracking App

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%7C%20Auth%20%7C%20FCM-FFCA28?logo=firebase)](https://firebase.google.com)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android)](https://www.android.com)

**MoviHub** is a Flutter-based mobile application for discovering, tracking, and reviewing movies and TV shows. Browse trending titles, maintain a personal watchlist, rate what you've watched, and connect with friends over shared film tastes — all in one place.

[Download APK](#-download-apk) · [Features](#-core-features) · [Setup](#-getting-started) · [Docs](DOCUMENTATION.md)

</div>

---

## 📱 Download APK

> **Pre-built release APKs** are available in the repository root:
> - [`movihub-v2.apk`](./movihub-v2.apk) ← Latest version (recommended)
> - [`movihub.apk`](./movihub.apk) ← Previous version

Install directly on any Android 6.0+ device. Enable **"Install from unknown sources"** in Settings → Security before installing.

---

## 🌍 Why MoviHub?

| Problem | MoviHub Solution |
|---|---|
| Can't remember what you've watched | Personal watched history with ratings |
| Losing track of movies to watch later | Persistent watchlist synced to cloud |
| Hard to discover new films | Trending, popular & recommended feeds |
| No central place for movie notes | Review and rate every title you watch |

---

## ✨ Core Features

### 🎥 Movie Discovery
- Browse **Trending**, **Popular**, and **Top Rated** movies
- Discover TV shows alongside films
- Detailed movie pages: cast, synopsis, runtime, genres, release date
- Genre-based filtering

### 📋 Watchlist & Tracking
- Add any title to your **personal watchlist**
- Mark titles as **Watched**
- Persistent storage via Firebase Firestore

### ⭐ Ratings & Reviews
- Rate movies on a 1–10 scale
- Write personal reviews
- View your full rating history on your profile

### 🔍 Search
- Full-text search across movies and TV shows
- Real-time results as you type
- Filter by type (movie / TV)

### 🔔 Notifications
- New release alerts for followed titles
- Friend activity notifications
- Push notifications via Firebase Cloud Messaging

### 👤 User Profile
- Email + Password registration & login
- Google Sign-In
- Profile stats: total watched, average rating, favourite genres

---

## 🏗️ Project Structure

```
lib/
├── main.dart                          # App entry point, Firebase init
├── firebase_options.dart              # Firebase project config (auto-generated)
│
├── core/
│   ├── routes/
│   │   └── app_router.dart            # Named route definitions
│   ├── services/
│   │   └── notification_service.dart  # FCM + local notifications
│   └── theme/
│       └── app_theme.dart             # Color palette, typography, global theme
│
└── features/
    ├── splash/
    │   └── splash_screen.dart         # Animated splash + auth redirect
    ├── auth/
    │   ├── login_screen.dart          # Email & Google login
    │   └── register_screen.dart       # Registration + Firestore user doc
    ├── home/
    │   └── home_screen.dart           # Main shell, bottom nav, trending feed
    ├── movie/
    │   ├── movie_detail_screen.dart   # Full movie info + watchlist + review
    │   ├── browse_screen.dart         # Browse by genre/category
    │   └── search_screen.dart         # Full-text search
    ├── watchlist/
    │   └── watchlist_screen.dart      # Saved & watched titles list
    ├── reviews/
    │   └── reviews_screen.dart        # User's ratings and reviews
    ├── notifications/
    │   └── notifications_screen.dart  # In-app notification feed
    └── profile/
        ├── profile_screen.dart        # User stats and activity
        └── settings_screen.dart       # App preferences
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **UI Framework** | Flutter 3.x (Material Design 3) |
| **Language** | Dart 3.x |
| **Backend / Database** | Firebase Firestore (NoSQL, real-time) |
| **Authentication** | Firebase Auth (Email/Password + Google) |
| **Push Notifications** | Firebase Cloud Messaging (FCM) |
| **Fonts** | Google Fonts |
| **State Management** | setState + StreamBuilder (widget-level) |
| **Navigation** | Named routes via AppRouter |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- Android Studio / VS Code
- Firebase project (Firestore + Auth + FCM enabled)

### 1. Clone the repository

```bash
git clone https://github.com/sabid210/movihub.git
cd movihub
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

The `lib/firebase_options.dart` is already configured for the project. If you fork and use your own Firebase project:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Enable in Firebase Console:
- ✅ Firestore Database
- ✅ Authentication → Email/Password + Google
- ✅ Cloud Messaging

### 4. Run the app

```bash
flutter run
```

---

## 📦 Building the APK

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Split by ABI (smaller per-device size)
flutter build apk --split-per-abi --release
```

Output:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🔥 Firestore Data Model

```
Firestore
│
├── users/{uid}
│   ├── user_id: string
│   ├── name: string
│   ├── email: string
│   ├── fcmToken: string
│   ├── created_at: timestamp
│   └── watchlist/{movieId}        ← subcollection
│       ├── movie_id: string
│       ├── title: string
│       ├── poster_url: string
│       ├── is_watched: boolean
│       └── added_at: timestamp
│
├── reviews/{reviewId}
│   ├── user_id: string
│   ├── movie_id: string
│   ├── movie_title: string
│   ├── rating: number             1–10
│   ├── review_text: string
│   └── created_at: timestamp
│
└── notifications/{notifId}
    ├── user_id: string
    ├── type: string               release | friend | recommendation
    ├── title: string
    ├── body: string
    ├── is_read: boolean
    ├── movie_id?: string
    └── created_at: timestamp
```

---

## 📋 Dependencies

```yaml
# Firebase
firebase_core: ^2.27.0
firebase_auth: ^4.17.0
cloud_firestore: ^4.15.0
firebase_messaging: ^14.7.15

# Auth
google_sign_in: ^6.2.1

# UI & Fonts
google_fonts: ^6.2.1
cached_network_image: ^3.3.1
shimmer: ^3.0.0

# Notifications
flutter_local_notifications: ^17.2.4

# Utils
intl: ^0.19.0
uuid: ^4.3.3
shared_preferences: ^2.2.2
```

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m "feat: add your feature"`
4. Push to the branch: `git push origin feature/your-feature`
5. Open a Pull Request

---

## 👨‍💻 Author

**Sabid**
- GitHub: [@sabid210](https://github.com/sabid210)
- Project: [movihub](https://github.com/sabid210/movihub)

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<div align="center">
Made with 🎬 for movie lovers
</div>
