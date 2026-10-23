import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/korean_date.dart';
import '../../../../shared/widgets/pressable.dart';
import '../../models/entry.dart';
import 'emotion_chip.dart';
import 'emotion_face.dart';

/// 기록 목록의 카드 한 장: 감정 캐릭터 + 감정 이름·강도·시각, 인물·분석 상태 칩, 본문 미리보기.
/// 배경은 감정 대표색을 옅게 깐다(Mentry식 감정색 카드).
class EntryCard extends StatelessWidget {
  const EntryCard({
    super.key,
    required this.entry,
    required this.personName,
    required this.onTap,
  });

  final Entry entry;
  final String? personName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tint = emotionColor(entry.emotion, colors);
    final time = formatKoreanTime(entry.createdAt);
    return Semantics(
      button: true,
      label:
          '${entry.emotion.label} 강도 ${entry.intensity}, $time, '
          '${personName == null ? '' : '$personName, '}${entry.body}',
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.space16),
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              tint.withValues(alpha: 0.16),
              colors.cardWhite,
            ),
            borderRadius: BorderRadius.circular(AppRadii.card - 8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EmotionFace(emotion: entry.emotion, size: 44),
              const SizedBox(width: AppSpacing.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          entry.emotion.label,
                          style: AppTextStyles.groupTitle.copyWith(
                            color: colors.textBlack,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.space8),
                        IntensityDots(level: entry.intensity),
                        const Spacer(),
                        Text(
                          time,
                          style: AppTextStyles.caption.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (personName != null ||
                        entry.analysisStatus != AnalysisStatus.done) ...[
                      const SizedBox(height: AppSpacing.space8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (personName != null)
                            _Pill(
                              label: personName!,
                              textColor: colors.textStrong,
                              color: colors.cardWhite,
                            ),
                          if (entry.analysisStatus == AnalysisStatus.pending)
                            _Pill(
                              label: '분석 중',
                              textColor: colors.textSecondary,
                              color: colors.cardWhite,
                            ),
                          if (entry.analysisStatus == AnalysisStatus.failed)
                            _Pill(
                              label: '분석 실패',
                              textColor: colors.danger,
                              color: colors.cardWhite,
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: AppSpacing.space8),
                    Text(
                      entry.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        color: colors.textStrong,
                        height: 1.45,
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

/// 강도 1~3을 점 세 개 중 채워진 개수로 보여 준다.
class IntensityDots extends StatelessWidget {
  const IntensityDots({super.key, required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= 3; i++)
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i <= level
                    ? colors.textStrong
                    : colors.textSecondary.withValues(alpha: 0.3),
              ),
            ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadii.pillBorderRadius,
      ),
      child: Text(
        label,
        style: AppTextStyles.chipLabel.copyWith(color: textColor, height: 1.3),
      ),
    );
  }
}
