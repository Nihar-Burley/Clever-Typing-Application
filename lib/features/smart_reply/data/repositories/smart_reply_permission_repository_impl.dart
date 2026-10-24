import '../../../../core/platform/keyboard_platform_service.dart';
import '../../domain/repositories/smart_reply_permission_repository.dart';

class SmartReplyPermissionRepositoryImpl
    implements SmartReplyPermissionRepository {
  const SmartReplyPermissionRepositoryImpl(this._platformService);

  final KeyboardPlatformService _platformService;

  @override
  Future<bool> isAccessibilityEnabled() {
    return _platformService.isAccessibilityCaptureEnabled();
  }

  @override
  Future<void> openAccessibilitySettings() {
    return _platformService.openAccessibilitySettings();
  }

  @override
  Future<String?> readLatestConversationContext() {
    return _platformService.readLatestConversationContext();
  }
}
