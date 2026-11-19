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

  /// 바텀시트 카드 (Figma `834:1374`, 불투명도 0인 두 겹은 뺐다).
  static const sheet = [
    BoxShadow(color: Color(0x03000000), blurRadius: 55, offset: Offset(0, 92)),
    BoxShadow(color: Color(0x05000000), blurRadius: 41, offset: Offset(0, 41)),
    BoxShadow(color: Color(0x05000000), blurRadius: 22, offset: Offset(0, 10)),
  ];

  /// 토스트 (Figma `834:2088`: 0 6 20, 불투명도 6%).
  static const toast = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 20, offset: Offset(0, 6)),
  ];
}
