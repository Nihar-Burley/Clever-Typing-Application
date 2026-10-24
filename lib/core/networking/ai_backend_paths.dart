/// Canonical AI backend endpoint paths used by Flutter and native Android.
abstract final class AiBackendPaths {
  static const String grammarCorrect = '/v1/keyboard/grammar-correct';
  static const String translate = '/v1/keyboard/translate';
  static const String smartReply = '/v1/keyboard/smart-reply';
  static const String rewrite = '/v1/keyboard/rewrite';
  static const String assistantExecute = '/v1/keyboard/assistant-execute';
  static const String assistantCatalog = '/v1/keyboard/assistants';
  static const String featureFlags = '/v1/keyboard/config';
}
