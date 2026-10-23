import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/pressable.dart';
import '../../../people/presentation/people_providers.dart';
import 'person_avatar.dart';

/// 인물 목록의 카드 한 장: 아바타, 이름·관계 칩, 마지막 기록, 오른쪽에 관계 지수와 작은 막대.
class PersonCard extends StatelessWidget {
  const PersonCard({super.key, required this.summary, required this.onTap});

  final PersonSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final person = summary.person;
    final last = summary.daysSinceLastRecord;
    final index = summary.index;
    final lastText = last == null
        ? '아직 기록이 없어요'
        : last == 0
        ? '오늘 기록했어요'
        : '마지막 기록 $last일 전';

    return Semantics(
      button: true,
      label:
          '${person.name}, ${person.relationType.label}, $lastText, '
          '${index == null ? '관계 지수 데이터 부족' : '관계 지수 $index'}',
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: AppCard.white(
          padding: const EdgeInsets.all(AppSpacing.space16),
          child: Row(
            children: [
              PersonAvatar(person: person),
              const SizedBox(width: AppSpacing.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            person.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.actionTitle.copyWith(
                              color: colors.textBlack,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.chip,
                            borderRadius: AppRadii.pillBorderRadius,
                          ),
                          child: Text(
                            person.relationType.label,
                            style: AppTextStyles.chipLabel.copyWith(
                              color: colors.textSecondary,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$lastText · 기록 ${summary.entryCount}건',
                      style: AppTextStyles.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.space12),
              SizedBox(
                width: 64,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      index == null ? '데이터 부족' : '$index',
                      style:
                          (index == null
                                  ? AppTextStyles.caption
                                  : AppTextStyles.sectionTitle)
                              .copyWith(
                                color: index == null
                                    ? colors.textSecondary
                                    : colors.brand,
                                height: 1.2,
                              ),
                    ),
                    if (index != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '관계 지수',
                        style: AppTextStyles.caption.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: SizedBox(
                          height: 6,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ColoredBox(color: colors.chip),
                              ),
                              FractionallySizedBox(
                                widthFactor: (index / 100)
                                    .clamp(0, 1)
                                    .toDouble(),
                                child: ColoredBox(color: colors.brand),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
