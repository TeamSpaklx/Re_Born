import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_motion.dart';

/// 온보딩·가입 단계 진행 막대: 가는 회색 줄 위에 핑크가 [current]/[total]만큼 차오른다.
class StepProgressBar extends StatelessWidget {
  const StepProgressBar({super.key, required this.current, required this.total})
    : assert(total > 0);

  /// 지금 단계(1부터).
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: '$total단계 중 $current단계',
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          height: 4,
          child: Stack(
            children: [
              Positioned.fill(child: ColoredBox(color: colors.chip)),
              AnimatedFractionallySizedBox(
                duration: AppMotion.normal,
                curve: AppMotion.move,
                heightFactor: 1,
                widthFactor: (current / total).clamp(0, 1).toDouble(),
                alignment: Alignment.centerLeft,
                child: ColoredBox(color: colors.brand),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
