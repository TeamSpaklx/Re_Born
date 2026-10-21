import 'package:flutter/services.dart';

/// 앱에서 쓰는 햅틱(진동) 피드백. 종류를 한 곳에서 정해서 화면마다 같은 느낌을 낸다.
/// iOS(Taptic Engine)와 Android 모두 `HapticFeedback`이 알아서 처리한다.
abstract final class AppHaptics {
  /// 탭 바에서 다른 탭으로 바꿀 때처럼 "선택이 바뀜".
  static Future<void> selection() => HapticFeedback.selectionClick();

  /// 버튼·링크를 눌렀을 때 가벼운 톡.
  static Future<void> tap() => HapticFeedback.lightImpact();
}
