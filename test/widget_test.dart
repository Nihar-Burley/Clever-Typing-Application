import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:clever_typing_application/app/app.dart';
import 'package:clever_typing_application/core/di/core_providers.dart';
import 'package:clever_typing_application/core/networking/ai_backend_config.dart';
import 'package:clever_typing_application/core/platform/keyboard_platform_service.dart';
import 'package:clever_typing_application/core/platform/models/keyboard_status.dart';
import 'package:clever_typing_application/core/storage/app_preferences_store.dart';
import 'package:clever_typing_application/features/home/presentation/screens/home_screen.dart';
import 'package:clever_typing_application/features/keyboard_settings/presentation/models/keyboard_settings_state.dart';
import 'package:clever_typing_application/features/onboarding/data/onboarding_repository.dart';
import 'package:clever_typing_application/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:clever_typing_application/l10n/app_localizations.dart';

void main() {
  testWidgets('app renders a MaterialApp', (WidgetTester tester) async {
    final _FakeKeyboardPlatformService platformService =
        _FakeKeyboardPlatformService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          keyboardPlatformServiceProvider.overrideWithValue(
            platformService,
          ),
        ],
        child: const CleverTypingApp(
          initialLocation: OnboardingScreen.routePath,
        ),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('finish setup navigates to the home screen', (
    WidgetTester tester,
  ) async {
    final _FakeKeyboardPlatformService platformService =
        _FakeKeyboardPlatformService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          keyboardPlatformServiceProvider.overrideWithValue(
            platformService,
          ),
        ],
        child: const CleverTypingApp(
          initialLocation: OnboardingScreen.routePath,
        ),
      ),
    );

    await tester.pumpAndSettle();

    final AppLocalizations l10n = AppLocalizations.english;

    await tester.tap(find.text(l10n.onboardingContinue));
    await tester.pumpAndSettle();
    expect(find.text(l10n.onboardingStepEnableTitle), findsOneWidget);

    await tester.tap(find.text(l10n.onboardingEnableKeyboardAction));
    await tester.pumpAndSettle();
    expect(find.text(l10n.onboardingStepEnableTitle), findsOneWidget);

    platformService.isKeyboardEnabled = true;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text(l10n.onboardingStepSelectTitle), findsOneWidget);

    await tester.tap(find.text(l10n.onboardingSelectKeyboardAction));
    await tester.pumpAndSettle();
    expect(find.text(l10n.onboardingStepSelectTitle), findsOneWidget);

    platformService.isKeyboardSelected = true;
    await tester.tap(find.text(l10n.onboardingSelectKeyboardAction));
    await tester.pumpAndSettle();
    expect(find.text(l10n.onboardingStepPrivacyTitle), findsOneWidget);

    await tester.tap(find.text(l10n.onboardingFinish));
    await tester.pumpAndSettle();

    expect(find.text(l10n.homeTitle), findsOneWidget);
    expect(find.text(l10n.homeWelcomeTitle), findsOneWidget);
  });

  test('onboarding completion is persisted for the next launch', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final OnboardingRepository repository = OnboardingRepository(
      const AppPreferencesStore(),
    );

    expect(await repository.isCompleted(), isFalse);

    await repository.setCompleted(true);

    expect(await repository.isCompleted(), isTrue);
  });

  testWidgets('home can be the initial route after onboarding is complete', (
    WidgetTester tester,
  ) async {
    final _FakeKeyboardPlatformService platformService =
        _FakeKeyboardPlatformService()
          ..isKeyboardEnabled = true
          ..isKeyboardSelected = true;

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          keyboardPlatformServiceProvider.overrideWithValue(
            platformService,
          ),
        ],
        child: const CleverTypingApp(
          initialLocation: HomeScreen.routePath,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(AppLocalizations.english.homeTitle), findsOneWidget);
  });
}

class _FakeKeyboardPlatformService implements KeyboardPlatformService {
  bool isKeyboardEnabled = false;
  bool isKeyboardSelected = false;

  @override
  Future<void> clearNativeData() async {}

  @override
  Future<KeyboardStatus> getKeyboardStatus() async {
    return KeyboardStatus(
      isKeyboardEnabled: isKeyboardEnabled,
      isKeyboardSelected: isKeyboardSelected,
    );
  }

  @override
  Future<bool> isAccessibilityCaptureEnabled() async => false;

  @override
  Future<void> openAccessibilitySettings() async {}

  @override
  Future<void> openKeyboardSettings() async {}

  @override
  Future<String?> readLatestConversationContext() async => null;

  @override
  Future<Map<String, Object?>> readNativeStatus() async => <String, Object?>{};

  @override
  Future<void> showInputMethodPicker() async {}

  @override
  Future<void> syncBackendConfig(AiBackendConfig config) async {}

  @override
  Future<void> syncKeyboardSettings(KeyboardSettingsState state) async {}

  @override
  Future<void> syncPinnedAssistant(String? assistantId) async {}
}
