import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// 앱 테마. 지금은 라이트 전용이다. 다크 모드는 나중에 [AppColors.dark]를 만들고
/// `darkTheme`을 추가하는 방식으로 넣는다.
abstract final class AppTheme {
  static const _colors = AppColors.light;

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: AppTextStyles.fontFamily,
    scaffoldBackgroundColor: _colors.background,
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: _colors.cta,
          brightness: Brightness.light,
        ).copyWith(
          primary: _colors.cta,
          onPrimary: _colors.onCta,
          surface: _colors.background,
          onSurface: _colors.textBlack,
        ),
    // 홈 화면은 항상 흰 배경 위에 카드를 올리므로 머티리얼이 색을 덧입히지 않게 한다.
    splashFactory: NoSplash.splashFactory,
    extensions: const [AppColors.light],
  );
}
