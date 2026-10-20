import 'dart:ui' show ImageFilter;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/app_assets.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/theme/bottom_nav_tokens.dart';

/// 하단 탭 바 (Figma `ButtonNavigator[Liquid Glass]`, docs/DESIGN_SYSTEM.md 5.8).
///
/// iOS와 Android는 배경 블러 강도만 다르고 구조·아이콘·라벨은 같다.
/// - iOS: Figma 값(반투명 흰색 + 테두리 + 그림자) + 약한 블러
/// - Android: 같은 모양에 더 강한 블러 배경
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.width = BottomNavTokens.width,
    this.platform,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final double width;

  /// 테스트에서 플랫폼을 바꿔 볼 때만 지정한다. 비우면 현재 플랫폼을 쓴다.
  final TargetPlatform? platform;

  static const _tabs = [
    _NavTab(AppAssets.tabHome, AppAssets.tabHomeActive),
    _NavTab(AppAssets.tabRelations, AppAssets.tabRelationsActive),
    _NavTab(AppAssets.tabRecord, AppAssets.tabRecordActive),
    _NavTab(AppAssets.tabAll, AppAssets.tabAllActive),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isAndroid =
        (platform ?? defaultTargetPlatform) == TargetPlatform.android;
    final blurSigma = isAndroid
        ? BottomNavTokens.androidBlurSigma
        : BottomNavTokens.iosBlurSigma;
    const radius = AppRadii.pillBorderRadius;

    final column =
        (width - BottomNavTokens.columnInset * 2) /
        BottomNavTokens.labels.length;
    final selectionLeft =
        BottomNavTokens.columnInset +
        column * currentIndex +
        column / 2 -
        BottomNavTokens.selectionWidth / 2;

    return SizedBox(
      width: width,
      height: BottomNavTokens.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 그림자는 알약 바깥쪽에만 그린다. 반투명 배경 아래로 비치면 Figma와 달라진다.
          Positioned.fill(
            child: ClipPath(
              clipper: _OutsideOfPillClipper(),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  boxShadow: [
                    BoxShadow(
                      color: colors.navShadow,
                      offset: const Offset(0, BottomNavTokens.shadowOffsetY),
                      blurRadius: BottomNavTokens.shadowBlur,
                      spreadRadius: BottomNavTokens.shadowSpread,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: ClipRRect(
              borderRadius: radius,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.navFill,
                    borderRadius: radius,
                    border: Border.all(
                      color: colors.navBorder,
                      width: BottomNavTokens.borderWidth,
                    ),
                  ),
                  child: Stack(
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        left: selectionLeft,
                        top:
                            (BottomNavTokens.height -
                                BottomNavTokens.selectionHeight) /
                            2,
                        width: BottomNavTokens.selectionWidth,
                        height: BottomNavTokens.selectionHeight,
                        child: SvgPicture.asset(
                          AppAssets.tabSelection,
                          fit: BoxFit.fill,
                        ),
                      ),
                      Positioned(
                        left: BottomNavTokens.columnInset,
                        right: BottomNavTokens.columnInset,
                        top: BottomNavTokens.menusTop,
                        height: BottomNavTokens.menusHeight,
                        child: Row(
                          children: [
                            for (var i = 0; i < _tabs.length; i++)
                              Expanded(
                                child: _NavItem(
                                  tab: _tabs[i],
                                  label: BottomNavTokens.labels[i],
                                  selected: i == currentIndex,
                                  onTap: () => onTap(i),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTab {
  const _NavTab(this.icon, this.activeIcon);

  final String icon;
  final String activeIcon;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final _NavTab tab;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              selected ? tab.activeIcon : tab.icon,
              width: BottomNavTokens.iconSize,
              height: BottomNavTokens.iconSize,
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: AppTextStyles.navLabel.copyWith(
                color: selected ? colors.brand : colors.textStrong,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 알약 바깥쪽만 남기는 클리퍼. 알약 안쪽(구멍)과 바깥의 넓은 영역을 even-odd로 합친다.
class _OutsideOfPillClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final pill = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.height / 2),
    );
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Rect.fromLTWH(-200, -200, size.width + 400, size.height + 400))
      ..addRRect(pill);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
