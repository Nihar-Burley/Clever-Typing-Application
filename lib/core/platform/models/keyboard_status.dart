/// Native Android keyboard activation state.
class KeyboardStatus {
  /// Creates the keyboard status.
  const KeyboardStatus({
    required this.isKeyboardEnabled,
    required this.isKeyboardSelected,
  });

  /// Whether the keyboard service is enabled in system settings.
  final bool isKeyboardEnabled;

  /// Whether the keyboard is the current default input method.
  final bool isKeyboardSelected;
}
