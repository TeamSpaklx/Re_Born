import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_spacing.dart';

enum _CardKind { pink, white, outlined }

/// 둥근 카드. 핑크(기록 완료 카드), 흰색(신호·그래프·액션 카드), 흰색 + 테두리 1px(기록 카드 Before) 세 종류.
/// 크기는 부모가 정한다.
///
/// 흰색 카드는 수정안에서 테두리가 없지만, 안쪽 좌표를 그대로 쓰도록 테두리 2px 자리를 투명하게 남겨 둔다.
/// 테두리 카드의 1px 선은 안쪽 위에 겹쳐 그려서 안쪽 좌표를 바꾸지 않는다.
class AppCard extends StatelessWidget {
  const AppCard.pink({
    super.key,
    this.height,
    this.padding,
    required this.child,
  }) : _kind = _CardKind.pink;

  const AppCard.white({
    super.key,
    this.height,
    this.padding,
    required this.child,
  }) : _kind = _CardKind.white;

  const AppCard.outlined({
    super.key,
    this.height,
    this.padding,
    required this.child,
  }) : _kind = _CardKind.outlined;

  final _CardKind _kind;
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
        color: _kind == _CardKind.pink ? colors.cardPink : colors.cardWhite,
        borderRadius: AppRadii.cardBorderRadius,
        border: _kind == _CardKind.white
            ? Border.all(
                color: Colors.transparent,
                width: AppSpacing.cardBorderWidth,
              )
            : null,
      ),
      foregroundDecoration: _kind == _CardKind.outlined
          ? BoxDecoration(
              borderRadius: AppRadii.cardBorderRadius,
              border: Border.all(
                color: colors.cardBorder,
                width: AppSpacing.cardOutlineWidth,
              ),
            )
          : null,
      child: child,
    );
  }
}
