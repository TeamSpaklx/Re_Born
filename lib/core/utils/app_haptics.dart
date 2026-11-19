import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../platform/android_haptics.dart';

/// 앱에서 쓰는 햅틱(진동) 피드백. 종류를 한 곳에서 정해서 화면마다 같은 느낌을 낸다.
///
/// - iOS: `HapticFeedback`(Taptic Engine)이 그대로 잘 느껴진다.
/// - Android: 기본 `HapticFeedback`이 기기에 따라 거의 안 느껴져서 [AndroidHaptics]로
///   기기 기본 효과를 재생한다. 네이티브를 못 부르면 기본 `HapticFeedback`으로 대신한다.
abstract final class AppHaptics {
  /// 탭 바에서 다른 탭으로 바꿀 때처럼 "선택이 바뀜".
  static Future<void> selection() =>
      _play('selection', HapticFeedback.selectionClick);

  /// 버튼·링크를 눌렀을 때 가벼운 톡.
  static Future<void> tap() => _play('tap', HapticFeedback.lightImpact);

  static Future<void> _play(
    String kind,
    Future<void> Function() fallback,
  ) async {
    if (defaultTargetPlatform == TargetPlatform.android &&
        await AndroidHaptics.play(kind)) {
      return;
    }
    await fallback();
  }
}
