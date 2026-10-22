import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../models/entry.dart';

/// 기록 목록의 카드 한 장: 감정·인물 칩, 본문 미리보기, 분석 상태.
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
    return Semantics(
      button: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AppCard.white(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _Pill(
                    label: '${entry.emotion.label} ${entry.intensity}',
                    color: colors.brand,
                    textColor: colors.onCta,
                  ),
                  if (personName != null)
                    _Pill(
                      label: personName!,
                      color: colors.chip,
                      textColor: colors.textSecondary,
                    ),
                  if (entry.analysisStatus == AnalysisStatus.pending)
                    _Pill(
                      label: '분석 중',
                      color: colors.chip,
                      textColor: colors.textSecondary,
                    ),
                  if (entry.analysisStatus == AnalysisStatus.failed)
                    _Pill(
                      label: '분석 실패',
                      color: colors.chip,
                      textColor: colors.brand,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                entry.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(color: colors.textBlack),
              ),
            ],
          ),
        ),
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
