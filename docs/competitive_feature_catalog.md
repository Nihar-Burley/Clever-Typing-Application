# Competitive Feature Catalog

## Product Goal and Competitor Target

Build an Android-first AI keyboard product that reaches competitive parity with CleverType and similar AI keyboard applications, then exceeds them on Android performance, trust, and workflow depth.

The product must:

- Match the expected AI keyboard baseline:
  - grammar correction
  - tone rewrite and paraphrasing
  - translation
  - AI assistants
  - smart reply
  - keyboard customization
  - subscription-backed premium AI usage
- Preserve the architecture already chosen for this repo:
  - Flutter host app for onboarding, account, settings, subscription, assistants, and privacy
  - Native Android `InputMethodService` for the keyboard surface and per-keystroke behavior
- Stay Android-only and Play Store ready

Status labels used in this file:

- `MVP`: required for first competitive launch
- `V2`: planned after launch to close gaps or deepen usage
- `Future`: valuable, but not required for near-term competitiveness
- `Differentiator`: should set the product apart from existing AI keyboard apps

## Competitive Parity Features

### Keyboard Core

- `MVP` Native Android IME with stable text input, delete, shift, enter, and cursor handling
- `MVP` QWERTY layout with letters, numbers, and symbol modes
- `MVP` Suggestion strip for local next-word and correction suggestions
- `MVP` Autocorrect and basic spell correction while typing
- `MVP` Emoji picker
- `MVP` Clipboard shortcuts panel
- `MVP` Keyboard height adjustment
- `MVP` Haptic feedback toggle
- `MVP` Sound feedback toggle
- `MVP` One-handed mode
- `V2` Swipe typing
- `V2` Advanced cursor control and text selection helpers
- `V2` Shortcut row customization

### AI Writing Tools

- `MVP` Grammar correction for selected text or current sentence
- `MVP` Spelling and punctuation cleanup
- `MVP` Rephrase/paraphrase action
- `MVP` Tone rewrite with preset tones:
  - professional
  - casual
  - polite
  - friendly
  - formal
- `MVP` Length transforms:
  - shorten
  - expand
  - simplify
- `MVP` Replace-or-insert result flow from keyboard sheet
- `V2` Humanize text transformation
- `V2` Summarize text
- `V2` Generate captions, emails, and polished messages
- `Future` Phrase-to-emoji conversion
- `Future` Emojify transformation

### Smart Reply

- `V2` Context-aware AI reply suggestions for chat and email style conversations
- `V2` Reply variants:
  - short
  - neutral
  - friendly
  - professional
  - positive
- `V2` Expand rough user draft into polished reply
- `V2` Accessibility-permission onboarding for reading recent visible conversation context

### Translation and Multilingual Support

- `MVP` Translate selected or typed text into a target language
- `MVP` Language picker for translation target
- `MVP` Tone-preserving translation where supported by the AI backend
- `V2` Auto-detect source language
- `V2` Multilingual rewriting support across major launch languages
- `Future` Offline language packs for limited local translation/rewrite support

### Custom Assistants and Prompt Tools

- `MVP` Built-in assistant gallery for common writing tasks
- `MVP` Built-in assistants:
  - grammar fix
  - professional rewrite
  - friendly reply
  - summarizer
  - social caption
  - email assistant
- `V2` User-created custom assistants with saved instructions
- `V2` Assistant pinning to keyboard toolbar
- `Future` Assistant import/export across devices

### Personalization and Themes

- `MVP` Theme presets
- `MVP` Color customization
- `MVP` Key shape and border styling
- `MVP` Suggestion strip visibility toggle
- `MVP` Auto-capitalization toggle
- `MVP` Auto-space after punctuation toggle
- `MVP` Default AI tone preference
- `V2` Premium theme packs
- `Future` Dynamic wallpaper or adaptive themes

### Account, Sync, and Subscription

- `MVP` Guest mode for basic keyboard use
- `MVP` Sign in with email
- `MVP` Sign in with Google
- `MVP` Free tier with daily AI quota
- `MVP` Premium subscription for expanded or unlimited AI usage
- `MVP` Restore purchases
- `MVP` Local usage counter display
- `V2` Cross-device sync for assistants and preferences
- `V2` Usage history view

### Privacy, Security, and Compliance

- `MVP` Keyboard privacy disclosure during onboarding
- `MVP` Explicit consent before any AI processing of typed or selected text
- `MVP` Sensitive field detection for password, payment, and OTP contexts
- `MVP` Block AI processing in sensitive fields
- `MVP` Secure token storage
- `MVP` Encrypted transport for all remote requests
- `MVP` Clear data deletion flow
- `V2` Privacy dashboard with AI request history summary
- `V2` Data export flow
- `Future` Incognito mode that disables learning/history across sessions

## Differentiator Features

### Performance and Reliability

- `Differentiator` Fast warm keyboard open time tuned for under-100 ms first paint
- `Differentiator` Local-first typing that remains fully usable when AI services are offline
- `Differentiator` Cancelable AI actions with graceful fallback and visible retry states
- `Differentiator` Narrow native-to-Flutter bridge so AI features do not block keyboard responsiveness
- `Differentiator` Optimized Android OEM compatibility testing for common device vendors

### Trust and User Control

- `Differentiator` Privacy dashboard showing what AI can access and when it was last used
- `Differentiator` Permission education screens that explain smart reply access clearly before Android prompts
- `Differentiator` Explicit “send to AI” action model rather than background text capture
- `Differentiator` Sensitive-content-safe defaults with no AI processing in protected input contexts

### Workflow Depth

- `Differentiator` Result preview sheet that lets the user compare original and rewritten text before insert
- `Differentiator` Assistant toolbar with task-focused shortcuts instead of generic chat-first UI
- `Differentiator` Draft expansion flow for turning rough notes into polished chat or email responses
- `Differentiator` User-configurable default tone and preferred assistant shortcuts

### Product Operations

- `Differentiator` AI model routing by task type to control cost and latency
- `Differentiator` Usage-based entitlement controls that allow a viable free tier without degrading core typing
- `Differentiator` Crash, latency, and AI success instrumentation designed specifically for keyboard flows

## MVP Features

### Launch-Critical User Features

- `MVP` Native Android keyboard with reliable text input lifecycle
- `MVP` Core key layouts, suggestion strip, autocorrect, emoji, and clipboard panel
- `MVP` Grammar correction
- `MVP` Rephrase and tone rewrite
- `MVP` Translation
- `MVP` Built-in AI assistant gallery
- `MVP` Theme and keyboard customization basics
- `MVP` Guest mode, email/Google sign-in, free quota, and premium subscription
- `MVP` Privacy disclosures and sensitive-field protections

### Launch-Critical App Flows

- `MVP` Onboarding that explains product value and privacy
- `MVP` Enable-keyboard guide
- `MVP` Switch-keyboard guide
- `MVP` Settings app for preferences, themes, and AI defaults
- `MVP` Subscription/paywall flow
- `MVP` Account management flow
- `MVP` Help and FAQ surface

### Launch-Critical Product Infrastructure

- `MVP` AI orchestration service for grammar, rewrite, translation, and assistants
- `MVP` Authentication backend integration
- `MVP` Billing integration and entitlement checks
- `MVP` Remote config for quotas, assistant availability, and feature flags
- `MVP` Structured logging and crash reporting

## Post-MVP Features

### V2 Expansion

- `V2` Smart reply with accessibility-assisted context capture
- `V2` Custom assistants with saved prompts
- `V2` Advanced reply and message generation tools
- `V2` Usage history and privacy dashboard
- `V2` Cross-device sync
- `V2` Swipe typing
- `V2` Advanced cursor and selection tools
- `V2` Premium theme packs
- `V2` Multilingual rewrite expansion

### Future Expansion

- `Future` Full AI chat experience inside the keyboard
- `Future` Offline language packs
- `Future` Assistant marketplace or template library
- `Future` Voice input enhancement with AI rewrite
- `Future` Team or enterprise policy controls
- `Future` Shared assistant presets

## Platform, Backend, Trust, and Monetization Features

### Platform and Android Integration

- `MVP` Native `InputMethodService` implementation for the keyboard
- `MVP` Flutter host app for companion flows
- `MVP` Native-accessible settings storage for low-latency keyboard reads
- `MVP` Controlled bridge between Flutter and native Android for preferences and AI actions
- `V2` Accessibility service integration for smart reply
- `Future` WorkManager-driven background sync for non-interactive product tasks

### Backend and AI Orchestration

- `MVP` Task-specific AI endpoints or orchestration paths
- `MVP` Prompt templates managed outside the keyboard UI
- `MVP` Rate limiting and quota enforcement
- `MVP` Usage accounting by user and feature
- `MVP` Failure mapping for offline, timeout, auth, and subscription errors
- `V2` Model routing by latency/cost/quality profile
- `V2` Experiment flags for assistant ordering and quota tuning

### Security and Compliance

- `MVP` No storage of secrets in repo or insecure app storage
- `MVP` Secure storage for auth tokens and sensitive settings
- `MVP` Play Store-compliant permission disclosures
- `MVP` Data safety documentation aligned with actual product behavior
- `V2` Account deletion request workflow
- `V2` Exportable privacy controls

### Monetization and Retention

- `MVP` Free tier quota rules
- `MVP` Premium entitlement gating
- `MVP` Paywall with clear value breakdown
- `MVP` Subscription restore flow
- `V2` Trial or introductory offer support
- `V2` Retention nudges tied to useful assistant discovery
- `Future` Referral program or invite-based growth hooks

### Analytics, Support, and Growth

- `MVP` Event tracking for onboarding completion, keyboard activation, and AI tool invocation
- `MVP` Error tracking for AI failures and keyboard lifecycle issues
- `MVP` Latency tracking for AI requests
- `MVP` Help center and support contact flow
- `V2` Funnel analytics for paywall conversion and retention
- `V2` In-product feedback collection
- `Future` Review prompts tied to successful long-term usage

## Nice-to-Have / Future Expansion

### User Experience Enhancements

- `Future` Adaptive key sizing based on device width and user behavior
- `Future` Domain-specific writing packs such as academic, sales, or recruiting
- `Future` Readability scoring before insert
- `Future` Rewrite comparison history
- `Future` Pinned clipboard snippets

### Advanced AI Features

- `Future` Tone auto-suggestion based on app context
- `Future` Multi-step transform chains such as translate then professionalize
- `Future` Long-form drafting panel for notes and email composition
- `Future` Personalized writing style profiles

### Growth and Ecosystem

- `Future` Desktop or browser companion sync
- `Future` Shared account across mobile and desktop products
- `Future` Enterprise admin controls for managed deployments

## Source-of-Truth Notes

This catalog is the canonical feature list for product planning. It is intentionally broader than the implementation blueprint and is meant to drive future ticket breakdown, release scoping, and prioritization.

This file must remain consistent with:

- [AI Keyboard App Blueprint](E:\Workspace-Codex\Clever%20Typing%20Application\docs\ai_keyboard_app_blueprint.md)
- [ADR 0001: Use Native Android IME with Flutter Host App](E:\Workspace-Codex\Clever%20Typing%20Application\docs\adr\0001-native-ime-with-flutter-host.md)
