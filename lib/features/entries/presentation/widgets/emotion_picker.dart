import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_motion.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../models/emotion.dart';
import 'emotion_chip.dart';
import 'emotion_face.dart';

/// 감정 선택 격자: 4열 × 2행, 감정 캐릭터(자리 표시) + 이름. 선택된 칸은 브랜드 핑크 테두리가 생기고
/// 살짝 커진다. (docs/DESIGN_SYSTEM.md 7.6)
class EmotionPicker extends StatelessWidget {
  const EmotionPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final Emotion? selected;
  final ValueChanged<Emotion> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return LayoutBuilder(
      builder: (context, constraints) {
        const columns = 4;
        const gap = AppSpacing.space12;
        final cell = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: AppSpacing.space16,
          children: [
            for (final emotion in Emotion.values)
              SizedBox(
                width: cell,
                child: Semantics(
                  button: true,
                  selected: selected == emotion,
                  label: emotion.label,
                  excludeSemantics: true,
                  onTap: () => onChanged(emotion),
                  child: GestureDetector(
                    key: Key('emotion-${emotion.name}'),
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      AppHaptics.selection();
                      onChanged(emotion);
                    },
                    child: Column(
                      children: [
                        AnimatedScale(
                          scale: selected == emotion ? 1.06 : 1,
                          duration: AppMotion.fast,
                          curve: AppMotion.enter,
                          child: AnimatedContainer(
                            duration: AppMotion.fast,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selected == emotion
                                    ? colors.brand
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: EmotionFace(
                              emotion: emotion,
                              size: cell - 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space8),
                        AnimatedDefaultTextStyle(
                          duration: AppMotion.fast,
                          style: AppTextStyles.button.copyWith(
                            color: selected == emotion
                                ? colors.textBlack
                                : colors.textSecondary,
                          ),
                          child: Text(emotion.label),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// 감정 비율 막대: 감정별 개수를 한 줄로 쌓아 보여 주고, 아래에 범례를 둔다.
/// [counts]가 비면 아무것도 그리지 않는다.
class EmotionRatioBar extends StatelessWidget {
  const EmotionRatioBar({super.key, required this.counts});

  final Map<Emotion, int> counts;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final total = counts.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) return const SizedBox.shrink();
    final sorted = counts.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 12,
            child: Row(
              children: [
                for (final e in sorted)
                  Expanded(
                    flex: e.value,
                    child: ColoredBox(color: emotionColor(e.key, colors)),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.space12),
        Wrap(
          spacing: AppSpacing.space16,
          runSpacing: AppSpacing.space8,
          children: [
            for (final e in sorted)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  EmotionDot(emotion: e.key, size: 8),
                  const SizedBox(width: 6),
                  Text(
                    '${e.key.label} ${(e.value * 100 / total).round()}%',
                    style: AppTextStyles.body.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
