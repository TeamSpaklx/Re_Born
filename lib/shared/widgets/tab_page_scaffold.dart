import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/theme/bottom_nav_tokens.dart';

/// 디자인이 없는 탭(기록·관계·전체)의 공통 틀. 임시 디자인: 홈의 고정 상단 바(블러)와 같은 구조에
/// 큰 제목을 놓고, 아래로 스크롤되는 내용과 탭 바 여백을 둔다.
class TabPageScaffold extends StatelessWidget {
  const TabPageScaffold({
    super.key,
    required this.title,
    required this.children,
    this.trailing,
    this.floating,
  });

  final String title;
  final List<Widget> children;

  /// 제목 오른쪽 끝에 놓을 것(예: 추가 버튼).
  final Widget? trailing;

  /// 탭 바 위 오른쪽에 떠 있는 버튼(예: [AppFab]).
  final Widget? floating;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final safeTop = MediaQuery.paddingOf(context).top;
    final barHeight = safeTop + HomeLayout.headerHeight;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: barHeight),
                ...children,
                const SizedBox(height: BottomNavTokens.scrollBottomPadding),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: barHeight,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: AppSpacing.topBarBlurSigma,
                  sigmaY: AppSpacing.topBarBlurSigma,
                ),
                child: ColoredBox(
                  color: colors.background.withValues(alpha: 0.7),
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: safeTop,
                      left: AppSpacing.pageMargin,
                      right: AppSpacing.pageMargin,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTextStyles.greeting.copyWith(
                              color: colors.textBlack,
                            ),
                          ),
                        ),
                        ?trailing,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (floating != null)
            Positioned(
              right: AppSpacing.pageMargin,
              bottom:
                  math.max(
                    MediaQuery.paddingOf(context).bottom,
                    BottomNavTokens.bottomOffset,
                  ) +
                  BottomNavTokens.height +
                  AppSpacing.space16,
              child: floating!,
            ),
        ],
      ),
    );
  }
}
