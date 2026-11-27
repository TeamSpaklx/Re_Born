import 'package:flutter/painting.dart' show Alignment, Offset;

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
  static const graphCardHeight = 180.0;
  static const actionCardHeight = 90.0;

  // 세로 간격 (Before). 위 요소의 아래 끝에서 다음 요소의 위까지.
  static const headerHeight = 62.0;
  static const headerToDate = 4.0;
  static const dateHeight = 17.0;
  static const dateToGreeting = 4.0;
  static const greetingToRecordCard = 24.0;
  static const recordCardToGraph = 22.0;
  static const sectionTitleHeight = 32.0;
  static const sectionTitleToCard = 12.0;
  static const graphToActionTitle = 27.0;

  // 참고 y 좌표 (Before)
  static const dateY = 128.0;
  static const greetingY = 149.0;
  static const recordCardY = 237.0;
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

/// 스플래시 화면 치수 (Figma 402×874 "스플릿 화면" 805:953, 로고는 화면 정중앙).
abstract final class SplashLayout {
  static const logoSize = 160.0;

  /// Figma는 이미지를 박스 안에서 left −0.4%, top −0.85% 옮겨 놓았다(160 기준 −0.64, −1.36px).
  static const logoOffset = Offset(-0.64, -1.36);

  /// 하단 "TeamSpaklx"의 아래 여백: Figma에서 글자 상자 아래가 화면 아래에서 66px,
  /// 홈 인디케이터 영역(34px)을 빼면 안전 영역 위로 32px.
  static const brandBottom = 32.0;

  // 아래 시간은 모두 Figma에 지정이 없어 정한 임시값(팀 확인 필요).

  /// 로고를 최소한 이만큼은 보여 준다(로딩이 빨라도 번쩍 사라지지 않게).
  static const minDuration = Duration(milliseconds: 1000);

  /// 로딩이 끝나지 않아도 이 시간이 지나면 투데이로 넘어간다.
  static const maxDuration = Duration(seconds: 3);

  /// 투데이가 로고 화면 위로 서서히 나타나는 시간(크로스페이드).
  static const fadeDuration = Duration(milliseconds: 400);
}

/// 인트로 온보딩 화면 (Figma 8877:1945, 402×874 기준, 상태 바 62 포함).
abstract final class IntroLayout {
  /// 앱 화면 목업 상자 314×490. 상단은 화면 위에서 101px.
  static const previewWidth = 314.0;
  static const previewHeight = 490.0;
  static const previewTop = 101.0;

  /// 목업 이미지는 상자 안에서 위로 4.1% 내려 놓고, 높이를 상자의 132.9%로 키워 아래를 잘라 낸다.
  static const previewImageTopFactor = 0.041;
  static const previewImageHeightFactor = 1.329;

  /// 목업 아래쪽이 흰색으로 사라지는 구간 26px (목업 상자 아래 끝에서 위로 확장해 겹침).
  static const previewFade = 26.0;

  /// 목업 아래 끝에서 제목 상자까지: Figma 목업 끝 591 → 글자 묶음 시작 598.
  static const previewToText = 7.0;

  /// 제목 상자 안 위 여백: 상자 높이 32 / 글자 묶음 시작에서 제목 위까지 15.
  static const titleTop = 15.0;

  /// 제목 아래 ~ 설명 사이 (제목 끝 47 → 설명 시작 59).
  static const titleToBody = 12.0;

  /// 설명 아래 ~ 버튼 사이 (설명 끝 97 → 버튼 시작 162).
  static const bodyToCta = 65.0;

  static const ctaHeight = 60.0;

  /// 버튼 아래 여백: 버튼 끝이 화면 위에서 820 → 화면 끝 874에서 홈 인디케이터(34)를 빼면 안전 영역 위로 20px.
  static const ctaBottom = 20.0;

  /// 상태 바 높이(62)를 뺀 목업 위 여백. 기기마다 다른 상태 바는 안전 영역이 맡는다.
  static const previewTopInset = previewTop - 62.0;
}

/// 인트로 끝 "시작할 준비가 끝났어요" 화면 (Figma 8877:1965, 402×874 기준, 상태 바 62 포함).
abstract final class StartLayout {
  /// 제목 가운데가 화면 위에서 128 → 상태 바를 뺀 위 여백. 제목 상자 높이 32라 위쪽은 112.
  static const titleTop = 112.0 - 62.0;

  /// 제목 가운데 128 ~ 설명 가운데 180, 설명 두 줄(24씩) 상자 높이 48이라 시작은 156. 제목 끝 144 → 12.
  static const titleToBody = 12.0;

  /// 목업 상자 338×560(가로 가운데), 위 240에서 상태 바 62를 뺀 178, 불투명도 82%.
  static const previewTop = 240.0 - 62.0;
  static const previewWidth = 338.0;
  static const previewHeight = 560.0;
  static const previewOpacity = 0.82;

  /// 목업 이미지는 상자 안에서 너비 235.76%, 높이 138.07%, 왼쪽 −66.04%, 위 −18.78%.
  static const imageWidthFactor = 2.3576;
  static const imageHeightFactor = 1.3807;
  static const imageLeftFactor = -0.6604;
  static const imageTopFactor = -0.1878;

  /// 아래 그라데이션: 높이 254, 위(투명) → 52%부터 검정. 버튼은 그 안 위에서 144.
  static const fadeHeight = 254.0;
  static const fadeSolidFrom = 0.52;
  static const ctaHeight = 60.0;

  /// 버튼 아래 여백: 버튼 끝 620+144+60 = 824 → 화면 끝 874에서 홈 인디케이터(34)를 빼면 안전 영역 위로 16px.
  static const ctaBottom = 16.0;
}

/// 공통 컴포넌트 치수. 토글·세그먼트·토스트·바텀시트·CTA·알림 버튼·스켈레톤은
/// Figma 컴포넌트 섹션(`749:337`) 값이고, 모달·설정 목록·애니메이션 시간은 Figma에 없어 추정이다.
/// 이메일 로그인 화면. 워드마크·좌우 여백·약관 아래 여백은 Figma 로그인(8877:1929, 402×874) 값이고,
/// 입력 폼 자리는 Figma에 없어 추정이다.
abstract final class LoginLayout {
  /// RE:BORN 워드마크 314×78.
  static const logoWidth = 314.0;
  static const logoHeight = 78.0;

  /// 워드마크 아래에서 이메일 입력까지(추정).
  static const logoToForm = 48.0;

  /// 로그인 버튼 높이 55(예전 소셜 버튼과 같은 높이), 좌우 44.
  static const buttonHeight = 55.0;
  static const horizontalMargin = 44.0;

  /// 약관 안내 아래 여백: Figma에서 글자 아래가 화면 아래에서 48px, 홈 인디케이터(34)를 빼면 안전 영역 위로 14px.
  static const legalBottom = 14.0;
}

abstract final class ComponentLayout {
  // 토글 (Figma `834:1302`): 64×28 알약, 흰 손잡이 38×24, 안쪽 2.
  static const toggleWidth = 64.0;
  static const toggleHeight = 28.0;
  static const toggleThumbWidth = 38.0;
  static const toggleThumbHeight = 24.0;
  static const toggleThumbInset = 2.0;
  static const toggleMinHit = 44.0;
  static const toggleDuration = Duration(milliseconds: 200);

  // 모달
  static const dialogMargin = 24.0;
  static const dialogPadding = 24.0;
  static const dialogButtonHeight = 52.0;
  static const dialogButtonGap = 12.0;

  // 토스트 (Figma `834:2088`): 흰 알약, 좌우 16, 간격 12, 체크 원 28, '확인' 터치 영역 32×44.
  // 시간(전체 3초 안에 나타남 → 머묾 → 사라짐)은 추정.
  static const toastTotal = Duration(milliseconds: 3000);
  static const toastFade = Duration(milliseconds: 250);
  static const toastGapAboveNav = 16.0;
  static const toastHeight = 64.0;
  static const toastPaddingH = 16.0;
  static const toastGap = 12.0;
  static const toastCheckSize = 28.0;
  static const toastActionWidth = 32.0;
  static const toastBorderWidth = 1.0;
  static const toastRiseOffset = 12.0;

  // 입력창
  static const inputBorderWidth = 1.5;
  static const inputPadding = 16.0;

  // 세그먼트 컨트롤 (Figma `834:1232`): 흰 트랙 안쪽 좌우 6·상하 5, 칸 높이 36, 칸 사이 20.
  static const segmentHeight = 36.0;
  static const segmentPaddingH = 6.0;
  static const segmentPaddingV = 5.0;
  static const segmentGap = 20.0;
  static const segmentIconSize = 24.0;
  static const segmentDuration = Duration(milliseconds: 200);

  // 바텀시트 (Figma `834:1374`): 화면 좌우 24 띄운 카드, 안쪽 위 12·좌우 20·아래 20.
  static const sheetMargin = 24.0;
  static const sheetPaddingTop = 12.0;
  static const sheetPaddingH = 20.0;
  static const sheetPaddingBottom = 20.0;
  static const sheetHandleWidth = 40.0;
  static const sheetHandleHeight = 4.0;
  static const sheetHandleRadius = 2.0;
  static const sheetHandleGap = 24.0;
  static const sheetHeaderPaddingH = 4.0;
  static const sheetHeaderGap = 12.0;
  static const sheetMaxHeightFraction = 0.9;
  static const sheetOptionHeight = 56.0;
  static const sheetIconSize = 24.0;
  static const sheetIconGap = 16.0;

  // 바텀시트 끌기 (토스식, Figma에 없어 추정): 시트 높이의 25% 넘게 내리거나 초당 700 넘게 아래로 튕기면 닫히고,
  // 위로는 저항이 붙어 최대 24까지만 늘어난다.
  static const sheetDismissFraction = 0.25;
  static const sheetDismissVelocity = 700.0;
  static const sheetOverDrag = 24.0;

  /// 카드 아래 여백의 최솟값. Figma는 카드 아래가 홈 인디케이터 영역(34) 바로 위라 안전 영역만큼 띄우고,
  /// 안전 영역이 없는 기기(안드로이드 버튼 내비 등)는 좌우와 같은 24를 띄운다.
  static const sheetMinBottomGap = 24.0;

  // 하단 고정 CTA 바 (Figma CTA `862:2951`: 높이 60 알약).
  static const ctaBarTop = 12.0;
  static const ctaBarBottom = 16.0;
  static const ctaButtonHeight = 60.0;

  /// 이 높이 이상인 CTA(하단 고정 버튼)는 Figma CTA 글자 18을 쓴다.
  /// 카드 안 버튼은 각자 Figma 값을 유지한다: 52 이상은 16(기록 카드 "감정 기록하기"), 그보다 낮으면 14.
  static const ctaLargeTextMinHeight = 60.0;
  static const ctaMediumTextMinHeight = 52.0;

  // 알림 종 버튼 (Figma `828:955`): 44 원, 종 24.
  static const bellButtonSize = 44.0;
  static const bellIconSize = 24.0;

  // 스켈레톤: 깜빡임(불투명도 1 ↔ 0.5) 한 번 왕복 시간. Figma에 없어 추정.
  static const skeletonPulse = Duration(milliseconds: 1200);
  static const skeletonMinOpacity = 0.5;

  // 가운데 제목 상단 바 (Figma 알림 `834:1149`): 높이 44, 아이콘 24.
  static const centerTitleBarHeight = 44.0;
  static const topBarIconSize = 24.0;

  // 체크 행 · 프로필 행 · 뱃지
  static const checkSize = 24.0;
  static const profileAvatarSize = 56.0;
  static const badgeDot = 8.0;
  static const badgeCountHeight = 18.0;

  // 빈·오류 상태
  static const stateMascotSize = 120.0;

  /// 알림 빈 화면 마스코트 (Figma `875:2965`, 151×151).
  static const emptyMascotLarge = 151.0;

  /// 조용한 빈 화면의 세로 위치: 남는 영역에서 가운데보다 조금 위(Figma 마스코트 top 346을 맞춘 값).
  static const quietEmptyAlignment = Alignment(0, -0.3);

  // 앱 잠금 화면 (Figma 834:2141). 로고는 스플래시와 같은 [SplashLayout] 값을 쓴다.
  /// "인증에 실패하거나…" 버튼 314×45, 글자는 가운데.
  static const lockHelpWidth = 314.0;
  static const lockHelpHeight = 45.0;

  /// 버튼 아래 여백: Figma에서 버튼 아래가 화면 아래에서 64px, 홈 인디케이터(34)를 빼면 안전 영역 위로 30px.
  static const lockHelpBottom = 30.0;

  /// 가운데 제목 바 아래에서 세그먼트까지 (Figma 알림: 바 아래 106 → 세그먼트 139).
  static const centerTitleToSegment = 33.0;
  static const stateButtonWidth = 200.0;

  // 설정 목록 (토스·레퍼런스 설정 화면을 참고한 추정값)
  static const settingsRowHeight = 60.0;
  static const settingsGroupPaddingH = 20.0;

  /// 카드 밖 회색 소제목과 카드 사이.
  static const settingsGroupTitleGap = 8.0;

  /// 행 왼쪽 아이콘 24와 글자 사이 16.
  static const settingsIconSize = 24.0;
  static const settingsIconGap = 16.0;

  /// 행 오른쪽 꺾쇠(Iconsax `arrow-right-1`) 크기. 예전 Figma 꺾쇠와 같은 20.
  static const settingsChevronSize = 20.0;

  /// 행 사이 구분선 두께.
  static const settingsDividerWidth = 1.0;

  /// 안내 카드 안쪽 여백과 제목·설명 사이.
  static const settingsInfoPadding = 20.0;
  static const settingsInfoTextGap = 4.0;
}
