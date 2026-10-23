import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/utils/app_haptics.dart';
import '../shared/widgets/app_bottom_nav_bar.dart';
import 'theme/app_colors.dart';
import 'theme/app_spacing.dart';
import 'theme/bottom_nav_tokens.dart';

/// 하단 탭 바가 화면 아래에 떠 있는 메인 틀.
///
/// 탭 바는 화면 아래에서 34 위(홈 인디케이터 영역 위)에 고정된다. 각 탭 화면은 스크롤 맨 아래에
/// [BottomNavTokens.scrollBottomPadding]만큼 여백을 둬서 탭 바에 가려지지 않게 한다.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final navBottom = math.max(safeBottom, BottomNavTokens.bottomOffset);
    final navWidth = math.min(
      BottomNavTokens.width,
      screenWidth - AppSpacing.pageMargin * 2,
    );

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          navigationShell,
          Positioned(
            left: 0,
            right: 0,
            bottom: navBottom,
            child: Center(
              child: AppBottomNavBar(
                width: navWidth,
                currentIndex: navigationShell.currentIndex,
                onTap: (index) {
                  // 다른 탭으로 바뀔 때만 햅틱. (iOS 네이티브 탭 바도 같은 콜백을 쓴다.)
                  if (index != navigationShell.currentIndex) {
                    AppHaptics.selection();
                  }
                  navigationShell.goBranch(
                    index,
                    // 이미 선택된 탭을 다시 누르면 그 탭의 첫 화면으로 돌아간다.
                    initialLocation: index == navigationShell.currentIndex,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
