import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../models/emotion.dart';

/// 감정의 대표색 (docs/DESIGN_SYSTEM.md 1장 감정 7색, 캐릭터 이름표 색). 카드 배경·비율 막대·범례에 쓴다.
Color emotionColor(Emotion emotion, AppColors colors) => switch (emotion) {
  Emotion.joy => colors.emotionJoy,
  Emotion.sadness => colors.emotionSadness,
  Emotion.neutral => colors.emotionNeutral,
  Emotion.anger => colors.emotionAnger,
  Emotion.anxiety => colors.emotionAnxiety,
  Emotion.love => colors.emotionLove,
  Emotion.excited => colors.emotionExcited,
};

/// 감정 색 점 (비율 막대 범례·칩).
class EmotionDot extends StatelessWidget {
  const EmotionDot({super.key, required this.emotion, this.size = 12});

  final Emotion emotion;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: emotionColor(emotion, context.colors),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// 감정 이름 칩: 감정 색의 옅은 배경 + 색 점 + 이름. 기록 카드·상세의 감정 표시.
class EmotionChip extends StatelessWidget {
  const EmotionChip({super.key, required this.emotion});

  final Emotion emotion;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = emotionColor(emotion, colors);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space12,
        vertical: AppSpacing.space4 + 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.24),
        borderRadius: AppRadii.pillBorderRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          EmotionDot(emotion: emotion, size: 8),
          const SizedBox(width: AppSpacing.space8 - 2),
          Text(
            emotion.label,
            style: AppTextStyles.button.copyWith(color: colors.textStrong),
          ),
        ],
      ),
    );
  }
}
