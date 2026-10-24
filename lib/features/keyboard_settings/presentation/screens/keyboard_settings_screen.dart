import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/platform/models/keyboard_status.dart';
import '../../../../core/widgets/app_section_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/keyboard_settings_provider.dart';
import '../models/keyboard_settings_state.dart';

final FutureProvider<KeyboardStatus> keyboardStatusProvider =
    FutureProvider<KeyboardStatus>(
  (Ref ref) {
    return ref.read(keyboardPlatformServiceProvider).getKeyboardStatus();
  },
);

/// Screen for keyboard personalization and typing settings.
class KeyboardSettingsScreen extends ConsumerWidget {
  /// Creates the keyboard settings screen.
  const KeyboardSettingsScreen({super.key});

  static const String routeName = 'keyboard-settings';
  static const String routePath = '/keyboard-settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final KeyboardSettingsState state = ref.watch(keyboardSettingsProvider);
    final KeyboardSettingsNotifier notifier =
        ref.read(keyboardSettingsProvider.notifier);
    final AsyncValue<KeyboardStatus> keyboardStatus =
        ref.watch(keyboardStatusProvider);
    final TextTheme textTheme = Theme.of(context).textTheme;
    const List<String> palettes = <String>['sunrise', 'forest', 'night'];
    const List<String> languages = <String>[
      'English',
      'Hindi',
      'Spanish',
      'French',
      'German',
      'Arabic',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.keyboardSettingsTitle),
      ),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: <Widget>[
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.keyboardSettingsHeadline,
                  style: textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.keyboardSettingsBody,
                  style: textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSectionCard(
            child: keyboardStatus.when(
              data: (KeyboardStatus status) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.keyboardSettingsIntegrationTitle,
                    style: textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.keyboardSettingsEnabledStatus(status.isKeyboardEnabled),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.keyboardSettingsSelectedStatus(status.isKeyboardSelected),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .read(keyboardPlatformServiceProvider)
                          .openKeyboardSettings();
                    },
                    child: Text(l10n.keyboardSettingsOpenSystemSettings),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton(
                    onPressed: () {
                      ref
                          .read(keyboardPlatformServiceProvider)
                          .showInputMethodPicker();
                    },
                    child: Text(l10n.keyboardSettingsShowPicker),
                  ),
                ],
              ),
              loading: () => Text(l10n.keyboardSettingsLoadingStatus),
              error: (_, __) => Text(l10n.keyboardSettingsStatusUnavailable),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSectionCard(
            child: Column(
              children: <Widget>[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.keyboardSettingsAutoCapitalization),
                  value: state.autoCapitalizationEnabled,
                  onChanged: notifier.setAutoCapitalization,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.keyboardSettingsAutoSpace),
                  value: state.autoSpaceEnabled,
                  onChanged: notifier.setAutoSpace,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.keyboardSettingsHapticFeedback),
                  value: state.hapticFeedbackEnabled,
                  onChanged: notifier.setHapticFeedback,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.keyboardSettingsSoundFeedback),
                  value: state.soundFeedbackEnabled,
                  onChanged: notifier.setSoundFeedback,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.keyboardSettingsOneHandedMode),
                  value: state.oneHandedModeEnabled,
                  onChanged: notifier.setOneHandedMode,
                ),
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.keyboardSettingsHeightLabel(state.keyboardHeight),
                  ),
                ),
                Slider(
                  min: 0.8,
                  max: 1.4,
                  divisions: 6,
                  value: state.keyboardHeight,
                  onChanged: notifier.setKeyboardHeight,
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: state.themePalette,
                  items: palettes
                      .map(
                        (String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text('Theme: $value'),
                        ),
                      )
                      .toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      notifier.setThemePalette(value);
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Keyboard theme',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: state.primaryLanguage,
                  items: languages
                      .map(
                        (String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      notifier.setPrimaryLanguage(value);
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Primary language',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: state.secondaryLanguage,
                  items: languages
                      .where((String value) => value != state.primaryLanguage)
                      .map(
                        (String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      notifier.setSecondaryLanguage(value);
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Secondary language',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Incognito mode'),
                  subtitle: const Text(
                    'Disable cached context and privacy-sensitive history.',
                  ),
                  value: state.incognitoModeEnabled,
                  onChanged: notifier.setIncognitoMode,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
