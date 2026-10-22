import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/providers/clock_provider.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/choice_chip_button.dart';
import '../../../shared/widgets/cta_button.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../analysis/relation_index.dart';
import '../../entries/presentation/entries_providers.dart';
import '../../insights/models/graph_period.dart';
import '../../insights/models/insight.dart';
import '../../insights/presentation/insights_providers.dart';
import '../../people/presentation/people_providers.dart';
import 'widgets/index_line_chart.dart';

/// 인물 상세 = 관계 히스토리 (F-09). **임시 디자인**.
/// 오늘 지수, 기간(1주·1개월·3개월·전체) 선택, 지수 선 그래프, 시작 대비 변화량, 인사이트 목록.
class PersonDetailScreen extends ConsumerStatefulWidget {
  const PersonDetailScreen({super.key, required this.personId});

  final String personId;

  @override
  ConsumerState<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

enum _DeleteChoice { keepEntries, deleteEntries }

class _PersonDetailScreenState extends ConsumerState<PersonDetailScreen> {
  GraphPeriod _period = GraphPeriod.month;

  Future<void> _delete() async {
    final colors = context.colors;
    final choice = await showDialog<_DeleteChoice>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: colors.cardWhite,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadii.cardBorderRadius,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '인물을 삭제할까요?',
                style: AppTextStyles.sectionTitle.copyWith(
                  color: colors.textBlack,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '이 인물의 지수 이력과 인사이트도 함께 지워져요. 기록은 어떻게 할까요?',
                style: AppTextStyles.body.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: 20),
              CtaButton(
                label: '기록은 남기기',
                height: 48,
                onPressed: () =>
                    Navigator.of(context).pop(_DeleteChoice.keepEntries),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(_DeleteChoice.deleteEntries),
                child: Text(
                  '기록도 함께 삭제',
                  style: AppTextStyles.button.copyWith(color: colors.brand),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  '취소',
                  style: AppTextStyles.button.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (choice == null || !mounted) return;
    final router = GoRouter.of(context);
    await ref
        .read(peopleActionsProvider)
        .delete(
          widget.personId,
          deleteEntries: choice == _DeleteChoice.deleteEntries,
        );
    router.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final person = ref.watch(personProvider(widget.personId));
    if (person == null) {
      return const PageScaffold(
        title: '인물',
        body: Center(child: EmptyState(message: '인물을 찾을 수 없어요')),
      );
    }

    final now = ref.watch(clockProvider)();
    final entries = ref.watch(entriesForPersonProvider(widget.personId)).value;
    final index = entries == null ? null : RelationIndex.compute(entries, now);
    final history = ref.watch(indexHistoryProvider(widget.personId));
    final insights =
        ref.watch(insightsForPersonProvider(widget.personId)).value ??
        const <Insight>[];

    return PageScaffold(
      title: person.name,
      actions: [
        PageAction(
          label: '수정',
          onTap: () => context.push(AppRoutes.relationsEdit(person.id)),
        ),
        PageAction(label: '삭제', onTap: _delete),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageMargin,
          8,
          AppSpacing.pageMargin,
          40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              person.relationType.label,
              style: AppTextStyles.date.copyWith(color: colors.textDate),
            ),
            const SizedBox(height: 12),
            AppCard.pink(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '오늘의 관계 지수',
                          style: AppTextStyles.body.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          index == null ? '데이터 부족' : '${index.index}',
                          key: const Key('person-index'),
                          style: AppTextStyles.attendanceNumber.copyWith(
                            color: colors.brand,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index == null)
                    Flexible(
                      child: Text(
                        '기록이 3건 이상 쌓이면 지수가 계산돼요.',
                        style: AppTextStyles.caption.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              children: [
                for (final p in GraphPeriod.values)
                  ChoiceChipButton(
                    label: p.label,
                    selected: _period == p,
                    onTap: () => setState(() => _period = p),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            history.when(
              data: (all) {
                final points = _period.filter(all, now);
                if (points.isEmpty) {
                  return const AppCard.white(
                    padding: EdgeInsets.zero,
                    child: EmptyState(message: '기록이 더 쌓이면 그래프가 보여요'),
                  );
                }
                final change = indexChange(points);
                return AppCard.white(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 6, bottom: 8),
                        child: Text(
                          change == null
                              ? '변화량을 보려면 점이 2개 이상 필요해요'
                              : '시작 대비 ${change >= 0 ? '+' : ''}$change',
                          key: const Key('index-change'),
                          style: AppTextStyles.graphTitle.copyWith(
                            color: colors.textBlack,
                          ),
                        ),
                      ),
                      IndexLineChart(
                        key: const Key('index-chart'),
                        points: points,
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox(height: IndexLineChart.height),
              error: (e, st) => Column(
                children: [
                  const EmptyState(message: '불러오지 못했어요'),
                  CtaButton(
                    label: '다시 시도',
                    height: 48,
                    onPressed: () =>
                        ref.invalidate(indexHistoryProvider(widget.personId)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              '인사이트',
              style: AppTextStyles.sectionTitle.copyWith(
                color: colors.textBlack,
              ),
            ),
            const SizedBox(height: 12),
            if (insights.isEmpty)
              Text(
                '아직 감지된 변화가 없어요.',
                style: AppTextStyles.body.copyWith(color: colors.textSecondary),
              )
            else
              for (final i in insights) ...[
                _InsightTile(
                  insight: i,
                  onTap: () => context.push(AppRoutes.insightDetail(i.id)),
                ),
                const SizedBox(height: AppSpacing.actionCardGap),
              ],
          ],
        ),
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({required this.insight, required this.onTap});

  final Insight insight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final e = insight.evidence;
    final detail = insight.type == InsightType.negativeTrend
        ? '최근 10일 부정 기록 ${e.negCount}건 · 지수 ${e.indexFrom} → ${e.indexTo}'
        : '지수 ${e.indexFrom} → ${e.indexTo}';
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AppCard.white(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              insight.message,
              style: AppTextStyles.recordCardTitleBefore.copyWith(
                color: colors.textBlack,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              detail,
              style: AppTextStyles.body.copyWith(color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
