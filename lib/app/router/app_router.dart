import 'package:go_router/go_router.dart';

import '../../features/account/presentation/screens/account_screen.dart';
import '../../features/assistants/presentation/screens/assistant_gallery_screen.dart';
import '../../features/help/presentation/screens/help_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/keyboard_settings/presentation/screens/keyboard_settings_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/privacy/presentation/screens/privacy_dashboard_screen.dart';
import '../../features/rewriting/presentation/screens/grammar_correction_screen.dart';
import '../../features/smart_reply/presentation/screens/smart_reply_screen.dart';
import '../../features/subscription/presentation/screens/subscription_screen.dart';
import '../../features/translation/presentation/screens/translation_screen.dart';
import '../../features/writing_tools/presentation/screens/writing_tools_screen.dart';

/// Centralized application routing.
class AppRouter {
  AppRouter({required String initialLocation})
    : _router = GoRouter(
        initialLocation: initialLocation,
        routes: <GoRoute>[
          GoRoute(
            path: OnboardingScreen.routePath,
            name: OnboardingScreen.routeName,
            builder: (context, state) => const OnboardingScreen(),
          ),
          GoRoute(
            path: HomeScreen.routePath,
            name: HomeScreen.routeName,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AccountScreen.routePath,
            name: AccountScreen.routeName,
            builder: (context, state) => const AccountScreen(),
          ),
          GoRoute(
            path: GrammarCorrectionScreen.routePath,
            name: GrammarCorrectionScreen.routeName,
            builder: (context, state) => const GrammarCorrectionScreen(),
          ),
          GoRoute(
            path: TranslationScreen.routePath,
            name: TranslationScreen.routeName,
            builder: (context, state) => const TranslationScreen(),
          ),
          GoRoute(
            path: WritingToolsScreen.routePath,
            name: WritingToolsScreen.routeName,
            builder: (context, state) => const WritingToolsScreen(),
          ),
          GoRoute(
            path: AssistantGalleryScreen.routePath,
            name: AssistantGalleryScreen.routeName,
            builder: (context, state) => const AssistantGalleryScreen(),
          ),
          GoRoute(
            path: KeyboardSettingsScreen.routePath,
            name: KeyboardSettingsScreen.routeName,
            builder: (context, state) => const KeyboardSettingsScreen(),
          ),
          GoRoute(
            path: PrivacyDashboardScreen.routePath,
            name: PrivacyDashboardScreen.routeName,
            builder: (context, state) => const PrivacyDashboardScreen(),
          ),
          GoRoute(
            path: SubscriptionScreen.routePath,
            name: SubscriptionScreen.routeName,
            builder: (context, state) => const SubscriptionScreen(),
          ),
          GoRoute(
            path: SmartReplyScreen.routePath,
            name: SmartReplyScreen.routeName,
            builder: (context, state) => const SmartReplyScreen(),
          ),
          GoRoute(
            path: HelpScreen.routePath,
            name: HelpScreen.routeName,
            builder: (context, state) => const HelpScreen(),
          ),
        ],
      );

  /// Router configuration for the Flutter host app.
  GoRouter get config => _router;

  final GoRouter _router;
}
