# 📝 Notes & Task Management

A modern **Flutter** app for notes & task management, fully offline with fast local storage.

## ✨ Core Features

- 🔔 **Smart Reminders** — Instant notifications for tasks with due dates, plus automatic alerts for overdue tasks to keep you on track.
- 🌐 **3 Languages (AR / EN / FR)** — Full multilingual support with seamless RTL/LTR layout switching.
- 📁 **Multi-Format Saving** — Save and organize notes with text and image attachments.
- ⚡ **Hive Local Storage** — Ultra-fast, lightweight, and works **100% offline** (no internet required).
- 🎨 **Modern Flutter UI** — Beautiful, responsive design that adapts to any Android screen size (phones & tablets).

## 🛠️ Tech Stack

| | |
|---|---|
| **Framework** | Flutter (Android) |
| **Database** | Hive DB (local & fast) |
| **Localization** | AR / EN / FR |
| **Notifications** | flutter_local_notifications |

## 📱 Demo & Screenshots

This is the full video of the app:

https://github.com/user-attachments/assets/7480d6fb-9424-43e1-9633-102a03cbdc88

<img width="108" height="240" alt="Screenshot_2026-01-02-21-30-24-684_com example note_app_roocode" src="https://github.com/user-attachments/assets/94ca9033-991e-41d1-aa19-63f90583fdc4" />

<img width="108" height="240" alt="Screenshot_2026-01-02-21-32-56-369_com miui home" src="https://github.com/user-attachments/assets/2e298cb1-5881-423d-b17a-840f4bea5ec8" />

<img width="108" height="240" alt="Screenshot_2026-01-02-21-31-57-435_com example note_app_roocode" src="https://github.com/user-attachments/assets/a208beae-ce48-4011-b03c-8a930098454e" />

<img width="108" height="240" alt="Image" src="https://github.com/user-attachments/assets/c4306217-7eb4-4098-9347-7bc54665a050" />

<img width="108" height="240" alt="Screenshot_2026-01-02-21-31-45-119_com example note_app_roocode" src="https://github.com/user-attachments/assets/dc525fe8-c6ef-4555-85cf-3e1d0d52e514" />

<img width="108" height="240" alt="Screenshot_2026-01-02-21-31-38-139_com example note_app_roocode" src="https://github.com/user-attachments/assets/26def01a-1033-491b-98ca-dda84e64362f" />

<img width="108" height="240" alt="Screenshot_2026-01-02-21-31-27-253_com example note_app_roocode" src="https://github.com/user-attachments/assets/01042e71-5f76-43ec-882c-3fb623522617" />

<img width="108" height="240" alt="Screenshot_2026-01-02-21-31-11-685_com example note_app_roocode" src="https://github.com/user-attachments/assets/41b2fc3b-e442-4742-a4ed-96aa3c1b6e99" />

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) **3.35.0 or newer**
- Dart SDK **3.9.0 or newer** (bundled with Flutter)
- Android Studio (or Android SDK + a connected device/emulator)
- Git

### 1. Clone the repository

```bash
git clone https://github.com/Modern-tech111/notes_and_tasks_management_app.git
cd notes_and_tasks_management_app
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run the app

```bash
flutter run
```

The app will launch on your connected device or emulator. You can also pick a target explicitly:

```bash
flutter devices          # list available devices
flutter run -d <device>  # run on a specific device
```

## 📦 Building a Release

### Signed APK

```bash
flutter build apk --release
```

The signed APK is written to `build/app/outputs/flutter-apk/app-release.apk`.

### App Bundle (AAB) — recommended for Google Play

```bash
flutter build appbundle --release
```

The bundle is written to `build/app/outputs/bundle/release/app-release.aab`.

### Release signing (Android)

Release builds are signed with an upload keystore configured through `android/key.properties`:

```properties
storePassword=<your store password>
keyPassword=<your key password>
keyAlias=<your alias>
storeFile=<path to your .jks keystore>
```

> ⚠️ **Security:** `key.properties` and the keystore file (`.jks`) are **gitignored** — never commit them. They must be copied manually onto any machine where you build a release. If they're missing, the build falls back to the debug key so `flutter run --release` still works for local testing.

### Tests

```bash
flutter test
```

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point, Hive & notifications setup
├── models/                   # Note & Task Hive models
├── screens/                  # Splash, Home, Notes, Tasks, Settings, Add/Edit screens
├── generated/                # Auto-generated localization files (AR/EN/FR)
└── l10n/                     # ARB translation sources
android/                      # Android host project (application ID: com.moderntech.notes_tasks)
ios/                          # iOS host project
```

Localization sources live in `lib/l10n/` (configured via `l10n.yaml`). After editing the ARB files, regenerate the Dart bindings with:

```bash
flutter gen-l10n
```

## 🧪 App Details

- **Application ID (Android):** `com.moderntech.notes_tasks`
- **Version:** 1.0.0+1
- **Languages:** العربية (AR) · English (EN) · Français (FR)
