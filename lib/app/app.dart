import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../features/keyboard_settings/providers/keyboard_settings_provider.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

/// Root application widget for the Flutter host app.
class CleverTypingApp extends ConsumerWidget {
  /// Creates the app root.
  const CleverTypingApp({
    required this.initialLocation,
    super.key,
  });

  final String initialLocation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppRouter router = AppRouter(initialLocation: initialLocation);
    final String themePalette =
        ref.watch(keyboardSettingsProvider.select((state) => state.themePalette));

    return MaterialApp.router(
      title: AppLocalizations.english.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(themePalette),
      routerConfig: router.config,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
