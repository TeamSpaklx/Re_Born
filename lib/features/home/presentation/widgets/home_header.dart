import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_assets.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/pressable.dart';

/// 로고와 알림 버튼 행 (높이 62).
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    this.onLogoTap,
    this.onBellTap,
    this.unreadCount = 0,
  });

  /// 로고를 눌렀을 때(화면 맨 위로 이동).
  final VoidCallback? onLogoTap;

  /// 알림 버튼을 눌렀을 때(알림 목록으로 이동).
  final VoidCallback? onBellTap;

  /// 읽지 않은 알림 수. 0보다 크면 벨 오른쪽 위에 점이 붙는다.
  final int unreadCount;

  // 로고 PNG는 안쪽 여백이 있어 Figma가 영역 안에서 이만큼 옮겨 그린다(DESIGN_HOME.md 5.1).
  static const _logoLeftFraction = -0.1132;
  static const _logoTopFraction = -0.0064;
  static const _bellInsetFraction = 0.1818;
  static const _bellTop = 9.0;
  static const _logoTop = 10.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const bell = HomeLayout.bellButtonSize;
    const logoW = HomeLayout.headerLogoWidth;
    const logoH = HomeLayout.headerLogoHeight;

    return SizedBox(
      height: HomeLayout.headerHeight,
      child: Stack(
        children: [
          Positioned(
            left: AppSpacing.pageMargin,
            top: _logoTop,
            width: logoW,
            height: logoH,
            child: Semantics(
              button: true,
              label: '맨 위로 이동',
              excludeSemantics: true,
              onTap: onLogoTap,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onLogoTap,
                child: ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.topLeft,
                    minWidth: logoW,
                    maxWidth: logoW,
                    minHeight: logoH,
                    maxHeight: logoH,
                    child: Transform.translate(
                      offset: const Offset(
                        logoW * _logoLeftFraction,
                        logoH * _logoTopFraction,
                      ),
                      child: Image.asset(
                        AppAssets.logo,
                        width: logoW,
                        height: logoH,
                        fit: BoxFit.fill,
                        excludeFromSemantics: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: AppSpacing.pageMargin,
            top: _bellTop,
            width: bell,
            height: bell,
            child: Semantics(
              button: true,
              label: unreadCount > 0 ? '알림, 읽지 않은 알림 $unreadCount개' : '알림',
              excludeSemantics: true,
              onTap: onBellTap,
              child: Pressable(
                onTap: onBellTap,
                child: Badged(
                  badge: unreadCount > 0 ? const AppBadge.dot() : null,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.bellButton,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(bell * _bellInsetFraction),
                      child: SvgPicture.asset(AppAssets.bell),
                    ),
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
