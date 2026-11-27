import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 상태 바·내비게이션 바 모양. 앱 밝기에 따라 아이콘 색만 뒤집는다(배경은 투명).
abstract final class AppOverlayStyles {
  static const light = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarContrastEnforced: false,
  );

  static const dark = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarContrastEnforced: false,
  );

  static SystemUiOverlayStyle of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
}
