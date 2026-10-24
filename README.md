# Clever Typing Application

Android-first AI keyboard product built with a Flutter host app and a native Android IME.

## Current Status

This repository currently contains:

- product planning documents under `docs/`
- the initial Flutter application structure
- the first onboarding and home app shell
- Android method-channel integration for keyboard settings and status
- a native Android keyboard service with a minimal input surface under `android/keyboard/`
- remote AI service contracts for grammar correction, translation, and smart reply

## Architecture

- Flutter owns onboarding, settings, account, assistants, subscription, and privacy flows.
- Native Android owns the keyboard service and per-keystroke input behavior.
- The app follows feature-first clean architecture.

## Project Layout

```text
lib/
  app/
  core/
  features/
android/
  keyboard/
docs/
test/
```

## Local Setup

1. Install a Flutter SDK compatible with the version constraint in `pubspec.yaml`.
2. Run `flutter pub get`.
3. Supply AI configuration:
   `flutter run --dart-define=AI_BASE_URL=https://your-api.example.com --dart-define=AI_API_KEY=your-token`
4. Run `flutter run`.

The Flutter host app syncs these backend settings to native Android so the IME can use the same live AI endpoints for grammar correction and translation actions.

## Next Steps

- Build the Android app project shell and Gradle configuration if it does not already exist locally.
- Complete Android Gradle wiring for the native IME and host app modules.
- Replace static assistant gallery content with persisted and backend-sourced assistants.
- Connect keyboard-side AI actions directly to the same backend-backed repository flows.
