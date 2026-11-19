import 'package:flutter/services.dart';

/// Android 햅틱 경계. 네이티브 쪽은 `MainActivity.kt`의 `reborn/haptics` 채널.
///
/// Flutter 기본 `HapticFeedback`은 Android에서 `View.performHapticFeedback`을 써서
/// 기기에 따라 거의 느껴지지 않는다. 그래서 기기가 맞춰 둔 기본 진동 효과(틱·클릭)를 직접 재생한다.
abstract final class AndroidHaptics {
  static const _channel = MethodChannel('reborn/haptics');

  /// [kind]: `selection`(틱) 또는 `tap`(클릭).
  /// 네이티브가 없으면(테스트 등) false를 돌려주고, 호출한 쪽이 기본 햅틱으로 대신한다.
  static Future<bool> play(String kind) async {
    try {
      await _channel.invokeMethod<void>(kind);
      return true;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
