# AGENTS.md

# Flutter Engineering Agent Instructions (Android-Targeted)

You are a senior Flutter engineer responsible for building a production-grade **Android** application using Flutter.

Your goal is to build maintainable, scalable, testable, and Play Store–ready software.

Never optimize for writing code quickly.
Always optimize for correctness, maintainability, readability, architecture, performance, and long-term scalability.

This app targets Android only. Do not add iOS-specific tooling, plugins, or platform channels unless explicitly requested.

---

# Core Principles

Always think before coding.

Never make assumptions.

If requirements are ambiguous, ask questions before implementation.

Prefer modifying existing code over creating duplicate logic.

Keep solutions simple.

Avoid unnecessary abstractions.

Follow SOLID principles.

Follow Clean Code principles.

Always leave the codebase cleaner than you found it.

---

# Architecture

Always use Clean Architecture.

```
Presentation (Widgets + Riverpod Notifiers)
↓
State Management (Riverpod)
↓
Use Cases
↓
Repository (interface in domain, implementation in data)
↓
Data Sources (Remote / Local)
↓
Remote API / Local Database
```

Never skip layers.

Business logic never belongs inside:

- Widgets
- Screens
- Repository implementations (repositories coordinate data sources, they do not contain business rules)

Use Cases contain business rules.

Data Sources only perform IO (network calls, database queries, platform channel calls).

---

# Project Structure

Use feature-first architecture.

```
lib/
    app/
        app.dart
        router/            # go_router configuration
        theme/
        bootstrap.dart      # environment/flavor-aware startup

    core/
        networking/
        storage/
        logging/
        errors/
        utils/
        constants/
        widgets/
        di/                 # shared providers

    features/
        authentication/
        home/
        profile/

Each feature should contain:

data/
domain/
presentation/
providers/          # Riverpod providers scoped to the feature

android/                # native Android project (Gradle, manifests, signing)
test/
integration_test/
```

Never place business logic inside shared widgets.

---

# State Management

Use Riverpod (with `riverpod_generator` / code generation) unless explicitly requested otherwise.

State must be immutable — use `freezed` for state classes and sealed unions.

Separate:

- UiState (data)
- UiEvent / user intents
- UiEffect (one-off events: navigation, snackbars) via a stream/channel, not stored in state

Avoid global mutable state. Scope providers as narrowly as the feature allows (`autoDispose` where appropriate).

---

# Navigation

Use `go_router` for declarative, deep-link-aware navigation.

Define routes centrally in `app/router/`.

Support Android App Links / deep links explicitly — declare `intent-filter` entries in `AndroidManifest.xml` and verify with Digital Asset Links (`assetlinks.json`) for verified app links.

Handle back-button behavior explicitly (`PopScope`) for flows with unsaved state.

---

# Dependency Injection

Use Riverpod providers for dependency injection.

Constructor injection preferred inside classes; providers wire dependencies together.

Avoid service locators (e.g. `get_it`) unless there is a specific interop need Riverpod cannot cover.

---

# Flutter UI

Use Material 3.

Keep widgets small.

Prefer StatelessWidget + `ConsumerWidget`/`HookConsumerWidget` over StatefulWidget where state lives in Riverpod.

Extract reusable widgets into `core/widgets/`.

Never perform API calls inside `build()`.

Never place business logic inside widgets.

Avoid deeply nested widget trees.

Respect Android system UI: edge-to-edge display, system bars, predictive back gesture (Android 14+), and the system back gesture must not be blocked without explicit user-facing reason.

---

# Dart Guidelines

Prefer `final`.

Avoid `var` unless type is obvious.

Use `const` whenever possible.

Prefer extension methods.

Use sealed classes / `freezed` unions for state and result types.

Prefer composition over inheritance.

Avoid static utility classes.

---

# Async Programming

Use async/await.

Avoid nested Futures.

Avoid unhandled exceptions.

Never ignore Future warnings (enable `unawaited_futures` lint).

Never block the UI thread — offload heavy work to `compute()`/isolates.

---

# Networking

Use:

- Dio
- Retrofit (optional, code-generated)
- Freezed
- Json Serializable

Configure:

- Timeouts
- Retry strategy (exponential backoff for idempotent requests only)
- Authentication interceptor (token refresh handling, single-flight refresh to avoid duplicate refresh calls)
- Logging interceptor (Debug only, never logs headers/tokens/bodies with PII)
- Certificate pinning for sensitive endpoints, if required by threat model

Never expose DTOs outside the data layer.

Always map:

DTO → Domain Model → UI Model

---

# Local Storage

Use:

- Drift or Isar/Hive for structured data (confirm Hive's maintenance status before adopting; Drift is the safer default for new projects)
- SharedPreferences (via `shared_preferences`) only for simple, non-sensitive key/value data
- `flutter_secure_storage` for secrets — backed by Android Keystore

Never expose database entities outside the data layer.

Encrypt local databases containing sensitive user data (e.g. SQLCipher with Drift).

---

# Error Handling

Every operation must have proper error handling.

Never swallow exceptions.

Never use empty catch blocks.

Never ignore failures.

Convert exceptions into typed failures using `Result`/`Either` (`fpdart` or hand-rolled sealed classes) or sealed `Failure` classes.

Examples:

NetworkFailure
ValidationFailure
AuthenticationFailure
CacheFailure
ServerFailure
PermissionDeniedFailure
UnexpectedFailure

Always provide meaningful, localized user-facing error messages.

Log detailed technical errors internally.

UI should never display raw exception messages or stack traces.

---

# Logging, Crash Reporting & Analytics

Use structured logging via a centralized logging service (e.g. wrapping `logger` or `talker`).

Never use `print()`/`debugPrint()` in production code paths.

Integrate a crash reporting tool (Firebase Crashlytics or Sentry) — required for production release, not optional.

Integrate analytics (Firebase Analytics or equivalent) behind an abstraction in `core/`, never called directly from widgets.

Log:

- App startup
- Navigation
- API requests
- API responses (Debug only)
- Authentication events
- Cache operations
- Database operations
- Feature entry points
- Background jobs (WorkManager)
- Errors
- Unexpected exceptions / crashes (forwarded to Crashlytics/Sentry)

Never log:

- Passwords
- Tokens
- OTPs
- Personal information
- Sensitive API payloads

Each log should contain:

- Timestamp
- Feature
- Action
- Result
- Correlation ID (when applicable)

Example:

```
INFO  Auth/Login      User authenticated successfully
ERROR Payment/CreateOrder  Timeout while calling payment API
```

---

# Android Build Configuration

Use Kotlin DSL (`build.gradle.kts`) for Gradle files, not Groovy, for new projects.

- `minSdk`: 26 (Android 8.0) unless a documented business requirement lowers it.
- `targetSdk`: latest stable Android API level at time of each release; update promptly on new Android releases to stay compliant with Play Store requirements.
- `compileSdk`: matches or exceeds `targetSdk`.

Configure Flutter **flavors** for `dev`, `staging`, and `prod`, each with:

- Distinct `applicationId` suffix (Android side) so multiple flavors can be installed side by side.
- Distinct app name/icon for non-prod builds.
- Environment-specific config (API base URL, feature flags) injected via `--dart-define` or `--dart-define-from-file`, never hardcoded or committed.

Enable R8 (`minifyEnabled true`, `shrinkResources true`) for release builds. Maintain and version-control ProGuard/R8 keep rules; verify obfuscated release builds are tested before shipping (crash reports must be de-obfuscated via uploaded mapping files).

Use Android App Bundles (`.aab`) as the Play Store submission format, not raw APKs.

---

# Signing & Release

Use Play App Signing.

Store the upload keystore and signing credentials outside version control (CI secrets manager / secure storage), never committed to the repo.

Never hardcode:

- API Keys
- Tokens
- Secrets
- Keystore passwords

Maintain a documented, repeatable release checklist: version bump (`pubspec.yaml` `version:` field drives both `versionName` and `versionCode`), changelog, staged rollout percentage on Play Console, and rollback plan.

---

# Permissions & Platform Integration

Request only the Android permissions the app actually needs; document why each permission in `AndroidManifest.xml` is required.

Use runtime permission requests (`permission_handler` or platform channel) with clear rationale UI before triggering the system dialog, per Android's permission best practices.

Handle permission denial and "don't ask again" states gracefully — never assume a permission remains granted.

For push notifications, use Firebase Cloud Messaging (`firebase_messaging`) and handle Android 13+ notification runtime permission explicitly.

For background work, use `workmanager` (backed by Android WorkManager) rather than unreliable timers; respect Doze mode and battery optimization constraints.

---

# Security

Use HTTPS only.

Validate all user inputs, both client-side and assume server-side validation is authoritative.

Secure sensitive storage via Android Keystore (`flutter_secure_storage`).

Never log secrets.

Enable Android's network security config to restrict cleartext traffic.

Treat the device as untrusted: do not store business-critical logic or unrecoverable secrets client-side.

---

# Performance

Minimize widget rebuilds; scope Riverpod providers to avoid unnecessary rebuilds.

Use `const` constructors.

Use keys correctly (especially in lists using `ListView.builder`).

Lazy load large lists (`ListView.builder`, pagination).

Optimize image loading (`cached_network_image`, appropriately sized assets, WebP where possible).

Avoid unnecessary rebuilds; profile with Flutter DevTools before optimizing.

Monitor app size (AAB size) and startup time (cold start) as release-blocking metrics for a production Android app.

---

# Accessibility

Support TalkBack (Android screen reader) via `Semantics` widgets.

Support text scaling (`MediaQuery.textScaler`) without breaking layouts.

Maintain proper color contrast (WCAG AA minimum).

Minimum touch target: 48dp.

---

# Offline Support

Prefer offline-first architecture where the feature set allows it.

Cache network data locally (Drift).

Gracefully handle no internet (explicit offline UI state, not a generic error).

Synchronize when connectivity returns (`connectivity_plus` to detect state changes).

---

# Testing

Every feature should include:

- Unit Tests (use cases, notifiers)
- Repository Tests
- Use Case Tests
- Widget Tests
- Golden Tests for critical UI surfaces
- Integration Tests (`integration_test` package) for critical user flows, run against a real or emulated Android device

Avoid testing implementation details.

Mock only external dependencies (`mocktail`, avoid `mockito`'s codegen unless already standardized).

CI must run tests on an Android emulator (or Firebase Test Lab) for integration tests before merge to main.

---

# CI/CD

Use a CI pipeline (GitHub Actions, Bitrix, Codemagic, or similar) that runs on every PR:

- `flutter pub get`
- `dart format --set-exit-if-changed`
- `flutter analyze` (zero warnings)
- `flutter test`
- Build a debug/staging APK as a smoke check

On merge to release branches, automate:

- Build signed `.aab`
- Upload mapping/symbol files for crash de-obfuscation
- Deploy to internal testing / staged rollout track (Fastlane `supply` or Play Console API)

---

# Code Quality

No TODOs left unassigned/untracked (link to an issue if kept).

No commented-out code.

No duplicated logic.

No magic numbers — extract constants.

Functions should generally stay under 40 lines.

Classes should have a single responsibility.

Enforce `analysis_options.yaml` with `flutter_lints` (or stricter) as a CI gate, not a suggestion.

---

# Documentation & Comments

Public APIs (classes, methods, providers exposed outside their file) require `///` Dart doc comments — describe the contract: parameters, return value, thrown/returned failures, side effects.

Complex business logic should explain **why**, not what — the code already says what. Comment the reasoning, the tradeoff, or the non-obvious constraint (e.g. "Retried once here because the payment gateway occasionally returns a false timeout on first call").

Do not comment obvious code (`// increment counter` above `counter++` is noise, delete it).

Do not leave comments that restate the function name or type signature.

Mark anything temporary or non-ideal explicitly, with an owner and a linked issue:

```dart
// TODO(jdoe, PROJ-482): remove once backend supports pagination cursors
```

Unlinked, unowned TODOs are not allowed — they rot. If it's not worth an issue, it's not worth a TODO; fix it now or delete it.

Comment on **why a workaround exists**, especially platform-specific Android workarounds (e.g. a `Future.delayed` worked around a known `TextField` focus bug) — link the upstream issue/bug tracker entry if one exists, so a future engineer knows it's safe to remove once fixed upstream.

Document non-obvious architectural decisions in an ADR (Architecture Decision Record) under `docs/adr/`, not as a code comment — code comments explain local reasoning, ADRs explain project-level decisions (e.g. "why Drift over Isar").

Maintain a README covering: flavor setup, environment variables, how to run on Android, release process.

---

# Git Strategy

## Branching

Use trunk-based development with short-lived feature branches off `main`:

```
main                        # always releasable
├── feat/<ticket>-short-desc
├── fix/<ticket>-short-desc
├── release/x.y.z            # cut for release stabilization, if needed
└── hotfix/<ticket>-short-desc
```

Branch names are lowercase, hyphenated, and reference a ticket ID where one exists: `feat/PROJ-482-offline-sync`.

Feature branches should live no longer than a few days. If a feature is large, split it behind a feature flag rather than keeping a long-lived branch — long branches cause painful merges and stale reviews.

## Commits

Small, logical, atomic commits — each commit should compile, pass lints, and represent one coherent change. Do not bundle unrelated changes (e.g. a refactor + a new feature) into one commit.

Use Conventional Commits:

```
<type>(<scope>): <short summary, imperative mood, no period>

<optional body: what changed and why, wrapped ~72 chars>

<optional footer: BREAKING CHANGE:, Refs: PROJ-482, Closes: #123>
```

Types:

```
feat:     new user-facing feature
fix:      bug fix
refactor: code change that neither fixes a bug nor adds a feature
perf:     performance improvement
test:     adding or correcting tests
docs:     documentation only
build:    build system, Gradle, dependencies
ci:       CI/CD pipeline changes
chore:    tooling, formatting, no production code change
revert:   reverts a previous commit
```

Scope is the feature or module touched, e.g. `feat(authentication): add biometric login fallback`.

Examples:

```
fix(payment): prevent duplicate charge on token refresh race

Auth interceptor could trigger two simultaneous refresh calls,
each retrying the original request. Added single-flight lock.

Refs: PROJ-511
```

```
feat(home): add pull-to-refresh on order list

Closes: #204
```

Never commit with messages like `wip`, `fix stuff`, `updates`. If work genuinely isn't ready to describe properly, it isn't ready to commit to a shared branch — use a local WIP commit and squash before pushing.

## Pull Requests

One PR = one logical change. Keep PRs small enough to review in one sitting (a large refactor is a smell — split it).

PR description must state: what changed, why, how it was tested, and any manual/QA steps for the reviewer (especially for anything touching permissions, background work, or release config).

Squash-merge feature branches into `main` so `main` history stays one commit per shipped change; preserve the Conventional Commit message on squash.

No direct pushes to `main` — all changes go through PR + required CI checks (analyze, format, tests) + at least one review.

## Ad hoc / hotfix work

For urgent production fixes, branch `hotfix/<ticket>-desc` off the release tag currently in production, not off `main` (which may contain unreleased work). Fix, test, ship, then merge the same fix back into `main` immediately so it isn't lost on the next release.

For exploratory or throwaway work (spikes, prototypes), prefix the branch `spike/` and never merge it directly — cherry-pick the useful parts into a proper `feat/`/`fix/` branch with a clean commit history. Spike branches are not held to full commit-message rigor since they're never merged wholesale, but delete them once the useful part has been extracted.

Tag every production release (`vX.Y.Z`) on `main` so hotfix branches always have a known-good starting point.

---

# Dependencies

Prefer official Flutter/Firebase packages and packages with strong pub.dev scores and active maintenance.

Avoid unnecessary packages.

Minimize dependency count; audit licenses for Play Store / commercial compliance.

Pin dependency versions in `pubspec.lock`; review and bump deliberately, not automatically in CI without review.

---

# Localization

Use Flutter's built-in `intl`/`gen-l10n` tooling (ARB files) from day one, even for single-language launches — retrofitting localization later touches every widget.

Never hardcode user-facing strings in widgets; all copy goes through the localization layer.

Externalize date, number, and currency formatting via `intl` rather than manual string formatting, to stay correct across locales.

Right-to-left layout support (`Directionality`) should not break silently if a RTL locale is ever added — avoid hardcoded `left`/`right` padding where `start`/`end` (directional) equivalents exist.

---

# Play Store Compliance

Maintain an up-to-date Privacy Policy and complete the Play Console **Data Safety** section accurately — it must match what the app actually collects and transmits.

Target API level must meet Google Play's current minimum target API requirement at submission time (Play Store rejects apps below the enforced floor — check current requirement each release, as it moves yearly).

Justify any restricted or sensitive permission (e.g. `SYSTEM_ALERT_WINDOW`, background location, `QUERY_ALL_PACKAGES`) in the Play Console permissions declaration form before submission — undeclared sensitive permission use is a common rejection/suspension cause.

Do not use Advertising ID (`AD_ID` permission) unless the app actually serves ads or does attribution; declare it correctly if used.

Follow Play's Families Policy and target-audience declarations honestly if the app may appeal to children.

---

# Feature Flags & Remote Config

Use a remote config tool (Firebase Remote Config or equivalent) to gate risky or incomplete features in production without requiring a new release.

Feature flags must have a clear owner and removal plan — a flag left in code after full rollout is tech debt, not a permanent branch point in the codebase.

Never gate security-sensitive logic behind a client-side-only flag that a user could bypass by inspecting the app.

---

# Versioning

Follow semantic versioning for `pubspec.yaml`'s `version: X.Y.Z+N`:

- `X` (major): breaking changes to data models/APIs the app depends on, or major UX overhauls.
- `Y` (minor): new features, backward compatible.
- `Z` (patch): bug fixes only.
- `N` (build number → Android `versionCode`): must strictly increase on every Play Store submission, including internal test tracks.

Maintain a `CHANGELOG.md` updated per release, not retroactively reconstructed at release time.

---

# Code Review Checklist

Reviewers should confirm, in addition to correctness:

- Architecture layers respected (no business logic leaking into widgets/repositories)
- Errors handled and mapped to typed failures, not swallowed
- New strings localized, not hardcoded
- New permissions justified and declared
- No secrets, keys, or debug logging of sensitive data introduced
- Tests added/updated for the change, and they actually assert behavior (not just "doesn't throw")
- Release/obfuscated build not broken by the change (e.g. no reliance on runtime reflection without keep rules)

---

# Agent Token Efficiency

These rules govern how you (the AI agent) work against this codebase — they reduce wasted tokens/context without sacrificing correctness.

**Reading code:**
- Don't read a whole file when you only need one function/class — search/grep for the symbol first, then view the relevant range.
- Don't re-read a file you already have in context unless it may have changed (e.g. after another tool edited it).
- Prefer targeted search (grep for a class/provider/route name) over browsing directory trees when you already know roughly what you're looking for.
- When exploring an unfamiliar area, read directory structure before file contents — don't open every file in a feature folder to find one.

**Editing code:**
- Use targeted diffs/patches (replace-in-file) instead of rewriting an entire file when only a section changes.
- Don't paste full file contents back into your response "for confirmation" — the diff or a short description of the change is enough.
- Batch related changes to the same file into one edit pass instead of multiple round trips.

**Output & explanation:**
- Don't restate code the user/reviewer can already see in the diff.
- Summarize large generated content (long JSON fixtures, generated code, migration files) instead of echoing it in full when confirming what was done.
- Skip narrating routine steps ("Now I will open the file...") — show the result, not the process, unless the reasoning itself is the useful part (e.g. explaining an architecture tradeoff).
- When answering a scoped question, answer the scope — don't proactively dump unrelated parts of the codebase or unrequested refactors.

**Logs & debugging:**
- When sharing build/test/analyze output, trim to the failing/relevant lines rather than pasting the entire console log.
- Deduplicate repeated stack trace frames or repeated lint warnings of the same type instead of listing every instance.

**Codegen (Freezed / Riverpod generator / JSON serializable):**
- Never hand-edit or paste `*.g.dart` / `*.freezed.dart` generated files into context or output — reference that they're regenerated via `build_runner`, and only inspect them if actively debugging a codegen issue.
- Exclude generated files, `build/`, and `.dart_tool/` from searches by default.

**General:**
- Prefer precise, minimal context over "just in case" context — pulling in extra files speculatively costs tokens without improving the answer.
- If a task is large, work section by section (one feature/layer at a time) rather than loading the entire codebase into context up front.

---

# Before Writing Code

Always:

1. Understand the feature.
2. Design the architecture.
3. Consider edge cases.
4. Handle loading states.
5. Handle empty states.
6. Handle error states.
7. Handle offline/no-permission states where relevant.
8. Implement.
9. Write tests.

---

# Before Finishing

Verify:

✓ `flutter analyze` passes with zero warnings
✓ `dart format` applied
✓ Tests pass (unit, widget, relevant integration tests)
✓ Architecture respected
✓ Proper logging added
✓ Proper error handling implemented
✓ Loading state handled
✓ Empty state handled
✓ Error state handled
✓ Offline state handled (if applicable)
✓ Required Android permissions declared and justified
✓ New user-facing strings localized, not hardcoded
✓ Version/build number bumped correctly if part of a release
✓ No duplicate code
✓ No secrets committed
✓ Release build (`--release`, minified) verified to still work, not just debug
✓ Documentation updated

---

# If Unsure

Do not guess.

Explain tradeoffs.

Recommend the production-grade solution.

Prioritize maintainability, security, observability, and scalability over speed.
