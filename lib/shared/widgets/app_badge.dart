import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

/// 읽지 않음 표시. [count]가 있으면 숫자 뱃지(99 넘으면 "99+"), 없으면 작은 점.
class AppBadge extends StatelessWidget {
  const AppBadge.dot({super.key}) : count = null;

  const AppBadge.count(int this.count, {super.key});

  final int? count;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (count == null) {
      return Container(
        width: ComponentLayout.badgeDot,
        height: ComponentLayout.badgeDot,
        decoration: BoxDecoration(color: colors.danger, shape: BoxShape.circle),
      );
    }
    final text = count! > 99 ? '99+' : '$count';
    return Container(
      constraints: const BoxConstraints(
        minWidth: ComponentLayout.badgeCountHeight,
      ),
      height: ComponentLayout.badgeCountHeight,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.danger,
        borderRadius: BorderRadius.circular(ComponentLayout.badgeCountHeight),
      ),
      child: Text(
        text,
        style: AppTextStyles.badge.copyWith(color: colors.onCta),
      ),
    );
  }
}

/// [child] 오른쪽 위 모서리에 [badge]를 겹쳐 놓는다 (벨 아이콘, 탭 아이콘).
class Badged extends StatelessWidget {
  const Badged({super.key, required this.child, this.badge});

  final Widget child;

  /// null이면 뱃지를 보이지 않는다.
  final AppBadge? badge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (badge != null) Positioned(right: -4, top: -4, child: badge!),
      ],
    );
  }
}
