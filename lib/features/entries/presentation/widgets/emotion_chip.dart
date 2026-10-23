import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../models/emotion.dart';

/// 감정의 대표색 (docs/DESIGN_SYSTEM.md 1장 감정 8색). 캐릭터 에셋이 오기 전까지는 이 색 원이 감정을 나타낸다.
Color emotionColor(Emotion emotion, AppColors colors) => switch (emotion) {
  Emotion.joy => colors.emotionJoy,
  Emotion.gratitude => colors.emotionGratitude,
  Emotion.excitement => colors.emotionExcitement,
  Emotion.calm => colors.emotionCalm,
  Emotion.hurt => colors.emotionHurt,
  Emotion.anxiety => colors.emotionAnxiety,
  Emotion.anger => colors.emotionAnger,
  Emotion.sadness => colors.emotionSadness,
};

/// 감정 색 원 (달력·목록·선택 격자에서 감정 캐릭터가 들어갈 자리).
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
