import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/di/core_providers.dart';
import '../core/networking/ai_backend_config.dart';
import '../core/platform/models/keyboard_status.dart';
import '../features/keyboard_settings/data/keyboard_settings_repository.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/onboarding/data/onboarding_repository.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import 'app.dart';

/// Synchronizes runtime configuration needed by the native keyboard layer.
class AppInitializer extends ConsumerStatefulWidget {
  /// Creates the initializer widget.
  const AppInitializer({super.key});

  @override
  ConsumerState<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<AppInitializer> {
  String? _initialLocation;

  @override
  void initState() {
    super.initState();
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    final KeyboardSettingsRepository repository = KeyboardSettingsRepository(
      ref.read(appPreferencesStoreProvider),
    );
    final settings = await repository.load();
    await ref.read(keyboardPlatformServiceProvider).syncKeyboardSettings(settings);
    final OnboardingRepository onboardingRepository = OnboardingRepository(
      ref.read(appPreferencesStoreProvider),
    );
    final bool isOnboardingCompleted = await onboardingRepository.isCompleted();
    KeyboardStatus? keyboardStatus;
    try {
      keyboardStatus =
          await ref.read(keyboardPlatformServiceProvider).getKeyboardStatus();
    } catch (_) {
      keyboardStatus = null;
    }
    final bool shouldOpenHome =
        isOnboardingCompleted &&
        (keyboardStatus == null ||
            (keyboardStatus.isKeyboardEnabled &&
                keyboardStatus.isKeyboardSelected));

    final AiBackendConfig config = ref.read(aiBackendConfigProvider);
    if (!config.isConfigured) {
      if (!mounted) {
        return;
      }
      setState(() {
        _initialLocation = shouldOpenHome
            ? HomeScreen.routePath
            : OnboardingScreen.routePath;
      });
      return;
    }

    await ref.read(keyboardPlatformServiceProvider).syncBackendConfig(config);
    await ref.read(remoteConfigRepositoryProvider).load();
    if (!mounted) {
      return;
    }
    setState(() {
      _initialLocation = shouldOpenHome
          ? HomeScreen.routePath
          : OnboardingScreen.routePath;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_initialLocation == null) {
      return const Directionality(
        textDirection: TextDirection.ltr,
        child: ColoredBox(
          color: Color(0xFFF5F1E8),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return CleverTypingApp(initialLocation: _initialLocation!);
  }
}
