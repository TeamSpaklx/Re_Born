import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/providers/clock_provider.dart';
import '../../../core/utils/korean_date.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/emotion_line_chart.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/pressable.dart';
import '../../../shared/widgets/segmented_control.dart';
import '../../../shared/widgets/skeleton.dart';
import '../../../shared/widgets/tab_page_scaffold.dart';
import '../../analysis/emotion_stats_builder.dart';
import '../../entries/models/entry.dart';
import '../../entries/models/intensity_level.dart';
import '../../entries/presentation/entries_providers.dart';
import '../../entries/presentation/widgets/emotion_face.dart';
import '../../entries/presentation/widgets/emotion_picker.dart';

/// 분석 탭: 기간(1주·1달)별 감정 수치 그래프, 감정·강도 분포, 최근 AI 코멘트.
/// 감정 수치는 일기의 점수(감정 방향 × 강도 1~5단계, −5~+5)를 날짜별로 평균한 값이다.
class AnalysisScreen extends ConsumerStatefulWidget {
  const AnalysisScreen({super.key});

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen> {
  StatsPeriod _period = StatsPeriod.week;

  @override
  Widget build(BuildContext context) {
    final now = ref.watch(clockProvider)();
    final entries = ref.watch(entriesProvider);
    return TabPageScaffold(
      title: '분석',
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageMargin,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.space8),
              SegmentedControl(
                labels: [for (final p in StatsPeriod.values) p.label],
                selectedIndex: _period.index,
                onChanged: (i) =>
                    setState(() => _period = StatsPeriod.values[i]),
              ),
              const SizedBox(height: AppSpacing.space16),
              entries.when(
                skipLoadingOnReload: true,
                data: (all) {
                  final stats = buildEmotionStats(all, now, _period);
                  if (stats.entryCount == 0) {
                    return EmptyState(
                      message: '이 기간에 쓴 일기가 없어요',
                      hint: '일기를 쓰면 감정 수치와 AI 코멘트가 여기에 모여요.',
                      showMascot: true,
                      actionLabel: '일기 쓰기',
                      onAction: () => context.push(AppRoutes.recordNew),
                    );
                  }
                  return _StatsBody(stats: stats);
                },
                loading: () => const SkeletonList(count: 3),
                error: (e, st) =>
                    ErrorState(onRetry: () => ref.invalidate(entriesProvider)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsBody extends StatelessWidget {
  const _StatsBody({required this.stats});

  final EmotionStats stats;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final avg = stats.averageScore!;
    final avgText = avg > 0
        ? '+${avg.toStringAsFixed(1)}'
        : avg.toStringAsFixed(1);
    TextStyle title() =>
        AppTextStyles.groupTitle.copyWith(color: colors.textBlack);
    TextStyle caption() =>
        AppTextStyles.caption.copyWith(color: colors.textSecondary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard.white(
          key: const Key('emotion-score-card'),
          padding: const EdgeInsets.all(AppSpacing.space20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('감정 수치', style: title()),
              const SizedBox(height: 4),
              Text(
                '일기 ${stats.entryCount}개 · 평균 $avgText (−5 ~ +5)',
                key: const Key('emotion-score-summary'),
                style: caption(),
              ),
              const SizedBox(height: AppSpacing.space12),
              EmotionLineChart(
                key: const Key('emotion-score-chart'),
                points: [
                  for (final d in stats.daily) ChartPoint(d.date, d.average),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space16),
        AppCard.white(
          padding: const EdgeInsets.all(AppSpacing.space20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('감정 분포', style: title()),
              const SizedBox(height: AppSpacing.space12),
              EmotionRatioBar(counts: stats.emotionCounts),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space16),
        AppCard.white(
          key: const Key('intensity-distribution'),
          padding: const EdgeInsets.all(AppSpacing.space20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('감정 강도', style: title()),
              const SizedBox(height: 4),
              Text('1~5단계 기준표로 고른 강도의 분포예요.', style: caption()),
              const SizedBox(height: AppSpacing.space16),
              _LevelBars(counts: stats.levelCounts),
            ],
          ),
        ),
        if (stats.recentFeedback.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.space24,
              bottom: AppSpacing.space12,
            ),
            child: Semantics(
              header: true,
              child: Text(
                '최근 AI 코멘트',
                style: AppTextStyles.sectionTitle.copyWith(
                  color: colors.textBlack,
                ),
              ),
            ),
          ),
          for (final e in stats.recentFeedback)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.actionCardGap),
              child: _FeedbackCard(entry: e),
            ),
        ],
      ],
    );
  }
}

/// 강도 단계별 가로 막대(가장 많은 단계를 꽉 채운 길이로).
class _LevelBars extends StatelessWidget {
  const _LevelBars({required this.counts});

  final Map<IntensityLevel, int> counts;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final most = counts.values.fold<int>(0, (a, b) => a > b ? a : b);
    return Column(
      children: [
        for (final level in IntensityLevel.values)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space8),
            child: Row(
              children: [
                SizedBox(
                  width: 84,
                  child: Text(
                    '${level.value} ${level.label}',
                    style: AppTextStyles.caption.copyWith(
                      color: colors.textStrong,
                    ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: AppRadii.pillBorderRadius,
                    child: SizedBox(
                      height: 10,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ColoredBox(color: colors.chip),
                          ),
                          if (most > 0)
                            FractionallySizedBox(
                              widthFactor: counts[level]! / most,
                              child: ColoredBox(color: colors.barStrong),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.space8),
                SizedBox(
                  width: 24,
                  child: Text(
                    '${counts[level]}',
                    key: Key('level-count-${level.value}'),
                    textAlign: TextAlign.end,
                    style: AppTextStyles.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.entry});

  final Entry entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Pressable(
      onTap: () => context.push(AppRoutes.recordDetail(entry.id)),
      child: AppCard.white(
        padding: const EdgeInsets.all(AppSpacing.space16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EmotionFace(emotion: entry.emotion, size: 36),
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${formatKoreanDate(entry.createdAt)} · ${entry.emotion.label}',
                    style: AppTextStyles.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.feedback!.comment,
                    maxLines: 3,
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
    );
  }
}
