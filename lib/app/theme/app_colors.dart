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
    required this.backgroundGradientTop,
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
  });

  /// 브랜드 핑크: 그래프 막대, 활성 탭, 강조 숫자, 출석 알약.
  final Color brand;

  /// 주요 버튼 배경 (감정 기록하기 / 오늘 기록 보기).
  final Color cta;
  final Color onCta;

  final Color background;

  /// 화면 맨 위 그라디언트 시작색. 흰색으로 끝난다.
  final Color backgroundGradientTop;

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

  /// Figma 홈 화면에서 읽은 라이트 팔레트.
  static const light = AppColors(
    brand: Color(0xFFFF6090),
    cta: Color(0xFFFF6090),
    onCta: Color(0xFFFFFFFF),
    background: Color(0xFFFFFFFF),
    backgroundGradientTop: Color(0xCCD94F79), // rgba(217,79,121,0.8)
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
  );

  @override
  AppColors copyWith({
    Color? brand,
    Color? cta,
    Color? onCta,
    Color? background,
    Color? backgroundGradientTop,
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
  }) {
    return AppColors(
      brand: brand ?? this.brand,
      cta: cta ?? this.cta,
      onCta: onCta ?? this.onCta,
      background: background ?? this.background,
      backgroundGradientTop:
          backgroundGradientTop ?? this.backgroundGradientTop,
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
      backgroundGradientTop: mix(
        backgroundGradientTop,
        other.backgroundGradientTop,
      ),
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
    );
  }
}

extension AppColorsContext on BuildContext {
  /// 현재 테마의 앱 색상. `context.colors.brand`처럼 쓴다.
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
