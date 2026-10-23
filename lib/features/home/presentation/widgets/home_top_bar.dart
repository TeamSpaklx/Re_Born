import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import 'home_header.dart';

/// 화면 위에 고정되는 상단 바: 상태바 영역 + 로고/알림 행.
/// 스크롤되는 내용이 이 뒤로 지나가면 블러로 흐려진다. 핑크 그라디언트는 없고 흰색 10%만 덮는다(수정안).
class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key, this.onLogoTap});

  /// 로고를 눌렀을 때(화면 맨 위로 이동).
  final VoidCallback? onLogoTap;

  /// 상단 바 높이: 상태바 영역 + 헤더 행.
  static double heightOf(BuildContext context) =>
      MediaQuery.paddingOf(context).top + HomeLayout.headerHeight;

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.paddingOf(context).top;

    return SizedBox(
      height: heightOf(context),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppSpacing.topBarBlurSigma,
            sigmaY: AppSpacing.topBarBlurSigma,
          ),
          child: ColoredBox(
            color: context.colors.topBarTint,
            child: Column(
              children: [
                SizedBox(height: safeTop),
                HomeHeader(onLogoTap: onLogoTap),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
