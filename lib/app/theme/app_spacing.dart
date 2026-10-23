import 'dart:ui' show Offset;

/// 간격과 크기. Figma 홈 화면(402×874 기준)에서 읽은 값이며 출처는 docs/DESIGN_HOME.md.
///
/// 화면 폭은 좌우 여백 [pageMargin]을 고정하고 카드가 남는 폭을 채운다(402일 때 354).
abstract final class AppSpacing {
  /// 디자인 기준 화면 크기.
  static const designWidth = 402.0;
  static const designHeight = 874.0;

  /// 좌우 여백.
  static const pageMargin = 24.0;

  /// 간격 스케일(4pt 체계). 새 화면의 여백·간격은 이 값 중에서 고른다.
  /// 홈 화면의 Figma 좌표값(22, 27, 35 등)은 아래 `HomeLayout`에 따로 둔다.
  static const space4 = 4.0;
  static const space8 = 8.0;
  static const space12 = 12.0;
  static const space16 = 16.0;
  static const space20 = 20.0;
  static const space24 = 24.0;
  static const space32 = 32.0;
  static const space40 = 40.0;
  static const space48 = 48.0;

  /// 터치할 수 있는 요소의 최소 크기(접근성).
  static const minTouchTarget = 44.0;

  /// 카드 폭 (디자인 기준, 실제로는 화면 폭 − 좌우 여백 × 2).
  static const designCardWidth = 354.0;

  /// 흰 카드가 테두리 자리로 남겨 두는 두께(수정안은 테두리 없음, 안쪽 좌표 유지용).
  static const cardBorderWidth = 2.0;

  /// 기록 카드(Before)의 테두리 선 두께.
  static const cardOutlineWidth = 1.0;

  /// 기록 카드 안쪽 여백.
  static const recordCardPadding = 20.0;

  /// 액션 카드(안부 묻기) 사이 간격.
  static const actionCardGap = 12.0;

  /// 홈 상단 바(고정) 뒤로 지나가는 내용에 주는 블러 강도 (추정, 사용자 첨부 사진 기준).
  static const topBarBlurSigma = 10.0;
}

/// 홈 화면 세부 치수. y는 Figma 프레임(Before) 기준 좌표이며 "참고용"이다.
/// 실제 배치는 세로 스택과 아래 간격으로 만들고, 이 값으로 결과를 대조한다.
abstract final class HomeLayout {
  // 헤더
  static const headerLogoWidth = 169.0;
  static const headerLogoHeight = 42.0;
  static const bellButtonSize = 44.0;
  static const bellIconSize = 30.0;

  /// 로고를 누르면 맨 위로 올라가는 시간. Figma에 지정이 없어 정한 임시값(팀 확인 필요).
  static const scrollToTopDuration = Duration(milliseconds: 500);

  /// 제안을 담은 뒤 채워진 원을 보여 주는 시간(그 뒤 다음 제안이 온다). 임시값.
  static const suggestionSwapDelay = Duration(milliseconds: 700);

  // 카드 높이
  static const recordCardHeightBefore = 268.0;

  /// 출석 체크 패널을 보일지. 지금은 숨긴다(2026-10-24). 켜면 After 카드가 Figma 높이(399)로 돌아온다.
  static const showAttendance = false;

  /// After 카드 높이. 출석 패널을 숨기면 안쪽 내용 높이에 맞춰 줄어들도록 null.
  static const double? recordCardHeightAfter = showAttendance ? 399.0 : null;
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
  static const recordCardToSignalTitle = 22.0;
  static const sectionTitleHeight = 32.0;
  static const sectionTitleToCard = 12.0;
  static const signalCardToGraph = 22.0;
  static const graphToActionTitle = 27.0;

  // 참고 y 좌표 (Before)
  static const dateY = 128.0;
  static const greetingY = 149.0;
  static const recordCardY = 237.0;
  static const signalTitleY = 527.0;
  static const signalCardY = 571.0;
  static const graphCardY = 697.0;
  static const actionTitleY = 904.0;
  static const actionCardY1 = 948.0;
  static const actionCardY2 = 1050.0;

  // 기록 카드(Before) 안쪽: 여우원숭이 일러스트(Figma `736:309`). 박스 151×98 안에 이미지 높이 ≈151(153.85%)을
  // 위쪽 정렬로 놓아 아래가 잘리고, 버튼 뒤에서 머리·귀·꼬리만 보인다.
  static const mascotWidth = 151.0;
  static const mascotHeight = 98.0;
  static const mascotImageHeight = 150.77;

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

  /// 막대가 서는 바닥선 y (카드 안쪽), 선 x=18, 폭 314. 위쪽 격자선 3개(y 61/82/103)는 최신 안에서 숨겨져 있다.
  static const baselineY = 124.0;
  static const gridLeft = 18.0;
  static const gridWidth = 314.0;

  /// 막대가 서는 바닥 y와 가장 높은 막대(금요일 예시)의 높이.
  static const barBottomY = 126.0;
  static const maxBarHeight = 75.806;

  /// 막대 색 구간(값 0~1): 이 값 이하는 진한 색, 그다음 이 값 이하는 중간 색, 그 위는 연한 색.
  /// Figma(`8632:1470`)에 규칙이 없어 샘플 막대(월·화·목 ≤0.48 진함, 수·토 0.63~0.87 중간,
  /// 금 1.0 연함)에서 정했다. (추정, 확인 필요)
  static const barStrongMax = 0.5;
  static const barMidMax = 0.9;

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

  // 아래 시간은 모두 Figma에 지정이 없어 정한 임시값(팀 확인 필요).

  /// 로고를 최소한 이만큼은 보여 준다(로딩이 빨라도 번쩍 사라지지 않게).
  static const minDuration = Duration(milliseconds: 800);

  /// 로딩이 끝나지 않아도 이 시간이 지나면 홈으로 넘어간다.
  static const maxDuration = Duration(seconds: 3);

  /// 홈이 로고 화면 위로 서서히 나타나는 시간(크로스페이드).
  static const fadeDuration = Duration(milliseconds: 400);
}

/// 공통 컴포넌트(토글·모달·토스트·설정 목록) 치수. Figma에 없는 값이라 모두 추정이다
/// (토스 설정·로그아웃 화면의 구조를 참고하고 Reborn 색·모서리로 정함, 확인 필요).
abstract final class ComponentLayout {
  // 토글: iOS식 알약
  static const toggleWidth = 51.0;
  static const toggleHeight = 31.0;
  static const toggleThumb = 27.0;
  static const toggleThumbInset = 2.0;
  static const toggleMinHit = 44.0;
  static const toggleDuration = Duration(milliseconds: 200);

  // 모달
  static const dialogMargin = 24.0;
  static const dialogPadding = 24.0;
  static const dialogButtonHeight = 52.0;
  static const dialogButtonGap = 12.0;

  // 토스트: 전체 시간 안에 나타남 → 머묾 → 사라짐이 모두 들어 있다.
  static const toastTotal = Duration(milliseconds: 3000);
  static const toastFade = Duration(milliseconds: 250);
  static const toastGapAboveNav = 16.0;
  static const toastPaddingH = 20.0;
  static const toastPaddingV = 14.0;
  static const toastRiseOffset = 12.0;

  // 입력창
  static const inputBorderWidth = 1.5;
  static const inputPadding = 16.0;

  // 세그먼트 컨트롤
  static const segmentedHeight = 44.0;
  static const segmentedPadding = 4.0;

  // 바텀시트
  static const sheetHandleWidth = 40.0;
  static const sheetHandleHeight = 4.0;
  static const sheetMaxHeightFraction = 0.9;
  static const sheetOptionHeight = 56.0;

  // 하단 고정 CTA 바
  static const ctaBarTop = 12.0;
  static const ctaBarBottom = 16.0;
  static const ctaButtonHeight = 52.0;

  // 체크 행 · 프로필 행 · 뱃지
  static const checkSize = 24.0;
  static const profileAvatarSize = 56.0;
  static const badgeDot = 8.0;
  static const badgeCountHeight = 18.0;

  // 빈·오류 상태
  static const stateMascotSize = 120.0;
  static const stateButtonWidth = 200.0;

  // 스켈레톤
  static const skeletonPulseMin = 0.55;

  // 설정 목록
  static const settingsRowHeight = 56.0;
  static const settingsGroupPaddingH = 20.0;
  static const settingsGroupTitleHeight = 52.0;
}
