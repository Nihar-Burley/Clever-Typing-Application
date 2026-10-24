abstract interface class SmartReplyPermissionRepository {
  Future<bool> isAccessibilityEnabled();

  Future<void> openAccessibilitySettings();

  Future<String?> readLatestConversationContext();
}
