import 'package:flutter/material.dart';

/// 앱에서 쓰는 모든 색. 화면에서 `Color(0x...)`를 직접 쓰지 않고 이 값만 쓴다.
///
/// 팔레트는 [AppColors.light]와 [AppColors.dark] 두 벌이고, 같은 필드를 가진다.
/// 설정의 다크 모드 토글이 둘 중 어느 쪽을 `ThemeData.extensions`에 넣을지 정한다.
/// 값의 출처는 docs/DESIGN_SYSTEM.md.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.brand,
    required this.cta,
    required this.onCta,
    required this.background,
    required this.cardPink,
    required this.cardWhite,
    required this.cardBorder,
    required this.iconStrong,
    required this.iconMuted,
    required this.textBlack,
    required this.textStrong,
    required this.textSecondary,
    required this.textDate,
    required this.textGraphCaption,
    required this.emoji,
    required this.chip,
    required this.avatar,
    required this.iconTile,
    required this.gridLine,
    required this.attendancePanel,
    required this.onAttendancePanel,
    required this.bellButton,
    required this.navFill,
    required this.navBorder,
    required this.navShadow,
    required this.navSelection,
    required this.navActive,
    required this.recordCardSubtitle,
    required this.ctaSoft,
    required this.onCtaSoft,
    required this.barStrong,
    required this.barMid,
    required this.barLight,
    required this.toggleOff,
    required this.danger,
    required this.dangerTile,
    required this.ctaPrimary,
    required this.toggleOn,
    required this.segmentTrack,
    required this.segmentSelected,
    required this.sheetHandle,
    required this.sheetTitle,
    required this.sheetRowText,
    required this.sheetSurface,
    required this.toastSurface,
    required this.toastBorder,
    required this.toastText,
    required this.toastAccent,
    required this.toastCheckFill,
    required this.skeleton,
    required this.emptyText,
    required this.scrim,
    required this.topBarTint,
    required this.splashBackground,
    required this.lockHelpText,
    required this.lockHelpPressed,
    required this.kakaoYellow,
    required this.onKakao,
    required this.socialSurface,
    required this.onSocial,
    required this.socialBorder,
    required this.loginLegalText,
    required this.startBackground,
    required this.startTitle,
    required this.startBody,
    required this.onStartCta,
    required this.emotionJoy,
    required this.emotionLove,
    required this.emotionExcited,
    required this.emotionNeutral,
    required this.emotionAnxiety,
    required this.emotionAnger,
    required this.emotionSadness,
  });

  /// 브랜드 핑크: 그래프 막대, 활성 탭, 강조 숫자, 출석 알약.
  final Color brand;

  /// 주요 버튼 배경 (감정 기록하기 / 오늘 기록 보기).
  final Color cta;
  final Color onCta;

  /// 화면 배경 `#F2F2F4` (홈 리디자인). 흰 카드가 배경과 구분된다.
  final Color background;

  /// 기록 카드(핑크)와 흰 카드, 흰 카드의 테두리.
  final Color cardPink;
  final Color cardWhite;
  final Color cardBorder;

  /// 진한 화살표(그래프·섹션 제목 옆). SVG에 박힌 #1C1B1F 대신 칠한다.
  final Color iconStrong;

  /// 옅은 화살표·원(행 화살표, 전체 보기, 선택 원). SVG에 박힌 #4C535F 대신 칠한다.
  final Color iconMuted;

  final Color textBlack;
  final Color textStrong;
  final Color textSecondary;
  final Color textDate;
  final Color textGraphCaption;
  final Color emoji;

  final Color chip;
  final Color avatar;
  final Color iconTile;
  final Color gridLine;

  final Color attendancePanel;
  final Color onAttendancePanel;
  final Color bellButton;

  /// 하단 탭 바.
  final Color navFill;
  final Color navBorder;
  final Color navShadow;
  final Color navSelection;

  /// 하단 탭에서 선택된 탭의 아이콘·라벨 색 (Figma `ButtonNavigator` 749:1100의 #D94F79).
  final Color navActive;

  /// 기록 카드(흰색, Before) 부제.
  final Color recordCardSubtitle;

  /// 연한 핑크 버튼 배경(기록 카드 Before의 "감정 기록하기").
  final Color ctaSoft;

  /// 연한 핑크 버튼 위 글자.
  final Color onCtaSoft;

  /// 그래프 막대 색 3단계: 진함(낮은 값) / 중간 / 연함(높은 값).
  final Color barStrong;
  final Color barMid;
  final Color barLight;

  /// 토글 꺼짐 배경 rgba(60,60,67,0.3) (Figma `834:1333`).
  final Color toggleOff;

  /// 삭제·로그아웃 같은 위험한 동작 글자 (Figma에 없음, 추정).
  final Color danger;

  /// 위험한 동작 버튼 배경 (추정).
  final Color dangerTile;

  /// 주요 CTA 배경 #FF80A6 (Figma CTA `862:2951`). 글자는 [onCta].
  final Color ctaPrimary;

  /// 토글 켜짐 배경 #FFAFC7 (Figma `834:1302`).
  final Color toggleOn;

  /// 세그먼트 바깥 트랙(흰 알약)과 선택된 칸 #F2F2F4 (Figma `834:1248`).
  final Color segmentTrack;
  final Color segmentSelected;

  /// 바텀시트 손잡이·제목·행 글자 (Figma `834:1374`).
  final Color sheetHandle;
  final Color sheetTitle;
  final Color sheetRowText;

  /// 토스트 테두리·문구·강조(체크·확인)·체크 원 배경 (Figma `834:2088`).
  /// 바텀시트·다이얼로그 면. 라이트는 흰색, 다크는 카드보다 한 단계 밝은 회청색(Figma 8877:1918).
  final Color sheetSurface;

  /// 토스트 면. 다크는 Figma 다크 토스트(8877:1922).
  final Color toastSurface;

  final Color toastBorder;
  final Color toastText;
  final Color toastAccent;
  final Color toastCheckFill;

  /// 로딩 스켈레톤 막대 #E4E4E4 (Figma `834:2351`).
  final Color skeleton;

  /// 빈 화면 안내 문구 #B3B3B3 (Figma 알림 `834:1161`).
  final Color emptyText;

  /// 모달 뒤 가림막: 검정 50% (추정).
  final Color scrim;

  /// 홈 상단 바 위에 덮는 흰색 10% (수정안 `rgba(255,255,255,0.1)`).
  final Color topBarTint;

  /// 스플래시 화면 배경: 흰색(Figma 805:953). 화면 배경(`#F2F2F4`)과 다르다. iOS·Android 시작 화면도 흰색이라 이어서 보인다.
  final Color splashBackground;

  /// 잠금 화면 "인증에 실패하거나…" 글자 `rgba(76,83,95,0.8)` (Figma 860:2655).
  final Color lockHelpText;

  /// 그 버튼을 누르고 있을 때의 알약 배경 `rgba(160,167,180,0.2)` (Figma 860:2657).
  final Color lockHelpPressed;

  /// 카카오 로그인 버튼 배경(브랜드 노랑)과 글자색.
  final Color kakaoYellow;
  final Color onKakao;

  /// 로그인 화면 구글 버튼 테두리 `#E5E5E5` (Figma 8877:1932).
  /// 구글 버튼 면과 소셜 버튼 글자. 브랜드 가이드상 다크 모드에서도 흰 버튼·어두운 글자를 쓴다(Figma 다크 로그인).
  final Color socialSurface;
  final Color onSocial;

  final Color socialBorder;

  /// 로그인 화면 약관 안내 글자 `rgba(76,83,95,0.8)` (Figma 8877:1940). 값은 [lockHelpText]와 같지만 쓰임이 달라 따로 둔다.
  final Color loginLegalText;

  /// 인트로 끝 화면(Figma 8877:1965) 배경 검정.
  final Color startBackground;

  /// 인트로 끝 화면 제목 글자 흰색.
  final Color startTitle;

  /// 인트로 끝 화면 설명 글자 #C2C2C7.
  final Color startBody;

  /// 인트로 끝 화면 CTA 글자 #260913(분홍 위 흰 글자는 대비 2.36:1이라 Figma 메모대로 어둡게).
  final Color onStartCta;

  /// 감정 7색(RebornMood 캐릭터의 이름표 색에서 뽑음): 기쁨
  final Color emotionJoy;

  /// 사랑
  final Color emotionLove;

  /// 신남
  final Color emotionExcited;

  /// 무표정
  final Color emotionNeutral;

  /// 불안함
  final Color emotionAnxiety;

  /// 화남
  final Color emotionAnger;

  /// 슬픔
  final Color emotionSadness;

  /// Figma 홈 화면에서 읽은 라이트 팔레트.
  static const light = AppColors(
    brand: Color(0xFFFF6090),
    cta: Color(0xFFFF6090),
    onCta: Color(0xFFFFFFFF),
    background: Color(0xFFF2F2F4),
    cardPink: Color(0xFFFEDAE5),
    cardWhite: Color(0xFFFFFFFF),
    cardBorder: Color(0xFFEEE6E9),
    iconStrong: Color(0xFF1C1B1F),
    iconMuted: Color(0xFF4C535F),
    textBlack: Color(0xFF000000),
    textStrong: Color(0xFF1A1A1A),
    textSecondary: Color(0xCC4C535F), // rgba(76,83,95,0.8)
    textDate: Color(0x99444444), // rgba(68,68,68,0.6)
    textGraphCaption: Color(0xFF70757F),
    emoji: Color(0xFFA0A7B4),
    chip: Color(0xFFF0F2F3),
    avatar: Color(0xFFD9D9D9),
    iconTile: Color(0x80D9D9D9), // rgba(217,217,217,0.5)
    gridLine: Color(0x80A0A7B4), // rgba(160,167,180,0.5)
    attendancePanel: Color(0xFFFFB2CA),
    onAttendancePanel: Color(0xCCFFFFFF), // rgba(255,255,255,0.8)
    bellButton: Color(0x1A999999), // rgba(153,153,153,0.1)
    navFill: Color(0xB3FFFFFF), // rgba(255,255,255,0.7)
    navBorder: Color(0xFFD0D0D0),
    navShadow: Color(0x1A000000), // rgba(0,0,0,0.1)
    navSelection: Color(0xFFEDEDED),
    navActive: Color(0xFFD94F79),
    recordCardSubtitle: Color(0xFF7D8492),
    ctaSoft: Color(0xFFFFAFC7),
    onCtaSoft: Color(0xFF000000),
    barStrong: Color(0xFFD94F79),
    barMid: Color(0xFFFF80A6),
    barLight: Color(0xFFFFB3CA),
    toggleOff: Color(0x4D3C3C43), // rgba(60,60,67,0.3)
    danger: Color(0xFFE5484D),
    dangerTile: Color(0xFFFDECEE),
    ctaPrimary: Color(0xFFFF80A6),
    toggleOn: Color(0xFFFFAFC7),
    segmentTrack: Color(0xFFFFFFFF),
    segmentSelected: Color(0xFFF2F2F4),
    sheetHandle: Color(0xFFE4E4E4),
    sheetTitle: Color(0xFF22252C),
    sheetRowText: Color(0xFF4B5260),
    sheetSurface: Color(0xFFFFFFFF),
    toastSurface: Color(0xFFFFFFFF),
    toastBorder: Color(0xFFE9E9EE),
    toastText: Color(0xFF22232A),
    toastAccent: Color(0xFFD94F79),
    toastCheckFill: Color(0xFFFBE8EF),
    skeleton: Color(0xFFE4E4E4),
    emptyText: Color(0xFFB3B3B3),
    scrim: Color(0x80000000),
    topBarTint: Color(0x1AFFFFFF),
    splashBackground: Color(0xFFFFFFFF),
    lockHelpText: Color(0xCC4C535F),
    lockHelpPressed: Color(0x33A0A7B4),
    kakaoYellow: Color(0xFFFEE500),
    onKakao: Color(0xFF191919),
    socialSurface: Color(0xFFFFFFFF),
    onSocial: Color(0xFF000000),
    socialBorder: Color(0xFFE5E5E5),
    loginLegalText: Color(0xCC4C535F),
    startBackground: Color(0xFF000000),
    startTitle: Color(0xFFFFFFFF),
    startBody: Color(0xFFC2C2C7),
    onStartCta: Color(0xFF260913),
    emotionJoy: Color(0xFFF4B1CB),
    emotionLove: Color(0xFFFF9EC4),
    emotionExcited: Color(0xFFFAD599),
    emotionNeutral: Color(0xFFD1BDF3),
    emotionAnxiety: Color(0xFFB9E5C6),
    emotionAnger: Color(0xFFFDA4AC),
    emotionSadness: Color(0xFFBBD5ED),
  );

  /// 다크 팔레트. 페이지 배경 #0F1013, 카드 #1C1D23, 테두리 #3B3D47, 칩 #2D2F39, 글자 #E4E4E4·#B7BAC6,
  /// 시트 #33353E, 토스트 #202229는 Figma "Dark Mode"(8877:1778) 시안에서 읽은 값이고,
  /// 시안에 없는 화면의 색은 같은 규칙(밝기만 반전, 브랜드·감정·카카오는 유지)으로 정한 값이다.
  static const dark = AppColors(
    brand: Color(0xFFFF6090),
    cta: Color(0xFFFF6090),
    onCta: Color(0xFFFFFFFF),
    background: Color(0xFF0F1013),
    cardPink: Color(0xFF3A2530),
    cardWhite: Color(0xFF1C1D23),
    cardBorder: Color(0xFF3B3D47),
    iconStrong: Color(0xFFE4E4E4),
    iconMuted: Color(0xFFB7BAC6),
    textBlack: Color(0xFFE4E4E4),
    textStrong: Color(0xFFE4E4E4),
    textSecondary: Color(0xFFB7BAC6),
    textDate: Color(0xCCB7BAC6),
    textGraphCaption: Color(0xFF9A9FAD),
    emoji: Color(0xFF7D8492),
    chip: Color(0xFF2D2F39),
    avatar: Color(0xFF3B3D47),
    iconTile: Color(0xFF2D2F39),
    gridLine: Color(0x4DA0A7B4),
    attendancePanel: Color(0xFF4A2735),
    onAttendancePanel: Color(0xCCFFFFFF),
    bellButton: Color(0x1AFFFFFF),
    navFill: Color(0xCC22242B),
    navBorder: Color(0xFF3B3D47),
    navShadow: Color(0x66000000),
    navSelection: Color(0xFF2D2F39),
    navActive: Color(0xFFD94F79),
    recordCardSubtitle: Color(0xFFB7BAC6),
    ctaSoft: Color(0xFFFFAFC7),
    onCtaSoft: Color(0xFF000000),
    barStrong: Color(0xFFD94F79),
    barMid: Color(0xFFFF80A6),
    barLight: Color(0xFFFFB3CA),
    toggleOff: Color(0x52787880),
    danger: Color(0xFFFF6B70),
    dangerTile: Color(0xFF3A1D20),
    ctaPrimary: Color(0xFFFF80A6),
    toggleOn: Color(0xFFFFAFC7),
    segmentTrack: Color(0xFF1C1D23),
    segmentSelected: Color(0xFF3B3D47),
    sheetHandle: Color(0xFF5A5C66),
    sheetTitle: Color(0xFFE4E4E4),
    sheetRowText: Color(0xFFC9CCD6),
    sheetSurface: Color(0xFF33353E),
    toastSurface: Color(0xFF202229),
    toastBorder: Color(0xFF3B3D47),
    toastText: Color(0xFFE4E4E4),
    toastAccent: Color(0xFFFF80A6),
    toastCheckFill: Color(0xFF3A2530),
    skeleton: Color(0xFF2D2F39),
    emptyText: Color(0xFF6B7080),
    scrim: Color(0x99000000),
    topBarTint: Color(0x1A0F1013),
    splashBackground: Color(0xFF0F1013),
    lockHelpText: Color(0xCCB7BAC6),
    lockHelpPressed: Color(0x33A0A7B4),
    kakaoYellow: Color(0xFFFEE500),
    onKakao: Color(0xFF191919),
    socialSurface: Color(0xFFFFFFFF),
    onSocial: Color(0xFF000000),
    socialBorder: Color(0xFFE5E5E5),
    loginLegalText: Color(0xCCB7BAC6),
    startBackground: Color(0xFF000000),
    startTitle: Color(0xFFFFFFFF),
    startBody: Color(0xFFC2C2C7),
    onStartCta: Color(0xFF260913),
    emotionJoy: Color(0xFFF4B1CB),
    emotionLove: Color(0xFFFF9EC4),
    emotionExcited: Color(0xFFFAD599),
    emotionNeutral: Color(0xFFD1BDF3),
    emotionAnxiety: Color(0xFFB9E5C6),
    emotionAnger: Color(0xFFFDA4AC),
    emotionSadness: Color(0xFFBBD5ED),
  );

  @override
  AppColors copyWith({
    Color? brand,
    Color? cta,
    Color? onCta,
    Color? background,
    Color? cardPink,
    Color? cardWhite,
    Color? cardBorder,
    Color? iconStrong,
    Color? iconMuted,
    Color? textBlack,
    Color? textStrong,
    Color? textSecondary,
    Color? textDate,
    Color? textGraphCaption,
    Color? emoji,
    Color? chip,
    Color? avatar,
    Color? iconTile,
    Color? gridLine,
    Color? attendancePanel,
    Color? onAttendancePanel,
    Color? bellButton,
    Color? navFill,
    Color? navBorder,
    Color? navShadow,
    Color? navSelection,
    Color? navActive,
    Color? recordCardSubtitle,
    Color? ctaSoft,
    Color? onCtaSoft,
    Color? barStrong,
    Color? barMid,
    Color? barLight,
    Color? toggleOff,
    Color? danger,
    Color? dangerTile,
    Color? ctaPrimary,
    Color? toggleOn,
    Color? segmentTrack,
    Color? segmentSelected,
    Color? sheetHandle,
    Color? sheetTitle,
    Color? sheetRowText,
    Color? sheetSurface,
    Color? toastSurface,
    Color? toastBorder,
    Color? toastText,
    Color? toastAccent,
    Color? toastCheckFill,
    Color? skeleton,
    Color? emptyText,
    Color? scrim,
    Color? topBarTint,
    Color? splashBackground,
    Color? lockHelpText,
    Color? lockHelpPressed,
    Color? kakaoYellow,
    Color? onKakao,
    Color? socialSurface,
    Color? onSocial,
    Color? socialBorder,
    Color? loginLegalText,
    Color? startBackground,
    Color? startTitle,
    Color? startBody,
    Color? onStartCta,
    Color? emotionJoy,
    Color? emotionLove,
    Color? emotionExcited,
    Color? emotionNeutral,
    Color? emotionAnxiety,
    Color? emotionAnger,
    Color? emotionSadness,
  }) {
    return AppColors(
      brand: brand ?? this.brand,
      cta: cta ?? this.cta,
      onCta: onCta ?? this.onCta,
      background: background ?? this.background,
      cardPink: cardPink ?? this.cardPink,
      cardWhite: cardWhite ?? this.cardWhite,
      cardBorder: cardBorder ?? this.cardBorder,
      iconStrong: iconStrong ?? this.iconStrong,
      iconMuted: iconMuted ?? this.iconMuted,
      textBlack: textBlack ?? this.textBlack,
      textStrong: textStrong ?? this.textStrong,
      textSecondary: textSecondary ?? this.textSecondary,
      textDate: textDate ?? this.textDate,
      textGraphCaption: textGraphCaption ?? this.textGraphCaption,
      emoji: emoji ?? this.emoji,
      chip: chip ?? this.chip,
      avatar: avatar ?? this.avatar,
      iconTile: iconTile ?? this.iconTile,
      gridLine: gridLine ?? this.gridLine,
      attendancePanel: attendancePanel ?? this.attendancePanel,
      onAttendancePanel: onAttendancePanel ?? this.onAttendancePanel,
      bellButton: bellButton ?? this.bellButton,
      navFill: navFill ?? this.navFill,
      navBorder: navBorder ?? this.navBorder,
      navShadow: navShadow ?? this.navShadow,
      navSelection: navSelection ?? this.navSelection,
      navActive: navActive ?? this.navActive,
      recordCardSubtitle: recordCardSubtitle ?? this.recordCardSubtitle,
      ctaSoft: ctaSoft ?? this.ctaSoft,
      onCtaSoft: onCtaSoft ?? this.onCtaSoft,
      barStrong: barStrong ?? this.barStrong,
      barMid: barMid ?? this.barMid,
      barLight: barLight ?? this.barLight,
      toggleOff: toggleOff ?? this.toggleOff,
      danger: danger ?? this.danger,
      dangerTile: dangerTile ?? this.dangerTile,
      ctaPrimary: ctaPrimary ?? this.ctaPrimary,
      toggleOn: toggleOn ?? this.toggleOn,
      segmentTrack: segmentTrack ?? this.segmentTrack,
      segmentSelected: segmentSelected ?? this.segmentSelected,
      sheetHandle: sheetHandle ?? this.sheetHandle,
      sheetTitle: sheetTitle ?? this.sheetTitle,
      sheetRowText: sheetRowText ?? this.sheetRowText,
      sheetSurface: sheetSurface ?? this.sheetSurface,
      toastSurface: toastSurface ?? this.toastSurface,
      toastBorder: toastBorder ?? this.toastBorder,
      toastText: toastText ?? this.toastText,
      toastAccent: toastAccent ?? this.toastAccent,
      toastCheckFill: toastCheckFill ?? this.toastCheckFill,
      skeleton: skeleton ?? this.skeleton,
      emptyText: emptyText ?? this.emptyText,
      scrim: scrim ?? this.scrim,
      topBarTint: topBarTint ?? this.topBarTint,
      splashBackground: splashBackground ?? this.splashBackground,
      lockHelpText: lockHelpText ?? this.lockHelpText,
      lockHelpPressed: lockHelpPressed ?? this.lockHelpPressed,
      kakaoYellow: kakaoYellow ?? this.kakaoYellow,
      onKakao: onKakao ?? this.onKakao,
      socialSurface: socialSurface ?? this.socialSurface,
      onSocial: onSocial ?? this.onSocial,
      socialBorder: socialBorder ?? this.socialBorder,
      loginLegalText: loginLegalText ?? this.loginLegalText,
      startBackground: startBackground ?? this.startBackground,
      startTitle: startTitle ?? this.startTitle,
      startBody: startBody ?? this.startBody,
      onStartCta: onStartCta ?? this.onStartCta,
      emotionJoy: emotionJoy ?? this.emotionJoy,
      emotionLove: emotionLove ?? this.emotionLove,
      emotionExcited: emotionExcited ?? this.emotionExcited,
      emotionNeutral: emotionNeutral ?? this.emotionNeutral,
      emotionAnxiety: emotionAnxiety ?? this.emotionAnxiety,
      emotionAnger: emotionAnger ?? this.emotionAnger,
      emotionSadness: emotionSadness ?? this.emotionSadness,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      brand: mix(brand, other.brand),
      cta: mix(cta, other.cta),
      onCta: mix(onCta, other.onCta),
      background: mix(background, other.background),
      cardPink: mix(cardPink, other.cardPink),
      cardWhite: mix(cardWhite, other.cardWhite),
      cardBorder: mix(cardBorder, other.cardBorder),
      iconStrong: mix(iconStrong, other.iconStrong),
      iconMuted: mix(iconMuted, other.iconMuted),
      textBlack: mix(textBlack, other.textBlack),
      textStrong: mix(textStrong, other.textStrong),
      textSecondary: mix(textSecondary, other.textSecondary),
      textDate: mix(textDate, other.textDate),
      textGraphCaption: mix(textGraphCaption, other.textGraphCaption),
      emoji: mix(emoji, other.emoji),
      chip: mix(chip, other.chip),
      avatar: mix(avatar, other.avatar),
      iconTile: mix(iconTile, other.iconTile),
      gridLine: mix(gridLine, other.gridLine),
      attendancePanel: mix(attendancePanel, other.attendancePanel),
      onAttendancePanel: mix(onAttendancePanel, other.onAttendancePanel),
      bellButton: mix(bellButton, other.bellButton),
      navFill: mix(navFill, other.navFill),
      navBorder: mix(navBorder, other.navBorder),
      navShadow: mix(navShadow, other.navShadow),
      navSelection: mix(navSelection, other.navSelection),
      navActive: mix(navActive, other.navActive),
      recordCardSubtitle: mix(recordCardSubtitle, other.recordCardSubtitle),
      ctaSoft: mix(ctaSoft, other.ctaSoft),
      onCtaSoft: mix(onCtaSoft, other.onCtaSoft),
      barStrong: mix(barStrong, other.barStrong),
      barMid: mix(barMid, other.barMid),
      barLight: mix(barLight, other.barLight),
      toggleOff: mix(toggleOff, other.toggleOff),
      danger: mix(danger, other.danger),
      dangerTile: mix(dangerTile, other.dangerTile),
      ctaPrimary: mix(ctaPrimary, other.ctaPrimary),
      toggleOn: mix(toggleOn, other.toggleOn),
      segmentTrack: mix(segmentTrack, other.segmentTrack),
      segmentSelected: mix(segmentSelected, other.segmentSelected),
      sheetHandle: mix(sheetHandle, other.sheetHandle),
      sheetTitle: mix(sheetTitle, other.sheetTitle),
      sheetRowText: mix(sheetRowText, other.sheetRowText),
      sheetSurface: mix(sheetSurface, other.sheetSurface),
      toastSurface: mix(toastSurface, other.toastSurface),
      toastBorder: mix(toastBorder, other.toastBorder),
      toastText: mix(toastText, other.toastText),
      toastAccent: mix(toastAccent, other.toastAccent),
      toastCheckFill: mix(toastCheckFill, other.toastCheckFill),
      skeleton: mix(skeleton, other.skeleton),
      emptyText: mix(emptyText, other.emptyText),
      scrim: mix(scrim, other.scrim),
      topBarTint: mix(topBarTint, other.topBarTint),
      splashBackground: mix(splashBackground, other.splashBackground),
      lockHelpText: mix(lockHelpText, other.lockHelpText),
      lockHelpPressed: mix(lockHelpPressed, other.lockHelpPressed),
      kakaoYellow: mix(kakaoYellow, other.kakaoYellow),
      onKakao: mix(onKakao, other.onKakao),
      socialSurface: mix(socialSurface, other.socialSurface),
      onSocial: mix(onSocial, other.onSocial),
      socialBorder: mix(socialBorder, other.socialBorder),
      loginLegalText: mix(loginLegalText, other.loginLegalText),
      startBackground: mix(startBackground, other.startBackground),
      startTitle: mix(startTitle, other.startTitle),
      startBody: mix(startBody, other.startBody),
      onStartCta: mix(onStartCta, other.onStartCta),
      emotionJoy: mix(emotionJoy, other.emotionJoy),
      emotionLove: mix(emotionLove, other.emotionLove),
      emotionExcited: mix(emotionExcited, other.emotionExcited),
      emotionNeutral: mix(emotionNeutral, other.emotionNeutral),
      emotionAnxiety: mix(emotionAnxiety, other.emotionAnxiety),
      emotionAnger: mix(emotionAnger, other.emotionAnger),
      emotionSadness: mix(emotionSadness, other.emotionSadness),
    );
  }
}

extension AppColorsContext on BuildContext {
  /// 현재 테마의 앱 색상. `context.colors.brand`처럼 쓴다.
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
