import 'package:flutter/widgets.dart';

/// 모서리 둥글기. 값의 출처는 docs/DESIGN_SYSTEM.md.
abstract final class AppRadii {
  /// 카드 (기록 카드, 신호 카드, 그래프 카드, 액션 카드).
  static const card = 24.0;

  /// 버튼, 아이콘 타일, 출석 패널.
  static const button = 12.0;
  static const iconTile = 12.0;
  static const attendancePanel = 12.0;

  /// 출석 진행 알약.
  static const attendancePill = 10.0;

  /// 그래프 막대의 위쪽 모서리.
  static const graphBarTop = 5.0;

  /// 모달 창(추정, 토스 구조 참고)과 토스트(추정).
  static const dialog = 28.0;
  static const toast = 16.0;

  /// 완전한 원/알약 (칩, 아바타, 알림 버튼, 하단 탭 바).
  static const pill = 100.0;

  static const cardBorderRadius = BorderRadius.all(Radius.circular(card));
  static const buttonBorderRadius = BorderRadius.all(Radius.circular(button));
  static const dialogBorderRadius = BorderRadius.all(Radius.circular(dialog));
  static const toastBorderRadius = BorderRadius.all(Radius.circular(toast));
  static const pillBorderRadius = BorderRadius.all(Radius.circular(pill));
  static const graphBarBorderRadius = BorderRadius.only(
    topLeft: Radius.circular(graphBarTop),
    topRight: Radius.circular(graphBarTop),
  );
}
