# RUN Guide

This document explains how to set up, run, build, and use the Clever Typing Application on Windows for Android development.

Last verified: July 25, 2026

## What This Project Is

This repository contains two connected parts:

- A Flutter host app for onboarding, settings, assistants, privacy, subscription, and AI feature screens
- A native Android keyboard (IME) module for actual typing, suggestions, clipboard, smart reply, translation, and keyboard-side AI actions

You need both the Flutter SDK and the Android SDK to run and build it.

## Prerequisites

Install and configure the following:

- Flutter SDK
- Android SDK
- Android Studio
  Android Studio is recommended for SDK management and emulator setup
- VS Code or Android Studio as your editor

## Verified Toolchain State

The project was runtime-verified with:

- Flutter 3.44.7
- Dart 3.12.2
- Android SDK 36.0.0
- Build target: Android debug APK

## Required Environment Setup

### 1. Check Flutter

Run:

```powershell
flutter doctor -v
```

Expected:

- Flutter installed and healthy
- Android toolchain available
- Android licenses accepted

If Android SDK is missing, configure it:

```powershell
flutter config --android-sdk "C:\Users\<YOUR_USERNAME>\AppData\Local\Android\Sdk"
flutter doctor --android-licenses
flutter doctor -v
```

### 2. Install Dependencies

From the project root:

```powershell
flutter pub get
```

## Project Verification Commands

These commands were used successfully for verification:

```powershell
flutter analyze
flutter test
flutter build apk --debug
```

Generated debug APK:

```text
build\app\outputs\flutter-apk\app-debug.apk
```

## Run Commands

### Option A: Run on Android Emulator or Device

Start an emulator from Android Studio Device Manager or connect a physical Android device with USB debugging enabled.

Then run:

```powershell
flutter devices
flutter run
```

If multiple devices are shown:

```powershell
flutter run -d <DEVICE_ID>
```

## Run on Android Emulator

### 1. Create an Emulator

Using Android Studio:

1. Open Android Studio
2. Open `Device Manager`
3. Click `Create device`
4. Choose a phone profile such as `Pixel`
5. Select a recent Android system image
6. Finish the wizard

### 2. Start the Emulator

From Android Studio:

1. Open `Device Manager`
2. Click the play button for the emulator

Or from command line, after the Android SDK is configured:

```powershell
flutter emulators
flutter emulators --launch <EMULATOR_ID>
```

### 3. Confirm the Emulator Is Visible

Run:

```powershell
flutter devices
```

You should see the emulator listed.

### 4. Run the App on the Emulator

Run:

```powershell
flutter run -d <EMULATOR_ID>
```

If there is only one Android device/emulator attached:

```powershell
flutter run
```

### 5. Build and Install Debug APK on the Emulator

If you already built the APK:

```powershell
adb install -r build\app\outputs\flutter-apk\app-debug.apk
```

## Run on a Physical Android Phone

### 1. Enable Developer Options

On the Android phone:

1. Open `Settings`
2. Open `About phone`
3. Tap `Build number` multiple times until developer mode is enabled

### 2. Enable USB Debugging

On the Android phone:

1. Open `Settings`
2. Open `Developer options`
3. Enable `USB debugging`

### 3. Connect the Phone to Windows

Use a USB cable that supports data transfer, not power-only charging.

When prompted on the phone:

1. Allow USB debugging
2. Trust the connected computer

### 4. Verify That Flutter Can See the Phone

Run:

```powershell
adb devices
flutter devices
```

If the device shows as unauthorized:

1. Reconnect the phone
2. Accept the RSA debugging prompt on the phone
3. Run `adb devices` again

### 5. Run the App on the Phone

Run:

```powershell
flutter run -d <PHONE_DEVICE_ID>
```

If only one device is attached:

```powershell
flutter run
```

### 6. Install a Built APK on the Phone

After building:

```powershell
adb install -r build\app\outputs\flutter-apk\app-debug.apk
```

If an older build is already installed, `-r` replaces it.

### Option B: Build APK Without Launching

Debug APK:

```powershell
flutter build apk --debug
```

Release APK:

```powershell
flutter build apk --release
```

### Option C: Install Built APK Manually

After building:

```powershell
adb install -r build\app\outputs\flutter-apk\app-debug.apk
```

## Clean Rebuild Commands

Use these if Gradle or plugin caches become unstable:

```powershell
flutter clean
flutter pub get
flutter build apk --debug
```

## Important Build Note

The project currently disables Kotlin incremental compilation in:

[`android/gradle.properties`](E:/Workspace-Codex/Clever%20Typing%20Application/android/gradle.properties)

This was required to avoid Kotlin daemon cache failures during Android compilation on this machine.

## First-Time App Setup on Android

After the app installs:

1. Open the Clever Typing app
2. Complete onboarding
3. Open keyboard settings from inside the app
4. Enable the Clever Typing keyboard in Android input settings
5. Open the input method picker
6. Switch the active keyboard to Clever Typing

## How to Enable the Keyboard Manually

On Android:

1. Open `Settings`
2. Go to `System`
3. Go to `Languages & input`
4. Open `On-screen keyboard`
5. Open `Manage on-screen keyboards`
6. Enable `Clever Typing`
7. Return to any text field
8. Open the keyboard picker
9. Select `Clever Typing`

Exact menu names may vary slightly by Android version and device brand.

## App User Guide

### Home Screen

The home screen provides entry points to:

- AI writing tools
- Grammar correction
- Translation
- Assistant gallery
- Smart reply
- Keyboard settings
- Subscription
- Privacy dashboard

### Grammar Correction

Use this when you want to correct grammar and punctuation before sending text.

How to use:

1. Open `Grammar correction`
2. Enter text
3. Tap `Correct grammar`
4. Review the corrected output

### Translation

Use this to translate text while preserving tone.

How to use:

1. Open `Translation`
2. Select source language or leave `Auto Detect`
3. Select target language
4. Choose whether to preserve tone
5. Enter the input text
6. Tap `Translate`
7. Review translated output and detected source language

### AI Writing Tools

Available writing tools include:

- Grammar correction
- Tone rewrite
- Paraphrase
- Shorten
- Expand
- Simplify
- Humanize
- Summarize
- Caption generation
- Email draft

How to use:

1. Open `AI writing tools`
2. Choose the tool
3. Choose tone if relevant
4. Toggle tone preservation if needed
5. Enter text
6. Tap `Run writing tool`
7. Review output and any summary bullets

### Assistant Gallery

This screen supports:

- Backend-driven assistant catalog
- Custom assistant creation
- Assistant editing and deletion
- Pinning one assistant for quick IME use

How to use:

1. Open `Assistant gallery`
2. Tap `+` to create a custom assistant
3. Fill in:
   - name
   - description
   - intent
   - prompt template
4. Save the assistant
5. Use `Pin` to make one assistant available from the keyboard toolbar
6. Use `Edit` or `Delete` for custom assistants
7. Tap `Run assistant` to execute an assistant on input text

### Smart Reply

Smart reply can use accessibility-based conversation capture.

How to use:

1. Open `Smart reply`
2. Tap `Open accessibility settings`
3. Enable the conversation capture service
4. Return to the app
5. Tap `Refresh captured context`
6. Select a reply variant:
   - Short
   - Friendly
   - Professional
   - Positive
7. Tap `Generate replies`
8. Review the suggestions

### Keyboard Settings

This screen controls settings that are synced to the native IME.

Available controls:

- Auto-capitalization
- Auto-space
- Haptic feedback
- Sound feedback
- One-handed mode
- Keyboard height
- Theme palette
- Primary language
- Secondary language
- Incognito mode

How to use:

1. Open `Keyboard settings`
2. Adjust the desired preferences
3. Preferences are persisted and synced to the keyboard

### Privacy Dashboard

This screen shows:

- Native keyboard privacy status
- Accessibility state
- Incognito state
- Sensitive-field block counts
- Native AI execution/failure counts
- Usage history
- Consent log
- Export and delete data actions

How to use:

1. Open `Privacy dashboard`
2. Review live status
3. Use `Export data` to inspect stored privacy and usage data
4. Use `Delete local data` to clear local history, consents, settings cache, and native counters

### Subscription

Use this screen to review plan state and quota-related product flow.

## Native Keyboard User Guide

### Keyboard Core Features

The native keyboard currently includes:

- Letter, number, symbol, and emoji layouts
- Suggestion strip
- Local autocorrect heuristics
- Next-word prediction
- Shift and caps-lock behavior
- Cursor left/right movement
- Clipboard history panel
- One-handed layout behavior
- Theme application from synced settings
- Swipe typing heuristic

### Native Keyboard AI Actions

The keyboard toolbar exposes actions such as:

- Fix
- Translate
- Reply
- Assist
- Rewrite
- Para
- Summ
- Email
- Caption

### How to Use Keyboard AI Actions

General flow:

1. Open any Android text field
2. Select text or place the cursor near the text
3. Use one of the AI action buttons
4. The keyboard sends the request to the configured backend
5. The result is inserted or replaces the selected text depending on the flow

### Smart Reply in the Keyboard

How to use:

1. Enable accessibility capture in the app first
2. Open a conversation in another app
3. Open the Clever Typing keyboard
4. Tap `Reply`
5. Tap one of the reply chips to insert it

### Assistant from the Keyboard

How to use:

1. In the app, pin an assistant in the assistant gallery
2. Open the keyboard in any text field
3. Select text or place the cursor near the text
4. Tap `Assist`
5. The pinned assistant runs and inserts output

### Translation from the Keyboard

How to use:

1. Set your preferred secondary language in `Keyboard settings`
2. Select text or place the cursor near it
3. Tap `Translate`
4. The keyboard translates into the configured secondary language

### Sensitive Field Protection

AI actions are blocked in sensitive contexts such as:

- password fields
- OTP fields
- payment/card-related fields
- PIN/passcode style fields

When blocked:

- the keyboard does not execute the AI action
- the privacy dashboard counter increases

### Incognito Mode

When enabled in keyboard settings:

- the keyboard indicates incognito mode in status text
- privacy-sensitive history behavior is reduced

## Known Warnings

The project currently builds successfully, but Flutter warns that:

- the app module applies the Kotlin Gradle Plugin directly
- the local `keyboard` module also applies KGP directly

This should be migrated to Built-in Kotlin in a future cleanup pass.

## Troubleshooting

### Android SDK Not Found

Run:

```powershell
flutter doctor -v
flutter config --android-sdk "C:\Users\<YOUR_USERNAME>\AppData\Local\Android\Sdk"
```

### Licenses Not Accepted

Run:

```powershell
flutter doctor --android-licenses
```

### Kotlin or Gradle Cache Failure

Run:

```powershell
flutter clean
flutter pub get
flutter build apk --debug
```

### Device Not Visible

Run:

```powershell
adb devices
flutter devices
```

### App Installs But Keyboard Does Not Show

Check:

1. The keyboard is enabled in Android settings
2. Clever Typing is selected as the active input method
3. You are tapping into a normal text field

## Recommended Daily Workflow

From the repo root:

```powershell
flutter pub get
flutter analyze
flutter test
flutter run
```

Before sharing a build:

```powershell
flutter build apk --debug
```

For release validation:

```powershell
flutter build apk --release
```
