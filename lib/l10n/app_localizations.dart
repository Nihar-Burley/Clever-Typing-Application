import 'package:flutter/widgets.dart';

/// Minimal localization layer for the initial implementation.
class AppLocalizations {
  /// Creates localizations for the provided locale.
  const AppLocalizations(this.locale);

  /// Supported locales for the app shell.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
  ];

  /// Fast access to the default English copy.
  static const AppLocalizations english = AppLocalizations(Locale('en'));

  /// Delegate for resolving localizations.
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// Current locale.
  final Locale locale;

  /// Returns the localization instance from the widget tree.
  static AppLocalizations of(BuildContext context) {
    final AppLocalizations? localizations =
        Localizations.of<AppLocalizations>(context, AppLocalizations);

    assert(localizations != null, 'AppLocalizations not found in context');
    return localizations!;
  }

  String get appName => 'Clever Typing';

  String get onboardingContinue => 'Continue';
  String get onboardingEnableKeyboardAction => 'Open keyboard settings';
  String get onboardingSelectKeyboardAction => 'Choose Clever Typing';
  String get onboardingFinish => 'Finish setup';
  String get onboardingEnableKeyboardPrompt =>
      'Enable Clever Typing in Android settings, then return to this app.';
  String get onboardingEnableKeyboardPending =>
      'Waiting for Android to report that Clever Typing is enabled.';
  String get onboardingSelectKeyboardPrompt =>
      'Open the input picker and choose Clever Typing as the active keyboard.';
  String get onboardingSelectKeyboardPending =>
      'Clever Typing is not the active keyboard yet. Choose it from the picker, then try again.';

  String get onboardingStepWelcomeEyebrow => 'Welcome';
  String get onboardingStepWelcomeTitle => 'Write better from any Android app';
  String get onboardingStepWelcomeBody =>
      'This product pairs a native Android keyboard with a Flutter companion app. '
      'You will enable the keyboard, choose it as your active input method, and '
      'then use AI actions only when you explicitly request them.';

  String get onboardingStepEnableEyebrow => 'Step 1';
  String get onboardingStepEnableTitle => 'Enable the keyboard service';
  String get onboardingStepEnableBody =>
      'Open Android keyboard settings and enable the Clever Typing keyboard. '
      'The product uses a native input method service for low-latency typing and '
      'stable text input across apps.';

  String get onboardingStepSelectEyebrow => 'Step 2';
  String get onboardingStepSelectTitle => 'Switch to Clever Typing';
  String get onboardingStepSelectBody =>
      'Choose Clever Typing as the active keyboard from the system input picker. '
      'This keeps the keyboard flow aligned with standard Android input behavior.';

  String get onboardingStepPrivacyEyebrow => 'Privacy';
  String get onboardingStepPrivacyTitle => 'AI help stays explicit and controlled';
  String get onboardingStepPrivacyBody =>
      'Typing stays local by default. Text should only be sent to AI services when '
      'you choose an AI tool, and sensitive fields such as passwords or OTPs must '
      'never be processed by remote services.';

  String get homeTitle => 'Home';
  String get homeWelcomeTitle => 'Clever Typing is installed';
  String get homeWelcomeBody =>
      'Finish Android keyboard setup, then use the app to access grammar correction, '
      'translation, writing tools, assistants, and privacy controls.';
  String get homeNextStepsTitle => 'Keyboard setup';
  String get homeNextStepsItemKeyboard =>
      '1. Enable Clever Typing in Android keyboard settings.';
  String get homeNextStepsItemSettings =>
      '2. Select Clever Typing from the system input picker.';
  String get homeNextStepsItemAi =>
      '3. Return here to configure languages, theme, and AI tools.';
  String get homeFeatureDemoTitle => 'Quick setup actions';
  String get homeFeatureDemoBody =>
      'If the keyboard is not visible yet, open Android settings first, then use the '
      'picker to make Clever Typing the active keyboard.';
  String get homeFeatureDemoAction => 'Open keyboard settings';
  String get homeFeatureHubTitle => 'Features';
  String get homeCardOpenFeature => 'Open feature';
  String get homeKeyboardStatusTitle => 'Keyboard status';
  String get homeKeyboardStatusLoading => 'Checking Android keyboard status...';
  String get homeChooseKeyboardAction => 'Choose keyboard';
  String get homeCardAccountTitle => 'Account';
  String get homeCardAccountBody =>
      'Choose guest, email, or Google profile mode for the companion app.';
  String get homeCardWritingToolsTitle => 'AI writing tools';
  String get homeCardWritingToolsBody =>
      'Tone rewrite, paraphrase, summarize, captions, and email drafting.';
  String get homeCardGrammarTitle => 'Grammar correction';
  String get homeCardGrammarBody =>
      'Correct grammar, spelling, punctuation, and sentence polish.';
  String get homeCardTranslationTitle => 'Translation';
  String get homeCardTranslationBody =>
      'Translate text while preserving intent and future tone controls.';
  String get homeCardAssistantsTitle => 'Assistant gallery';
  String get homeCardAssistantsBody =>
      'Browse built-in writing assistants and premium prompt tools.';
  String get homeCardSmartReplyTitle => 'Smart reply';
  String get homeCardSmartReplyBody =>
      'Generate response suggestions from visible conversation context.';
  String get homeCardSettingsTitle => 'Keyboard settings';
  String get homeCardSettingsBody =>
      'Configure typing behavior, keyboard height, haptics, and layout options.';
  String get homeCardSubscriptionTitle => 'Subscription';
  String get homeCardSubscriptionBody =>
      'Manage quota, free versus premium access, and future entitlement gates.';
  String get homeCardPrivacyTitle => 'Privacy dashboard';
  String get homeCardPrivacyBody =>
      'Review explicit AI controls, sensitive field handling, and permission rules.';
  String get homeCardHelpTitle => 'Help and FAQ';
  String get homeCardHelpBody =>
      'Review setup steps, quota behavior, and support contact guidance.';

  String get accountTitle => 'Account';
  String get accountHeadline => 'Manage how this device uses Clever Typing';
  String get accountBody =>
      'The companion app supports guest use and persistent local account modes for email and Google identity preferences.';
  String accountCurrentMode(String mode) => 'Current mode: $mode';
  String accountCurrentIdentity(String displayName, String email) =>
      email.isEmpty ? 'Identity: $displayName' : 'Identity: $displayName ($email)';
  String get accountManageTitle => 'Account mode';
  String get accountNameLabel => 'Display name';
  String get accountEmailLabel => 'Email address';
  String get accountEmailAction => 'Use email';
  String get accountGoogleAction => 'Use Google profile';
  String get accountGuestAction => 'Continue as guest';
  String get accountSignOutAction => 'Sign out';

  String get grammarCorrectionTitle => 'Grammar correction';
  String get grammarCorrectionHeadline => 'Correct grammar before AI backend wiring';
  String get grammarCorrectionBody =>
      'This screen exercises the first end-to-end feature flow. The current '
      'implementation sends requests through the configured AI backend using '
      'the same repository layers that the keyboard integration will use.';
  String get grammarCorrectionInputLabel => 'Text to correct';
  String get grammarCorrectionInputHint =>
      'Enter text with grammar or punctuation issues.';
  String get grammarCorrectionAction => 'Correct grammar';
  String get grammarCorrectionLoading => 'Correcting...';
  String get grammarCorrectionResultTitle => 'Correction result';
  String get grammarCorrectionOriginalLabel => 'Original';
  String get grammarCorrectionCorrectedLabel => 'Corrected';

  String get translationTitle => 'Translation';
  String get translationHeadline => 'Translate from the app before keyboard wiring';
  String get translationBody =>
      'This flow provides the translation surface, language selection, and output '
      'handling that will later be shared with keyboard-triggered translation.';
  String get translationLanguageLabel => 'Target language';
  String get translationSourceLanguageLabel => 'Source language';
  String get translationPreserveToneLabel => 'Preserve original tone';
  String get translationInputLabel => 'Text to translate';
  String get translationInputHint => 'Enter text that needs translation.';
  String get translationAction => 'Translate';
  String get translationLoading => 'Translating...';
  String get translationResultTitle => 'Translated text';
  String translationDetectedLanguage(String value) =>
      'Detected source language: $value';

  String get assistantGalleryTitle => 'Assistant gallery';
  String get assistantGalleryHeadline => 'Built-in AI assistant templates';
  String get assistantGalleryBody =>
      'These assistants mirror the task-focused tools expected in competitive AI '
      'keyboards. Saved custom assistants can be layered onto this gallery later.';
  String get assistantExecutionBody =>
      'Run the selected assistant against the live backend contract so the same workflow can later execute from the keyboard.';
  String get assistantExecutionInputLabel => 'Text for assistant execution';
  String get assistantExecutionAction => 'Run assistant';
  String get assistantExecutionLoading => 'Running assistant...';
  String get assistantExecutionResultTitle => 'Assistant output';

  String get keyboardSettingsTitle => 'Keyboard settings';
  String get keyboardSettingsHeadline => 'Tune typing behavior for Android use';
  String get keyboardSettingsBody =>
      'These settings model the preferences that the native keyboard service will '
      'read quickly without pushing per-keystroke state through Flutter.';
  String get keyboardSettingsIntegrationTitle => 'Android keyboard integration';
  String get keyboardSettingsAutoCapitalization => 'Auto-capitalization';
  String get keyboardSettingsAutoSpace => 'Auto-space after punctuation';
  String get keyboardSettingsHapticFeedback => 'Haptic feedback';
  String get keyboardSettingsSoundFeedback => 'Sound feedback';
  String get keyboardSettingsOneHandedMode => 'One-handed mode';
  String keyboardSettingsEnabledStatus(bool isEnabled) =>
      'Keyboard enabled in system settings: ${isEnabled ? 'Yes' : 'No'}';
  String keyboardSettingsSelectedStatus(bool isSelected) =>
      'Keyboard selected as active input method: ${isSelected ? 'Yes' : 'No'}';
  String get keyboardSettingsOpenSystemSettings => 'Open Android keyboard settings';
  String get keyboardSettingsShowPicker => 'Show input method picker';
  String get keyboardSettingsLoadingStatus => 'Checking keyboard status...';
  String get keyboardSettingsStatusUnavailable =>
      'Keyboard status is unavailable in the current environment.';
  String keyboardSettingsHeightLabel(double value) =>
      'Keyboard height: ${value.toStringAsFixed(1)}x';

  String get privacyTitle => 'Privacy dashboard';
  String get privacyHeadline => 'Trust and consent must be explicit';
  String get privacyBody =>
      'Keyboard products are held to a higher bar. This screen captures the user '
      'promises that must stay true as more AI-backed features are integrated.';
  String get privacyRulesTitle => 'Core privacy rules';
  String get privacyRuleLocalTyping =>
      'Typing stays local until the user explicitly runs an AI action.';
  String get privacyRuleExplicitAi =>
      'AI requests must be intentional and visible to the user.';
  String get privacyRuleSensitiveFields =>
      'Passwords, OTPs, and payment fields must bypass remote processing.';
  String get privacyRuleAccessibility =>
      'Smart reply access should be opt-in and explained before permission prompts.';

  String get subscriptionTitle => 'Subscription';
  String get subscriptionHeadline => 'Quota and premium access model';
  String get subscriptionBody =>
      'Competitive AI keyboards need a sustainable free tier and clear premium '
      'value. This screen models the entitlement surface before backend billing integration.';
  String subscriptionCurrentPlan(String planName) => 'Current plan: $planName';
  String subscriptionQuota(int actions) =>
      'Remaining daily AI actions: $actions';
  String subscriptionUsageToday(int used, int quota) =>
      'Used today: $used of ${quota == 999 ? 'unlimited' : quota}';
  String get subscriptionPlansTitle => 'Plans';
  String get subscriptionFreePlan => 'Free';
  String get subscriptionPremiumPlan => 'Premium';
  String get subscriptionFeatureFree =>
      'Free: core keyboard, grammar correction, limited daily AI usage.';
  String get subscriptionFeaturePremium =>
      'Premium: higher or unlimited AI usage and advanced assistants.';
  String get subscriptionFeatureSmartReply =>
      'Premium roadmap: smart reply, premium themes, custom assistants.';
  String get subscriptionRefreshAction => 'Refresh usage';
  String get subscriptionRestorePurchases => 'Restore purchases';

  String get helpTitle => 'Help and FAQ';
  String get helpHeadline => 'Launch guidance and support';
  String get helpBody =>
      'Use this screen as the in-app help center for setup, AI usage rules, and support contact.';
  String get helpFaqTitle => 'Frequently asked questions';
  String get helpFaqEnableKeyboardQuestion => 'How do I enable the keyboard?';
  String get helpFaqEnableKeyboardAnswer =>
      'Open Android keyboard settings, enable Clever Typing, then select it from the system input picker.';
  String get helpFaqAiQuestion => 'When is my text sent to AI services?';
  String get helpFaqAiAnswer =>
      'Only after you explicitly run an AI action such as grammar correction, rewrite, translate, smart reply, or assistant execution.';
  String get helpFaqQuotaQuestion => 'How does the free quota work?';
  String get helpFaqQuotaAnswer =>
      'Free mode has a daily AI action quota. Premium mode removes that limit for the app-side MVP flows.';
  String get helpSupportTitle => 'Support';
  String get helpSupportBody =>
      'If setup fails or the keyboard does not appear, gather your device model, Android version, and the failing flow before contacting support.';
  String get helpSupportEmail => 'support@clevertyping.app';

  String get smartReplyTitle => 'Smart reply';
  String get smartReplyHeadline => 'Preview reply generation flow';
  String get smartReplyBody =>
      'Smart reply can use accessibility-assisted conversation capture after '
      'explicit user permission and reply-variant selection.';
  String get smartReplyAccessibilityEnabled =>
      'Accessibility capture is enabled.';
  String get smartReplyAccessibilityDisabled =>
      'Accessibility capture is disabled.';
  String get smartReplyAccessibilityAction => 'Open accessibility settings';
  String get smartReplyRefreshContextAction => 'Refresh captured context';
  String get smartReplyVariantLabel => 'Reply variant';
  String get smartReplyVariantShort => 'Short';
  String get smartReplyVariantFriendly => 'Friendly';
  String get smartReplyVariantProfessional => 'Professional';
  String get smartReplyVariantPositive => 'Positive';
  String get smartReplyInputLabel => 'Conversation context';
  String get smartReplyInputHint =>
      'Paste the latest message or short conversation context.';
  String get smartReplyAction => 'Generate replies';
  String get smartReplyLoading => 'Generating...';

  String get writingToolsTitle => 'AI writing tools';
  String get writingToolsHeadline => 'Production writing tools surface';
  String get writingToolsBody =>
      'Use a unified backend-driven pipeline for rewrite, paraphrase, summarization, captions, and drafting.';
  String get writingToolsToolLabel => 'Writing tool';
  String get writingToolsToneLabel => 'Tone';
  String get writingToolsInputLabel => 'Input text';
  String get writingToolsInputHint =>
      'Enter the content you want to transform.';
  String get writingToolsAction => 'Run writing tool';
  String get writingToolsLoading => 'Running...';
  String get writingToolsResultTitle => 'Tool output';
  String get toolGrammarCorrection => 'Grammar correction';
  String get toolToneRewrite => 'Tone rewrite';
  String get toolParaphrase => 'Paraphrase';
  String get toolShorten => 'Shorten';
  String get toolExpand => 'Expand';
  String get toolSimplify => 'Simplify';
  String get toolHumanize => 'Humanize';
  String get toolSummarize => 'Summarize';
  String get toolCaptionGeneration => 'Caption generation';
  String get toolEmailDraft => 'Email draft';
  String get toneNeutral => 'Neutral';
  String get toneProfessional => 'Professional';
  String get toneFriendly => 'Friendly';
  String get toneFormal => 'Formal';
  String get tonePersuasive => 'Persuasive';

  String get commonPremium => 'Premium';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'en';

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
