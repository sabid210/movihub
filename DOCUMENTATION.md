# 📖 MoviHub — Technical Documentation

> Full technical reference for the MoviHub Flutter application.
> For a quick overview, see [README.md](README.md).

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Screen-by-Screen Breakdown](#2-screen-by-screen-breakdown)
3. [Firebase / Firestore API](#3-firebase--firestore-api)
4. [Authentication Flow](#4-authentication-flow)
5. [Notification System](#5-notification-system)
6. [State Management](#6-state-management)
7. [Routing](#7-routing)
8. [Theming](#8-theming)
9. [Build & Deployment Guide](#9-build--deployment-guide)

---

## 1. Architecture Overview

MoviHub follows a **feature-first folder structure**. Each screen lives in its own feature folder under `lib/features/`, and cross-cutting concerns (routing, theming, services) live under `lib/core/`.

```
lib/
├── core/
│   ├── routes/        ← Centralized named routes
│   ├── services/      ← FCM, notification handler
│   └── theme/         ← App-wide color & typography
└── features/
    ├── auth/
    ├── home/
    ├── movie/
    ├── watchlist/
    ├── reviews/
    ├── notifications/
    └── profile/
```

**State management** is kept intentionally simple: `setState` for local UI state, `StreamBuilder` for live Firestore data. No external state management library (no Provider, Riverpod, or Bloc) is used, keeping the codebase accessible for contributors.

---

## 2. Screen-by-Screen Breakdown

### 2.1 Splash Screen (`splash_screen.dart`)
- Displays animated app logo on launch.
- Checks `FirebaseAuth.instance.currentUser`:
  - If logged in → navigate to `HomeScreen`
  - If not → navigate to `LoginScreen`

### 2.2 Login Screen (`auth/login_screen.dart`)
- Email + Password login via `FirebaseAuth.signInWithEmailAndPassword`
- Google Sign-In via `GoogleSignIn` package
- On success → navigate to `HomeScreen`
- Validation: non-empty fields, valid email format

### 2.3 Register Screen (`auth/register_screen.dart`)
- Creates Firebase Auth user
- On success, writes a user document to `users/{uid}` in Firestore:
  ```dart
  {
    'user_id': uid,
    'name': displayName,
    'email': email,
    'fcmToken': await FirebaseMessaging.instance.getToken(),
    'created_at': Timestamp.now(),
  }
  ```

### 2.4 Home Screen (`home/home_screen.dart`)
- Bottom navigation bar with tabs: Home, Search, Watchlist, Profile
- Home tab shows:
  - **Trending Now** horizontal scroll (live Firestore feed)
  - **Popular Movies** grid
  - **Continue Watching** (watchlist items marked as started)
- Uses `StreamBuilder` on `listings` collection for real-time updates

### 2.5 Movie Detail Screen (`movie/movie_detail_screen.dart`)
- Shows full movie info: poster, title, year, runtime, genres, synopsis, cast
- Action buttons:
  - **Add to Watchlist** → writes to `users/{uid}/watchlist/{movieId}`
  - **Mark as Watched** → updates `is_watched: true` in watchlist subcollection
  - **Rate & Review** → opens rating bottom sheet
- Handles movie not in watchlist / already watched states

### 2.6 Browse Screen (`movie/browse_screen.dart`)
- Filter bar: All / Movies / TV Shows
- Genre chips for quick filtering
- Grid layout with poster cards and title overlay
- Tapping a card navigates to `MovieDetailScreen`

### 2.7 Search Screen (`movie/search_screen.dart`)
- `TextField` with `onChanged` triggers client-side filter on cached Firestore data
- Debounced to avoid excessive reads
- Results show poster thumbnail, title, year, and type badge (Movie / TV)

### 2.8 Watchlist Screen (`watchlist/watchlist_screen.dart`)
- Two tabs: **To Watch** and **Watched**
- Reads `users/{uid}/watchlist` subcollection
- Long-press to remove from watchlist

### 2.9 Reviews Screen (`reviews/reviews_screen.dart`)
- Lists all user reviews from `reviews` collection filtered by `user_id`
- Shows star rating, movie title, and review snippet
- Tap to expand full review

### 2.10 Notifications Screen (`notifications/notifications_screen.dart`)
- Reads `notifications` collection filtered by `user_id`
- Sorted by `created_at` descending
- Tap notification → mark `is_read: true`
- **Mark All as Read** button

### 2.11 Profile Screen (`profile/profile_screen.dart`)
- Displays:
  - Avatar + display name + email
  - Stats: total watched, total reviews, average rating, favourite genre
- Links to Settings and Reviews screens
- Sign Out button

### 2.12 Settings Screen (`profile/settings_screen.dart`)
- Toggle: push notifications on/off
- Theme selector: Light / Dark / System
- Account: Change password, Delete account

---

## 3. Firebase / Firestore API

### Collections

#### `users/{uid}`
| Field | Type | Description |
|-------|------|-------------|
| `user_id` | string | Firebase Auth UID |
| `name` | string | Display name |
| `email` | string | Registered email |
| `fcmToken` | string | FCM push token (updated on login) |
| `created_at` | timestamp | Registration time |

#### `users/{uid}/watchlist/{movieId}` (subcollection)
| Field | Type | Description |
|-------|------|-------------|
| `movie_id` | string | Unique movie identifier |
| `title` | string | Movie title |
| `poster_url` | string | Cloudinary or TMDB poster URL |
| `is_watched` | boolean | Has the user watched it |
| `added_at` | timestamp | When it was added |

#### `reviews/{reviewId}`
| Field | Type | Description |
|-------|------|-------------|
| `user_id` | string | Author UID |
| `movie_id` | string | Target movie |
| `movie_title` | string | Denormalized title |
| `rating` | number | 1–10 |
| `review_text` | string | Free-text review |
| `created_at` | timestamp | Submission time |

#### `notifications/{notifId}`
| Field | Type | Description |
|-------|------|-------------|
| `user_id` | string | Target user |
| `type` | string | `release` / `friend` / `recommendation` |
| `title` | string | Notification heading |
| `body` | string | Notification message |
| `is_read` | boolean | Read state |
| `movie_id` | string? | Related movie (optional) |
| `created_at` | timestamp | Creation time |

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;

      match /watchlist/{movieId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }

    match /reviews/{reviewId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null
        && request.auth.uid == resource.data.user_id;
    }

    match /notifications/{notifId} {
      allow read, write: if request.auth != null
        && request.auth.uid == resource.data.user_id;
      allow create: if request.auth != null;
    }
  }
}
```

---

## 4. Authentication Flow

```
App Launch
    │
    ▼
SplashScreen
    │
    ├─ Auth user exists? ──YES──► HomeScreen
    │
    └─ NO
        │
        ▼
    LoginScreen
        │
        ├─ Email/Password ──────► FirebaseAuth.signInWithEmailAndPassword()
        │                               │
        │                               ▼
        │                         Update FCM token in Firestore
        │                               │
        │                               ▼
        │                           HomeScreen
        │
        └─ Google Sign-In ──────► GoogleSignIn().signIn()
                                        │
                                        ▼
                                  FirebaseAuth.signInWithCredential()
                                        │
                                        ▼
                                  Upsert user doc in Firestore
                                        │
                                        ▼
                                    HomeScreen
```

**FCM Token Refresh:** The app listens to `FirebaseMessaging.instance.onTokenRefresh` and updates the `fcmToken` field in the user's Firestore document whenever a new token is issued.

---

## 5. Notification System

### Architecture

```
Firebase Cloud Messaging (FCM)
        │
        ▼
notification_service.dart
        │
        ├─ Foreground messages  → flutter_local_notifications (show banner)
        ├─ Background messages  → handled by Firebase SDK
        └─ Notification tap     → navigate to relevant screen
```

### Notification Types

| Type | Trigger | Navigate to |
|------|---------|-------------|
| `release` | New movie added to DB | `MovieDetailScreen` |
| `recommendation` | Personalised suggestion | `MovieDetailScreen` |
| `friend` | Friend activity | `ProfileScreen` |

### Local Notification Setup

```dart
const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
const initSettings = InitializationSettings(android: androidSettings);
await flutterLocalNotificationsPlugin.initialize(initSettings,
    onDidReceiveNotificationResponse: _onNotificationTap);
```

### Firestore Notification Write (on new release)

```dart
await FirebaseFirestore.instance.collection('notifications').add({
  'user_id': targetUserId,
  'type': 'release',
  'title': 'New Release: ${movie.title}',
  'body': 'Now available on MoviHub',
  'is_read': false,
  'movie_id': movie.id,
  'created_at': FieldValue.serverTimestamp(),
});
```

---

## 6. State Management

MoviHub uses **widget-level state only**:

- `setState` — local UI interactions (loading spinners, form inputs, tab selection)
- `StreamBuilder<QuerySnapshot>` — live Firestore collections (home feed, watchlist, notifications)
- `FutureBuilder` — one-time fetches (movie detail)

No external state management package is used by design. If the app scales significantly, migrating the watchlist and auth state to Riverpod or Provider is recommended.

---

## 7. Routing

All routes are defined in `core/routes/app_router.dart`:

```dart
static const String splash        = '/';
static const String login         = '/login';
static const String register      = '/register';
static const String home          = '/home';
static const String movieDetail   = '/movie-detail';
static const String search        = '/search';
static const String watchlist     = '/watchlist';
static const String reviews       = '/reviews';
static const String notifications = '/notifications';
static const String profile       = '/profile';
static const String settings      = '/settings';
```

Arguments are passed via `RouteSettings.arguments` and cast in the target screen's `build` method.

---

## 8. Theming

Defined in `core/theme/app_theme.dart`.

| Token | Light Value | Dark Value |
|-------|------------|-----------|
| Primary | `#E50914` (Netflix red) | `#E50914` |
| Background | `#FFFFFF` | `#141414` |
| Surface | `#F5F5F5` | `#1F1F1F` |
| On-surface | `#212121` | `#E0E0E0` |
| Font family | Poppins | Poppins |

The theme is applied at the `MaterialApp` level and respects the system theme by default. Users can override it in Settings.

---

## 9. Build & Deployment Guide

### Debug Build

```bash
flutter clean
flutter pub get
flutter run
```

### Release APK

```bash
flutter clean
flutter pub get
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Split APKs (smaller download per device)

```bash
flutter build apk --split-per-abi --release
# Outputs: arm64-v8a, armeabi-v7a, x86_64 variants
```

### Versioning

Update `version` in `pubspec.yaml` before each release:

```yaml
version: 2.0.0+2   # format: semver+buildNumber
```

### Checklist Before Release

- [ ] `firebase_options.dart` points to production Firebase project
- [ ] Firestore security rules are deployed and tested
- [ ] FCM server key is configured in Firebase Console
- [ ] `flutter analyze` passes with no errors
- [ ] APK tested on Android 6.0, 10, and 13+
- [ ] `version` and `build number` incremented in `pubspec.yaml`

---

*Documentation last updated: May 2026*
