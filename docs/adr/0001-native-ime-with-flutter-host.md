# ADR 0001: Use Native Android IME with Flutter Host App

## Status

Accepted

## Context

The product must deliver a full Android keyboard with AI-assisted writing features. The user asked for Flutter, but Android keyboards are implemented through `InputMethodService`, which has strict lifecycle, rendering, and latency requirements.

A pure Flutter implementation would force the keyboard surface through a runtime that is not the natural owner of the Android IME lifecycle. That increases risk around startup performance, memory pressure, input correctness, and OEM compatibility.

## Decision

Adopt a hybrid architecture:

- Build the installable Android application in Flutter
- Build the actual keyboard service as a native Android IME
- Share business contracts through clean architecture and a narrow bridge
- Use Flutter for:
  - onboarding
  - account
  - paywall
  - settings
  - assistant management
  - privacy/data controls
- Use native Android for:
  - key rendering
  - input handling
  - text commit/delete/select
  - suggestion strip responsiveness
  - IME lifecycle

## Consequences

### Positive

- Lower input latency
- Better compliance with Android IME expectations
- Cleaner handling of selection, composing text, and editor actions
- Reduced risk in production

### Negative

- Two implementation surfaces instead of one
- More bridge code between native and Flutter
- More testing effort

## Rejected Alternatives

### Pure Flutter IME

Rejected because the keyboard is the most latency-sensitive part of the product and should not depend on a general-purpose cross-platform rendering path.

### Fully Native Android App

Rejected because Flutter is still a good fit for the companion app, settings, onboarding, paywall, and reusable domain layer.

## Implementation Notes

- Use `Pigeon` or a disciplined `MethodChannel` interface
- Keep per-keystroke logic native
- Route AI requests through repository/use-case boundaries, not ad hoc bridge calls
- Store fast-read keyboard preferences in native-accessible storage
