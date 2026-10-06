# GymTrack

GymTrack is an offline-first Flutter app for managing workout plans, recording
sets, reviewing workout history, and tracking strength and body measurements.
Workout and measurement data are stored locally in SQLite through Drift.

## Requirements

- Flutter SDK compatible with the Dart constraint in `pubspec.yaml`
- Android SDK for Android builds

## Run locally

```sh
flutter pub get
flutter run
```

The app seeds its exercise library and starter plan only when the local database
is empty. No account or backend is required for core features.

## Tests and analysis

```sh
flutter analyze
flutter test
```

Integration tests can be run on a connected device or emulator with:

```sh
flutter test integration_test
```

## Build Android APK

```sh
flutter build apk --release
```

The APK is written to `build/app/outputs/flutter-apk/app-release.apk`.

## Data backup

Use Settings to export a JSON backup and import it on another installation.
Keep a copy of the backup outside the app's local storage if you plan to change
or reset devices.
