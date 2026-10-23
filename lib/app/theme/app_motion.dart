import 'package:flutter/animation.dart';

/// 움직임의 길이와 곡선. 화면 코드에 `Duration(milliseconds: …)`를 직접 쓰지 않고 이 값을 쓴다
/// (docs/DESIGN_SYSTEM.md 5장). 값은 토스 같은 앱의 느낌(짧고 부드러움)을 참고한 **추정**이다.
abstract final class AppMotion {
  /// 눌림 반응(불투명도).
  static const press = Duration(milliseconds: 100);

  /// 토글·칩 선택·체크·세그먼트 이동처럼 작은 요소의 상태 변화.
  static const fast = Duration(milliseconds: 200);

  /// 바텀시트·모달·화면 전환·카드 펼침.
  static const normal = Duration(milliseconds: 300);

  /// 맨 위로 스크롤처럼 긴 이동.
  static const slow = Duration(milliseconds: 500);

  /// 스켈레톤이 한 번 깜빡이는 시간.
  static const skeletonPulse = Duration(milliseconds: 1200);

  /// 나타날 때(감속), 사라질 때(가속), 위치가 바뀔 때.
  static const enter = Curves.easeOutCubic;
  static const exit = Curves.easeInCubic;
  static const move = Curves.easeInOutCubic;

  /// 눌렸을 때 불투명도와 크기 배율.
  static const pressedOpacity = 0.7;
  static const pressedScale = 0.97;
}
