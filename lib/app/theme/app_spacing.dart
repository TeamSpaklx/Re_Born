import 'dart:ui' show Offset;

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

  /// 상단 핑크 그라디언트 높이. Figma 코드값(rgba(217,79,121,0.8) → 흰색, 4.327%)은 실제 화면과
  /// 달라서, Figma 스크린샷(`docs/design/home_before.png`)의 색을 10px 간격으로 재서 정했다.
  /// 맨 위 불투명도가 약 0.40이고 아래로 부드럽게 줄어 120px 근처에서 흰색이 된다. (추정, 확인 필요)
  static const backgroundGradientHeight = 120.0;

  /// 홈 상단 바(고정) 뒤로 지나가는 내용에 주는 블러 강도 (추정, 사용자 첨부 사진 기준).
  static const topBarBlurSigma = 10.0;

  /// 0px부터 10px 간격(0~120px)의 핑크(`backgroundGradientTop`의 RGB) 불투명도.
  static const backgroundGradientAlphas = [
    0.40,
    0.36,
    0.31,
    0.26,
    0.22,
    0.17,
    0.13,
    0.09,
    0.07,
    0.04,
    0.02,
    0.01,
    0.0,
  ];
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

  // 세로 간격 (Before). 위 요소의 아래 끝에서 다음 요소의 위까지.
  static const headerHeight = 62.0;
  static const headerToDate = 4.0;
  static const dateHeight = 17.0;
  static const dateToGreeting = 4.0;
  static const greetingToRecordCard = 24.0;
  static const recordCardToSignalTitle = 35.0;
  static const sectionTitleHeight = 32.0;
  static const sectionTitleToCard = 12.0;
  static const signalCardToGraph = 22.0;
  static const graphToActionTitle = 27.0;

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

  static const weekdayLabelY = 135.5;

  /// 요일 라벨(월~일) 왼쪽 x.
  static const weekdayLabelLefts = [
    27.113,
    74.874,
    122.634,
    170.395,
    219.172,
    266.932,
    314.693,
  ];

  /// 카드 안쪽(테두리 안) 디자인 폭. 폭이 다르면 가로 좌표를 이 비율로 맞춘다.
  static const designInnerWidth = 350.0;
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

/// 스플래시 화면 치수 (Figma 402×874 "스플릿 화면", 로고는 화면 정중앙).
abstract final class SplashLayout {
  static const logoSize = 200.0;

  /// Figma는 이미지를 박스 안에서 left −0.4%, top −0.85% 옮겨 놓았다(200 기준 −0.8, −1.7px).
  static const logoOffset = Offset(-0.8, -1.7);

  /// 로고를 보여 주는 시간. Figma에 지정이 없어 정한 임시값(팀 확인 필요).
  static const duration = Duration(milliseconds: 1200);
}
