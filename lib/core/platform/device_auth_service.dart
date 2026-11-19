import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// 기기에서 쓸 수 있는 잠금 해제 수단. 설정 화면 문구("앱 잠금 (Face ID)")에 쓴다.
enum DeviceAuthKind {
  faceId('Face ID'),
  touchId('Touch ID'),
  fingerprint('지문'),
  biometric('생체 인증'),
  passcode('기기 암호'),

  /// 기기에 화면 잠금(암호)이 없어 앱 잠금을 쓸 수 없다.
  none('');

  const DeviceAuthKind(this.label);

  final String label;
}

/// 인증 결과. `local_auth` 오류 코드는 [LocalAuthDeviceAuthService]에서만 해석한다.
sealed class DeviceAuthResult {
  const DeviceAuthResult();
}

/// 인증 성공.
final class DeviceAuthSuccess extends DeviceAuthResult {
  const DeviceAuthSuccess();
}

/// 얼굴·지문이 맞지 않았거나 사용자가 취소했다. 다시 시도할 수 있다.
final class DeviceAuthFailed extends DeviceAuthResult {
  const DeviceAuthFailed();
}

/// 너무 많이 실패해 생체 인증이 잠겼다. 기기 암호로는 풀 수 있다.
final class DeviceAuthLockedOut extends DeviceAuthResult {
  const DeviceAuthLockedOut();
}

/// 기기에 화면 잠금이 없거나 인증 장치를 쓸 수 없다. 앱 잠금을 유지하면 영영 못 들어가므로 잠금을 끈다.
final class DeviceAuthUnavailable extends DeviceAuthResult {
  const DeviceAuthUnavailable();
}

/// 기기 인증(Face ID·Touch ID·지문·기기 암호) 경계. 테스트에서는 가짜로 바꿔 끼운다.
abstract interface class DeviceAuthService {
  /// 지금 기기에서 쓸 수 있는 대표 수단. 화면 잠금이 없으면 [DeviceAuthKind.none].
  Future<DeviceAuthKind> availableKind();

  /// 시스템 인증 창을 띄운다. 생체 인증이 실패하면 기기 암호로도 풀 수 있다.
  Future<DeviceAuthResult> authenticate({required String reason});

  /// 앱 전환 화면에 앱 미리보기를 남길지(Android 13+만, 나머지는 아무 일 없음).
  Future<void> setRecentsPreviewHidden(bool hidden);
}

/// `local_auth`로 만든 실제 구현.
class LocalAuthDeviceAuthService implements DeviceAuthService {
  LocalAuthDeviceAuthService([LocalAuthentication? auth])
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  static const _channel = MethodChannel('reborn/app_lock');

  @override
  Future<DeviceAuthKind> availableKind() async {
    try {
      if (!await _auth.isDeviceSupported()) return DeviceAuthKind.none;
      final types = await _auth.getAvailableBiometrics();
      final ios = defaultTargetPlatform == TargetPlatform.iOS;
      if (types.contains(BiometricType.face)) {
        return ios ? DeviceAuthKind.faceId : DeviceAuthKind.biometric;
      }
      if (types.contains(BiometricType.fingerprint)) {
        return ios ? DeviceAuthKind.touchId : DeviceAuthKind.fingerprint;
      }
      if (types.isNotEmpty) return DeviceAuthKind.biometric;
      return DeviceAuthKind.passcode;
    } on PlatformException {
      return DeviceAuthKind.none;
    } on LocalAuthException {
      return DeviceAuthKind.none;
    }
  }

  @override
  Future<DeviceAuthResult> authenticate({required String reason}) async {
    try {
      final ok = await _auth.authenticate(
        localizedReason: reason,
        // 생체 인증이 안 되면 기기 암호(PIN)로 풀 수 있게 한다.
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
      return ok ? const DeviceAuthSuccess() : const DeviceAuthFailed();
    } on LocalAuthException catch (e) {
      return switch (e.code) {
        // 화면 잠금(암호) 자체가 없을 때만. 생체 인증만 없으면 기기 암호로 풀 수 있다.
        LocalAuthExceptionCode.noCredentialsSet =>
          const DeviceAuthUnavailable(),
        LocalAuthExceptionCode.temporaryLockout ||
        LocalAuthExceptionCode.biometricLockout => const DeviceAuthLockedOut(),
        _ => const DeviceAuthFailed(),
      };
    } on PlatformException {
      return const DeviceAuthFailed();
    }
  }

  @override
  Future<void> setRecentsPreviewHidden(bool hidden) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _channel.invokeMethod<void>('setRecentsPreviewHidden', hidden);
    } on PlatformException {
      // 미리보기 숨김은 보조 수단이라 실패해도 Flutter 덮개가 가린다.
    } on MissingPluginException {
      // 테스트 등 네이티브가 없는 환경.
    }
  }
}
