# AI Keyboard App Blueprint

## Objective

Design an Android-first Flutter application that matches the core feature set of CleverType and similar AI keyboard products while staying maintainable, scalable, and Play Store ready.

This document defines the product scope, UX flows, architecture, Android integration strategy, and delivery phases.

## Product Positioning

The app is an AI-assisted Android keyboard that helps users write faster and better inside any text field. It combines:

- Fast, reliable keyboard input
- Grammar and spelling correction
- Tone rewrite and paraphrasing
- Translation
- Context-aware smart replies
- AI assistants and custom prompts
- Personalization, privacy, and subscription support

## Assumptions

- Target platform is Android only.
- The host application is built in Flutter.
- The keyboard service must behave like a native Android IME for latency, lifecycle, and OS compatibility.
- AI-heavy features depend on a backend service or hosted LLM APIs.
- Offline typing must still work even if AI features are unavailable.

## Feature Set

### 1. Core Keyboard

- QWERTY keyboard with letters, numbers, symbols, emoji access
- Autocorrect and next-word suggestions
- Caps, shift lock, backspace, enter, space, language switch
- Cursor movement and text selection helpers
- Clipboard shortcuts
- Haptic and sound feedback controls
- One-handed mode
- Adjustable keyboard height
- Theme selection

### 2. AI Writing Tools

- Grammar correction for selected text or current sentence
- Spelling and punctuation fixes
- Rephrase/paraphrase
- Tone rewriting
- Length transforms: shorten, expand, simplify
- Humanize text
- Emoji insertion or phrase-to-emoji
- Summarize text
- Generate captions, replies, email drafts, and polished messages
- Freeform AI chat from the keyboard

### 3. Smart Reply

- Read the latest visible conversation context after explicit user opt-in
- Generate reply variants:
  - Neutral
  - Positive
  - Friendly
  - Professional
  - Short
- Expand a user-written rough draft into a polished response

### 4. Translation

- Translate typed text into target language
- Preserve intent and tone where possible
- Language detection
- Quick language picker

### 5. Custom AI Assistants

- Built-in prompt templates:
  - Grammar Fix
  - Professional Rewrite
  - Friendly Reply
  - Summarizer
  - Social Caption
  - Email Assistant
  - Brainstorm
- User-defined assistants with:
  - Name
  - Prompt instructions
  - Output style
  - Optional target length

### 6. Accounts, Billing, and Usage

- Email/Google sign-in
- Anonymous guest mode for basic keyboard usage
- Free tier with daily AI quota
- Premium subscription for unlimited or higher-volume AI usage
- Usage dashboard
- Restore purchases

### 7. Privacy and Safety

- Clear disclosure for keyboard data handling
- Explicit consent before enabling AI processing of typed text
- Explicit consent before enabling accessibility-assisted smart reply
- Incognito mode to disable learning/history
- Sensitive field detection:
  - Password
  - Payment
  - OTP
- Never send sensitive field content to AI services
- Delete account and data export flows

### 8. Settings and Personalization

- Theme and color presets
- Key border and roundness
- Suggestion strip toggles
- Auto-capitalization
- Auto-space after punctuation
- Swipe typing toggle
- Haptic/sound toggle
- Language preferences
- AI default tone
- Custom shortcut row

## Feature Mapping to CleverType

Based on public CleverType product pages and app listings, the competitor surface includes:

- Grammar correction
- Tone change/paraphrasing
- AI translation
- Smart reply
- ChatGPT access
- 20+ to 30+ AI assistants
- Custom assistants
- Theme customization
- Privacy messaging

This design covers all of those categories and adds production-grade Android handling for performance, permissions, and reliability.

## User Personas

### Professional Writer

- Needs grammar fixes, professional tone, fast email replies

### Student

- Needs rewrite, summarize, translate, and humanize tools

### Social User

- Needs witty tone, captions, emoji tools, and fast chat replies

### Multilingual User

- Needs translation and language-aware rewriting

## Primary User Flows

### Onboarding

1. Launch app
2. See product value and privacy explanation
3. Sign in or continue as guest
4. Enable keyboard in Android settings
5. Switch default input method to this keyboard
6. Optional: enable accessibility for smart reply
7. Choose theme and default language
8. Land on dashboard

### Typing Flow

1. User types in any app
2. Native IME renders keyboard instantly
3. Suggestions and autocorrect operate locally
4. User opens AI toolbar
5. User selects text transformation tool
6. Selected/current text is sent to AI only after explicit action
7. Result appears in bottom sheet
8. User inserts or replaces text

### Smart Reply Flow

1. User opens smart reply tool
2. App reads recent visible conversation context if permission granted
3. Backend generates reply options
4. User taps reply to insert

### Custom Assistant Flow

1. User opens assistant gallery
2. Chooses built-in assistant or creates new one
3. Writes instructions and save
4. Assistant appears in keyboard toolbar

## Screen Inventory

### Flutter Host App

- Splash
- Welcome / value proposition
- Sign-in / create account
- Keyboard enable guide
- Keyboard select guide
- Accessibility opt-in guide
- Home dashboard
- Assistant gallery
- Custom assistant editor
- Theme/customization
- Subscription/paywall
- Usage history
- Account/privacy/data controls
- Settings
- Help/FAQ

### Keyboard Surface

- Main key layout
- Suggestion strip
- AI toolbar
- Tool bottom sheet
- Result preview sheet
- Emoji/symbol panel
- Clipboard panel

## Recommended Architecture

### High-Level Decision

Use a hybrid architecture:

- Native Android layer owns the `InputMethodService`
- Flutter owns the host app UI, business flows, and most domain logic
- Shared service contracts isolate AI, billing, auth, analytics, and settings

This is the safer production choice because Android IMEs are latency-sensitive and heavily tied to native OS lifecycle APIs.

### Clean Architecture Layers

#### Presentation

- Flutter screens
- Riverpod notifiers
- UI state/effect models
- Native keyboard view controllers on Android side

#### Domain

- Use cases for:
  - CorrectText
  - RewriteText
  - TranslateText
  - GenerateReply
  - ExecuteAssistant
  - SaveCustomAssistant
  - GetKeyboardPreferences
  - UpdateKeyboardPreferences
  - TrackUsage

#### Data

- Repository implementations
- DTO mappers
- Local/remote data source coordination

#### Platform

- Android IME service
- Accessibility integration
- Billing client
- Secure storage
- MethodChannel / Pigeon bridge

## Proposed Project Structure

```text
lib/
  app/
    app.dart
    bootstrap.dart
    router/
    theme/
  core/
    constants/
    di/
    errors/
    logging/
    networking/
    storage/
    widgets/
  features/
    onboarding/
      data/
      domain/
      presentation/
      providers/
    authentication/
      data/
      domain/
      presentation/
      providers/
    keyboard_settings/
      data/
      domain/
      presentation/
      providers/
    assistants/
      data/
      domain/
      presentation/
      providers/
    rewriting/
      data/
      domain/
      presentation/
      providers/
    translation/
      data/
      domain/
      presentation/
      providers/
    smart_reply/
      data/
      domain/
      presentation/
      providers/
    subscription/
      data/
      domain/
      presentation/
      providers/
    privacy/
      data/
      domain/
      presentation/
      providers/
android/
  app/
  keyboard/
    src/main/kotlin/.../
      ime/
      suggestion/
      bridge/
      accessibility/
      theme/
test/
integration_test/
docs/
  adr/
```

## Android Components

### Native Components

- `InputMethodService` for keyboard lifecycle
- Custom keyboard view / Compose view for rendering keys and suggestion row
- `AccessibilityService` for optional smart reply context capture
- `BroadcastReceiver` or app callbacks for settings sync
- Billing integration
- Secure preferences bridge

### Flutter-to-Native Bridge

Use `Pigeon` or tightly defined `MethodChannel` APIs for:

- Fetching keyboard preferences
- Updating theme/layout
- Requesting AI actions
- Sending usage events
- Reading capability states

Keep the bridge narrow. Do not push per-keystroke rendering through Flutter.

## Data Architecture

### Local Storage

- Drift for structured local data:
  - custom assistants
  - AI history
  - usage counters
  - feature flags cache
- `flutter_secure_storage` for tokens and secrets
- SharedPreferences/DataStore bridge for fast native keyboard settings

### Backend Services

- Auth service
- Subscription/entitlement service
- AI orchestration service
- Prompt template service
- Analytics and remote config

### AI Gateway Responsibilities

- Model routing by task type
- Prompt templating
- Token/usage accounting
- Rate limiting
- Sensitive-content filtering
- Retry policy
- Observability

## AI Capability Design

### Local vs Remote Split

Local:

- Autocorrect
- Suggestions
- Basic spell heuristics
- Keyboard personalization

Remote:

- Grammar rewrite
- Tone transformation
- Translation
- Smart reply
- Custom assistant execution
- Chat

### Prompting Model

Each AI action should be a typed use case with a typed request and response model. Do not expose raw prompt strings above the data layer.

Example actions:

- `FixGrammarRequest`
- `RewriteToneRequest`
- `TranslateRequest`
- `GenerateReplyRequest`
- `RunAssistantRequest`

## Permissions Strategy

### Required

- Keyboard service permission through Android input method enablement
- Network access

### Optional

- Accessibility service for smart reply context
- Notification permission only if product later adds proactive notifications

Avoid any extra permissions unless directly justified by a user-facing feature.

## Privacy Model

- On-device typing is default
- AI processing happens only when user invokes an AI action
- Sensitive input fields bypass AI entirely
- Accessibility-based context capture is opt-in and revocable
- Provide a visible privacy dashboard:
  - AI requests count
  - last processing time
  - delete history
  - export/delete account

## Performance Requirements

- Keyboard first paint under 100 ms on warm start
- Standard key tap latency under 20 ms perceived delay
- AI result placeholder shown under 150 ms
- Cancelable in-flight AI requests
- Debounced network requests
- Aggressive caching of templates/config

## Error and Offline States

- Keyboard remains usable without internet
- AI toolbar shows offline state instead of failing silently
- Failed AI request returns actionable message
- Smart reply unavailable when accessibility permission is off
- Premium-only tool usage routes to paywall gracefully

## Logging and Observability

- Central logging abstraction
- Correlation ID per AI request
- Track:
  - keyboard opened
  - AI tool invoked
  - AI success/failure/latency
  - smart reply permission state
  - paywall conversion funnel

Never log raw typed text, secrets, OTPs, or passwords.

## Monetization

- Free:
  - keyboard
  - basic autocorrect
  - limited AI actions per day
- Premium:
  - unlimited or higher quota
  - advanced assistants
  - custom assistants
  - smart reply
  - premium themes

## Release Plan

### Phase 1: Foundation

- Flutter host app
- Native Android IME shell
- Onboarding
- Settings sync
- Basic keyboard
- Auth

### Phase 2: Core AI

- Grammar fix
- Tone rewrite
- Translation
- Assistant gallery
- Subscription

### Phase 3: Advanced AI

- Smart reply via accessibility
- Custom assistants
- Chat
- AI history and usage analytics

### Phase 4: Polish

- Theme system
- Performance tuning
- A/B testing hooks
- Crash reporting hardening
- Play Store compliance assets

## Testing Strategy

### Unit Tests

- Use cases
- notifiers
- repositories

### Widget Tests

- onboarding
- assistant gallery
- settings
- paywall

### Android Instrumentation Tests

- IME enablement flow
- keyboard rendering
- text commit/delete behavior
- selection replace flow

### Integration Tests

- sign-in to keyboard activation
- grammar rewrite insertion
- subscription unlock
- smart reply happy path

## Technical Risks

### 1. Pure Flutter Keyboard Rendering

Risk:
Flutter-only keyboard rendering inside `InputMethodService` can create latency, lifecycle, and memory issues.

Mitigation:
Keep the IME shell native.

### 2. Accessibility Permission Sensitivity

Risk:
Users may distrust or decline smart reply permissions.

Mitigation:
Make smart reply optional and explain exactly what is read and when.

### 3. AI Cost Explosion

Risk:
Heavy rewrite and chat usage can make margins negative.

Mitigation:
Task-specific model routing, quotas, caching, and subscription gating.

### 4. Privacy/Store Review Risk

Risk:
Keyboard apps are reviewed aggressively due to sensitive input access.

Mitigation:
Clear disclosures, sensitive field exclusion, data minimization, and strong privacy copy.

## Recommended Initial MVP

Ship this first:

- Native Android keyboard
- Flutter onboarding and settings app
- Grammar fix
- Tone rewrite
- Translation
- Built-in assistants
- Theme customization
- Sign-in and subscription

Delay until later:

- Accessibility smart reply
- Full chat experience
- swipe typing
- multilingual offline language packs

## Success Metrics

- Keyboard activation rate
- Day-1 and Day-7 retention
- AI tool usage per active user
- grammar fix to insert conversion
- paywall conversion
- crash-free sessions
- median AI latency

## Summary

The correct production design is not a pure Flutter keyboard. It is a Flutter Android app paired with a native Android IME and a narrowly scoped platform bridge. That approach supports CleverType-like AI features while meeting Android performance, privacy, and lifecycle constraints.
