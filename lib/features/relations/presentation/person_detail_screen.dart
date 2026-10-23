import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_assets.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/providers/clock_provider.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_dialogs.dart';
import '../../../shared/widgets/donut_chart.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../../shared/widgets/pressable.dart';
import '../../../shared/widgets/segmented_control.dart';
import '../../analysis/relation_index.dart';
import '../../entries/models/emotion.dart';
import '../../entries/models/entry.dart';
import '../../entries/presentation/entries_providers.dart';
import '../../entries/presentation/widgets/emotion_chip.dart';
import '../../entries/presentation/widgets/entry_card.dart';
import '../../insights/models/graph_period.dart';
import '../../insights/models/insight.dart';
import '../../insights/presentation/insights_providers.dart';
import '../../people/presentation/people_providers.dart';
import 'widgets/index_line_chart.dart';
import 'widgets/person_avatar.dart';

/// 인물 상세 = 관계 히스토리 (F-09).
/// 오늘 지수, 기간(1주·1개월·3개월·전체) 선택, 지수 곡선 그래프와 시작 대비 변화량, 감정 분포(도넛),
/// 인사이트 목록, 최근 기록.
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
    final choice = await showAppDialog<_DeleteChoice>(
      context,
      title: '인물을 삭제할까요?',
      message: '이 인물의 지수 이력과 인사이트도 함께 지워져요. 기록은 어떻게 할까요?',
      actions: const [
        AppDialogAction(
          label: '기록은 남기기',
          value: _DeleteChoice.keepEntries,
          kind: AppDialogButtonKind.primary,
        ),
        AppDialogAction(
          label: '기록도 함께 삭제',
          value: _DeleteChoice.deleteEntries,
          kind: AppDialogButtonKind.destructive,
        ),
        AppDialogAction(label: '취소', value: null),
      ],
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
    final people = ref.watch(peopleProvider).value ?? const [];
    final names = {for (final p in people) p.id: p.name};

    final counts = <Emotion, int>{};
    for (final e in entries ?? const <Entry>[]) {
      counts[e.emotion] = (counts[e.emotion] ?? 0) + 1;
    }
    final recent = (entries ?? const <Entry>[]).take(3).toList();

    Widget sectionTitle(String text) => Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.space32,
        bottom: AppSpacing.space12,
      ),
      child: Text(
        text,
        style: AppTextStyles.sectionTitle.copyWith(color: colors.textBlack),
      ),
    );

    return PageScaffold(
      title: '',
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
          AppSpacing.space8,
          AppSpacing.pageMargin,
          AppSpacing.space40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                PersonAvatar(person: person, size: 64),
                const SizedBox(width: AppSpacing.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          person.name,
                          style: AppTextStyles.greeting.copyWith(
                            color: colors.textBlack,
                          ),
                        ),
                      ),
                      Text(
                        person.relationType.label,
                        style: AppTextStyles.recordCardSubtitle.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (person.memo != null && person.memo!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.space12),
              Text(
                person.memo!,
                style: AppTextStyles.body.copyWith(
                  color: colors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.space20),
            AppCard.pink(
              padding: const EdgeInsets.all(AppSpacing.space20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '오늘의 관계 지수',
                    style: AppTextStyles.body.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        index == null ? '데이터 부족' : '${index.index}',
                        key: const Key('person-index'),
                        style:
                            (index == null
                                    ? AppTextStyles.sectionTitle
                                    : AppTextStyles.attendanceNumber)
                                .copyWith(
                                  color: colors.brand,
                                  height: index == null ? 1.3 : 1.1,
                                ),
                      ),
                      if (index != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 2),
                          child: Text(
                            '/ 100',
                            style: AppTextStyles.body.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space12),
                  if (index != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(
                        height: 8,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: ColoredBox(color: colors.cardWhite),
                            ),
                            FractionallySizedBox(
                              widthFactor: (index.index / 100)
                                  .clamp(0, 1)
                                  .toDouble(),
                              child: ColoredBox(color: colors.brand),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Text(
                      '기록이 3건 이상 쌓이면 지수가 계산돼요.',
                      style: AppTextStyles.body.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            sectionTitle('관계 변화'),
            SegmentedControl(
              labels: [for (final p in GraphPeriod.values) p.label],
              selectedIndex: GraphPeriod.values.indexOf(_period),
              onChanged: (i) => setState(() => _period = GraphPeriod.values[i]),
            ),
            const SizedBox(height: AppSpacing.space12),
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
                          style: AppTextStyles.groupTitle.copyWith(
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
              error: (e, st) => ErrorState(
                onRetry: () =>
                    ref.invalidate(indexHistoryProvider(widget.personId)),
              ),
            ),
            if (counts.isNotEmpty) ...[
              sectionTitle('자주 느낀 감정'),
              AppCard.white(
                padding: const EdgeInsets.all(AppSpacing.space20),
                child: Row(
                  children: [
                    DonutChart(
                      size: 104,
                      strokeWidth: 16,
                      segments: [
                        for (final e in Emotion.values)
                          if ((counts[e] ?? 0) > 0)
                            DonutSegment(
                              value: counts[e]!.toDouble(),
                              color: emotionColor(e, colors),
                            ),
                      ],
                      center: Text(
                        '${entries!.length}건',
                        style: AppTextStyles.groupTitle.copyWith(
                          color: colors.textBlack,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space20),
                    Expanded(child: _Legend(counts: counts)),
                  ],
                ),
              ),
            ],
            sectionTitle('인사이트'),
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
            if (recent.isNotEmpty) ...[
              sectionTitle('최근 기록'),
              for (final e in recent) ...[
                EntryCard(
                  entry: e,
                  personName: names[e.personId],
                  onTap: () => context.push(AppRoutes.recordDetail(e.id)),
                ),
                const SizedBox(height: AppSpacing.actionCardGap),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// 감정 분포 범례: 개수가 많은 순으로 최대 4개.
class _Legend extends StatelessWidget {
  const _Legend({required this.counts});

  final Map<Emotion, int> counts;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final total = counts.values.fold<int>(0, (a, b) => a + b);
    final top = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final e in top.take(4))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                EmotionDot(emotion: e.key, size: 10),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    e.key.label,
                    style: AppTextStyles.body.copyWith(color: colors.textBlack),
                  ),
                ),
                Text(
                  '${(e.value * 100 / total).round()}%',
                  style: AppTextStyles.body.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
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
    return Semantics(
      button: true,
      label: '${insight.message}, $detail',
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: AppCard.white(
          padding: const EdgeInsets.all(AppSpacing.space16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight.message,
                      style: AppTextStyles.groupTitle.copyWith(
                        color: colors.textBlack,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detail,
                      style: AppTextStyles.body.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SvgPicture.asset(AppAssets.chevronSignal),
            ],
          ),
        ),
      ),
    );
  }
}
