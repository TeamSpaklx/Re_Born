import 'package:flutter/material.dart';

/// 앱에서 쓰는 모든 색. 화면에서 `Color(0x...)`를 직접 쓰지 않고 이 값만 쓴다.
///
/// 라이트 팔레트 한 벌만 있다([AppColors.light]). 다크 모드를 추가할 때는
/// 같은 필드로 `AppColors.dark`를 만들고 `ThemeData.extensions`에 넣으면 된다.
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
    required this.recordCardSubtitle,
    required this.ctaSoft,
    required this.onCtaSoft,
    required this.barStrong,
    required this.barMid,
    required this.barLight,
    required this.toggleOff,
    required this.danger,
    required this.dangerTile,
    required this.toastFill,
    required this.scrim,
    required this.topBarTint,
    required this.splashBackground,
    required this.skeleton,
    required this.kakaoYellow,
    required this.onKakao,
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

  /// 화면 배경 `#FFF8F8` (수정안). 카드는 흰색이라 배경과 구분된다.
  final Color background;

  /// 기록 카드(핑크)와 흰 카드, 흰 카드의 테두리.
  final Color cardPink;
  final Color cardWhite;
  final Color cardBorder;

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

  /// 토글 꺼짐 배경.
  final Color toggleOff;

  /// 삭제·로그아웃 같은 위험한 동작 글자 (Figma에 없음, 추정).
  final Color danger;

  /// 위험한 동작 버튼 배경 (추정).
  final Color dangerTile;

  /// 토스트 배경: #1A1A1A 90% (추정).
  final Color toastFill;

  /// 모달 뒤 가림막: 검정 50% (추정).
  final Color scrim;

  /// 홈 상단 바 위에 덮는 흰색 10% (수정안 `rgba(255,255,255,0.1)`).
  final Color topBarTint;

  /// 스플래시 화면 배경: 흰색(Figma `289:1723`). 화면 배경(`#FFF8F8`)과 다르다. iOS·Android 시작 화면도 흰색이라 이어서 보인다.
  final Color splashBackground;

  /// 로딩 스켈레톤 블록 (흰 카드·#FFF8F8 배경 둘 다에서 보이는 연한 핑크 회색, 추정).
  final Color skeleton;

  /// 카카오 로그인 버튼 배경(브랜드 노랑)과 글자색.
  final Color kakaoYellow;
  final Color onKakao;

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
    background: Color(0xFFFFF8F8),
    cardPink: Color(0xFFFEDAE5),
    cardWhite: Color(0xFFFFFFFF),
    cardBorder: Color(0xFFEEE6E9),
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
    recordCardSubtitle: Color(0xFF7D8492),
    ctaSoft: Color(0xFFFFAFC7),
    onCtaSoft: Color(0xFF000000),
    barStrong: Color(0xFFD94F79),
    barMid: Color(0xFFFF80A6),
    barLight: Color(0xFFFFB3CA),
    toggleOff: Color(0xFFE8D5DA),
    danger: Color(0xFFE5484D),
    dangerTile: Color(0xFFFDECEE),
    toastFill: Color(0xE61A1A1A),
    scrim: Color(0x80000000),
    topBarTint: Color(0x1AFFFFFF),
    splashBackground: Color(0xFFFFFFFF),
    skeleton: Color(0xFFF1EAED),
    kakaoYellow: Color(0xFFFEE500),
    onKakao: Color(0xFF191919),
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
    Color? recordCardSubtitle,
    Color? ctaSoft,
    Color? onCtaSoft,
    Color? barStrong,
    Color? barMid,
    Color? barLight,
    Color? toggleOff,
    Color? danger,
    Color? dangerTile,
    Color? toastFill,
    Color? scrim,
    Color? topBarTint,
    Color? splashBackground,
    Color? skeleton,
    Color? kakaoYellow,
    Color? onKakao,
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
      recordCardSubtitle: recordCardSubtitle ?? this.recordCardSubtitle,
      ctaSoft: ctaSoft ?? this.ctaSoft,
      onCtaSoft: onCtaSoft ?? this.onCtaSoft,
      barStrong: barStrong ?? this.barStrong,
      barMid: barMid ?? this.barMid,
      barLight: barLight ?? this.barLight,
      toggleOff: toggleOff ?? this.toggleOff,
      danger: danger ?? this.danger,
      dangerTile: dangerTile ?? this.dangerTile,
      toastFill: toastFill ?? this.toastFill,
      scrim: scrim ?? this.scrim,
      topBarTint: topBarTint ?? this.topBarTint,
      splashBackground: splashBackground ?? this.splashBackground,
      skeleton: skeleton ?? this.skeleton,
      kakaoYellow: kakaoYellow ?? this.kakaoYellow,
      onKakao: onKakao ?? this.onKakao,
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
      recordCardSubtitle: mix(recordCardSubtitle, other.recordCardSubtitle),
      ctaSoft: mix(ctaSoft, other.ctaSoft),
      onCtaSoft: mix(onCtaSoft, other.onCtaSoft),
      barStrong: mix(barStrong, other.barStrong),
      barMid: mix(barMid, other.barMid),
      barLight: mix(barLight, other.barLight),
      toggleOff: mix(toggleOff, other.toggleOff),
      danger: mix(danger, other.danger),
      dangerTile: mix(dangerTile, other.dangerTile),
      toastFill: mix(toastFill, other.toastFill),
      scrim: mix(scrim, other.scrim),
      topBarTint: mix(topBarTint, other.topBarTint),
      splashBackground: mix(splashBackground, other.splashBackground),
      skeleton: mix(skeleton, other.skeleton),
      kakaoYellow: mix(kakaoYellow, other.kakaoYellow),
      onKakao: mix(onKakao, other.onKakao),
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
