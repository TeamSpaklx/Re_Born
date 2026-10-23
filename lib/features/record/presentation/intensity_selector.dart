import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_motion.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/app_haptics.dart';

/// 감정 강도 선택(1~3): 점 1·2·3개와 이름("조금/보통/많이")이 든 칸 세 개. 고르기 전에는 아무것도 선택되지 않는다.
class IntensitySelector extends StatelessWidget {
  const IntensitySelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int? value;
  final ValueChanged<int> onChanged;

  static const labels = {1: '조금', 2: '보통', 3: '많이'};

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        for (final level in labels.keys) ...[
          if (level > 1) const SizedBox(width: AppSpacing.space12),
          Expanded(
            child: Semantics(
              button: true,
              selected: value == level,
              label: '강도 ${labels[level]}',
              excludeSemantics: true,
              onTap: () => onChanged(level),
              child: GestureDetector(
                key: Key('intensity-$level'),
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  AppHaptics.selection();
                  onChanged(level);
                },
                child: AnimatedContainer(
                  duration: AppMotion.fast,
                  height: 72,
                  decoration: BoxDecoration(
                    color: value == level ? colors.cardPink : colors.cardWhite,
                    borderRadius: BorderRadius.circular(AppRadii.card - 8),
                    border: Border.all(
                      color: value == level ? colors.brand : colors.cardBorder,
                      width: value == level ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 1; i <= 3; i++)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: i <= level
                                    ? (value == level
                                          ? colors.brand
                                          : colors.textSecondary)
                                    : colors.chip,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.space8),
                      Text(
                        labels[level]!,
                        style: AppTextStyles.button.copyWith(
                          color: value == level
                              ? colors.textBlack
                              : colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
