import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// 앱 테마. 라이트와 다크 두 벌이고 [AppColors]만 다르다.
/// 라이트·다크는 설정의 화면 모드(`themeModeProvider`: 기기 설정 / 라이트 / 다크)가 고른다.
abstract final class AppTheme {
  static final ThemeData light = _build(AppColors.light, Brightness.light);
  static final ThemeData dark = _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors colors, Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: AppTextStyles.fontFamily,
      scaffoldBackgroundColor: colors.background,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: colors.cta,
            brightness: brightness,
          ).copyWith(
            primary: colors.cta,
            onPrimary: colors.onCta,
            surface: colors.background,
            onSurface: colors.textBlack,
          ),
      // 화면 배경과 카드 색을 그대로 사용하고 머티리얼이 색을 덧입히지 않게 한다.
      splashFactory: NoSplash.splashFactory,
      extensions: [colors],
    );
  }
}
