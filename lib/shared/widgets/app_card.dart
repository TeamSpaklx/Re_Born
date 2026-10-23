import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_spacing.dart';

/// 둥근 카드. 핑크(기록 카드)와 흰색 + 테두리 2px(신호·그래프·액션 카드) 두 종류.
/// 크기는 부모가 정한다. 테두리 안쪽이 자식의 영역이다(Figma와 같다).
class AppCard extends StatelessWidget {
  const AppCard.pink({
    super.key,
    this.height,
    this.padding,
    required this.child,
  }) : _white = false;

  const AppCard.white({
    super.key,
    this.height,
    this.padding,
    required this.child,
  }) : _white = true;

  final bool _white;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: height,
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _white ? colors.cardWhite : colors.cardPink,
        borderRadius: AppRadii.cardBorderRadius,
        border: _white
            ? Border.all(
                color: colors.cardBorder,
                width: AppSpacing.cardBorderWidth,
              )
            : null,
      ),
      child: child,
    );
  }
}
