import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_motion.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/app_haptics.dart';
import '../../entries/models/intensity_level.dart';

/// 감정 강도 선택(1~5단계 기준표). 단계마다 번호·이름·기준 설명을 한 줄씩 보여 줘서
/// 기준표를 보면서 고를 수 있다. 고르기 전에는 아무것도 선택되지 않는다.
class IntensitySelector extends StatelessWidget {
  const IntensitySelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int? value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final level in IntensityLevel.values) ...[
          if (level != IntensityLevel.values.first)
            const SizedBox(height: AppSpacing.space8),
          _LevelTile(
            level: level,
            selected: value == level.value,
            onTap: () {
              AppHaptics.selection();
              onChanged(level.value);
            },
          ),
        ],
      ],
    );
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.level,
    required this.selected,
    required this.onTap,
  });

  final IntensityLevel level;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: '${level.value}단계 ${level.label}, ${level.description}',
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        key: Key('intensity-${level.value}'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space16,
            vertical: AppSpacing.space12,
          ),
          decoration: BoxDecoration(
            color: selected ? colors.cardPink : colors.cardWhite,
            borderRadius: BorderRadius.circular(AppRadii.card - 8),
            border: Border.all(
              color: selected ? colors.brand : colors.cardBorder,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: AppMotion.fast,
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? colors.brand : colors.chip,
                ),
                child: Text(
                  '${level.value}',
                  style: AppTextStyles.button.copyWith(
                    color: selected ? colors.onCta : colors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level.label,
                      style: AppTextStyles.button.copyWith(
                        color: colors.textBlack,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      level.description,
                      style: AppTextStyles.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
