/// 간격과 크기. Figma 홈 화면(402×874 기준)에서 읽은 값이며 출처는 docs/DESIGN_SYSTEM.md.
///
/// 화면 폭은 좌우 여백 [pageMargin]을 고정하고 카드가 남는 폭을 채운다(402일 때 354).
abstract final class AppSpacing {
  /// 디자인 기준 화면 크기.
  static const designWidth = 402.0;
  static const designHeight = 874.0;

  /// 좌우 여백.
  static const pageMargin = 24.0;

  /// 카드 폭 (디자인 기준, 실제로는 화면 폭 − 좌우 여백 × 2).
  static const designCardWidth = 354.0;

  /// 흰 카드 테두리 두께.
  static const cardBorderWidth = 2.0;

  /// 기록 카드 안쪽 여백.
  static const recordCardPadding = 20.0;

  /// 액션 카드(안부 묻기) 사이 간격.
  static const actionCardGap = 12.0;

  /// 상단 그라디언트가 흰색이 되는 높이. Figma는 프레임 높이의 4.327%이며
  /// Before(1205) 기준 약 52px이다. (추정, 확인 필요)
  static const backgroundGradientHeight = 52.0;
}

/// 홈 화면 세부 치수. y는 Figma 프레임(Before) 기준 좌표이며 "참고용"이다.
/// 실제 배치는 세로 스택과 아래 간격으로 만들고, 이 값으로 결과를 대조한다.
abstract final class HomeLayout {
  // 헤더
  static const headerLogoWidth = 169.0;
  static const headerLogoHeight = 42.0;
  static const bellButtonSize = 44.0;

  // 카드 높이
  static const recordCardHeightBefore = 172.0;
  static const recordCardHeightAfter = 399.0;
  static const ctaButtonHeightBefore = 52.0;
  static const ctaButtonHeightAfter = 48.0;
  static const signalCardHeight = 104.0;
  static const graphCardHeight = 180.0;
  static const actionCardHeight = 90.0;

  // 참고 y 좌표 (Before)
  static const dateY = 128.0;
  static const greetingY = 149.0;
  static const recordCardY = 237.0;
  static const signalTitleY = 444.0;
  static const signalCardY = 488.0;
  static const graphCardY = 614.0;
  static const actionTitleY = 821.0;
  static const actionCardY1 = 865.0;
  static const actionCardY2 = 967.0;

  // 아이콘·아바타
  static const avatarSize = 48.0;
  static const personIconSize = 36.0;
  static const iconTileSize = 48.0;
  static const forumIconSize = 36.0;
  static const radioSize = 20.0;
}

/// 감정 그래프(주간 막대) 치수. 카드 안쪽 좌표 기준.
abstract final class GraphLayout {
  static const barWidth = 27.437;

  /// 막대 x 좌표(월~일). 간격은 47.76.
  static const barLefts = [20.0, 67.76, 115.52, 163.28, 211.04, 258.8];

  /// 가로 격자선 y (카드 안쪽) 4개, 선 x=18, 폭 314.
  static const gridLineYs = [61.0, 82.0, 103.0, 124.0];
  static const gridLeft = 18.0;
  static const gridWidth = 314.0;

  /// 막대가 서는 바닥 y와 가장 높은 막대(금요일 예시)의 높이.
  static const barBottomY = 126.0;
  static const maxBarHeight = 75.806;

  static const weekdayLabelY = 135.0;
  static const captionY = 159.0;
}

/// 출석 체크 패널 치수 (After 기록 카드 안).
abstract final class AttendanceLayout {
  static const panelWidth = 313.0;
  static const panelHeight = 110.0;
  static const pillWidth = 43.0;
  static const pillHeight = 13.0;
  static const pillGap = 5.0;
  static const pillCount = 6;
}
