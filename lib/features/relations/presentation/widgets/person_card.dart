import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/pressable.dart';
import '../../../analysis/relation_band.dart';
import '../../../people/presentation/people_providers.dart';
import 'person_avatar.dart';

/// 인물 목록의 카드 한 장: 아바타, 이름·관계 칩, 마지막 기록, 오른쪽에 관계 지수.
/// 지수는 숫자만으로는 좋고 나쁨이 안 읽혀서, 구간 설명(가까워요·무난해요·조금 멀어졌어요)과
/// 지난주 대비 변화(▲/▼)를 같이 보여 준다. 분홍은 "가까워요"에만 쓴다(분홍 역할 규칙, DESIGN_SYSTEM).
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
          '${index == null ? '관계 지수 데이터 부족' : '관계 지수 $index, ${summary.band!.label}'}'
          '${_changeSpoken(summary.indexChange)}',
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
                width: PersonCardLayout.indexColumnWidth,
                child: index == null
                    ? Text(
                        '데이터 부족',
                        textAlign: TextAlign.end,
                        style: AppTextStyles.caption.copyWith(
                          color: colors.textSecondary,
                          height: 1.2,
                        ),
                      )
                    : _IndexColumn(
                        index: index,
                        band: summary.band!,
                        change: summary.indexChange,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 지난주 대비 변화를 스크린 리더용 문장으로.
String _changeSpoken(int? change) {
  if (change == null || change == 0) return '';
  return change > 0 ? ', 지난주보다 $change점 올랐어요' : ', 지난주보다 ${-change}점 내렸어요';
}

/// 오른쪽 지수 칸: 숫자 + 변화(▲/▼), 구간 설명, 작은 막대.
class _IndexColumn extends StatelessWidget {
  const _IndexColumn({
    required this.index,
    required this.band,
    required this.change,
  });

  final int index;
  final RelationBand band;
  final int? change;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final close = band == RelationBand.close;
    final numberColor = close ? colors.brand : colors.textBlack;
    final barColor = close ? colors.brand : colors.iconMuted;
    final delta = change;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            if (delta != null && delta != 0) ...[
              Text(
                delta > 0 ? '▲$delta' : '▼${-delta}',
                key: const Key('person-index-change'),
                style: AppTextStyles.caption.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.space4),
            ],
            Text(
              '$index',
              style: AppTextStyles.sectionTitle.copyWith(
                color: numberColor,
                height: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          band.label,
          maxLines: 1,
          style: AppTextStyles.caption.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: SizedBox(
            height: 6,
            width: PersonCardLayout.barWidth,
            child: Stack(
              children: [
                Positioned.fill(child: ColoredBox(color: colors.chip)),
                FractionallySizedBox(
                  heightFactor: 1,
                  widthFactor: (index / 100).clamp(0, 1).toDouble(),
                  child: ColoredBox(color: barColor),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
