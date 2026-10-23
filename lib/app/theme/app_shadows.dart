import 'package:flutter/painting.dart';

/// 그림자 3단계. 카드는 그림자 없이 배경색 차이로 구분하고(flat), 떠 있는 요소만 쓴다
/// (docs/DESIGN_SYSTEM.md 4장). 색은 검정 불투명도만 써서 다크 모드에서도 자연스럽다.
abstract final class AppShadows {
  /// 세그먼트의 선택된 알약, 토글 동그라미처럼 아주 약한 입체감.
  static const subtle = [
    BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 2)),
  ];

  /// 하단 탭 바처럼 화면 위에 떠 있는 요소 (Figma `0 4 25 4`, 불투명도 10%).
  static const floating = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 25,
      spreadRadius: 4,
      offset: Offset(0, 4),
    ),
  ];

  /// 바텀시트처럼 가림막 위에 올라오는 큰 요소 (추정).
  static const overlay = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 24, offset: Offset(0, -4)),
  ];
}
