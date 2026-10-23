import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/bottom_nav_tokens.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/providers/clock_provider.dart';
import '../../../shared/widgets/app_dialogs.dart';
import '../../todos/models/todo.dart';
import '../../todos/presentation/todos_providers.dart';
import '../models/action_suggestion.dart';
import '../models/home_summary.dart';
import 'home_providers.dart';
import 'widgets/action_suggestion_card.dart';
import 'widgets/home_error_view.dart';
import 'widgets/home_greeting.dart';
import 'widgets/home_top_bar.dart';
import 'widgets/record_card_after.dart';
import 'widgets/record_card_before.dart';
import 'widgets/relation_signal_card.dart';
import 'widgets/section_title_row.dart';
import 'widgets/weekly_emotion_card.dart';

/// 투데이(홈) 탭. 지금은 Before(기록 전) 상태만 구현한다. After(기록 완료)는 다음 작업.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(homeSummaryProvider);
    final background = context.colors.background;

    return Scaffold(
      backgroundColor: background,
      body: summary.when(
        data: (data) => _HomeContent(summary: data),
        // 로딩 화면(스켈레톤)은 디자인이 나오면 만든다. 그때까지는 배경만 보인다.
        loading: () => const SizedBox.expand(),
        error: (error, stack) =>
            HomeErrorView(onRetry: () => ref.invalidate(homeSummaryProvider)),
      ),
    );
  }
}

class _HomeContent extends ConsumerStatefulWidget {
  const _HomeContent({required this.summary});

  final HomeSummary summary;

  @override
  ConsumerState<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends ConsumerState<_HomeContent> {
  final _scrollController = ScrollController();

  HomeSummary get summary => widget.summary;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 상단 바의 로고를 누르면 맨 위로 부드럽게 올라간다.
  void _scrollToTop() {
    if (!_scrollController.hasClients || _scrollController.offset <= 0) return;
    _scrollController.animateTo(
      0,
      duration: HomeLayout.scrollToTopDuration,
      curve: Curves.easeInOutCubic,
    );
  }

  /// 제안을 체크리스트에 담는다(이미 담았으면 아무 일도 하지 않는다).
  Future<void> _add(
    BuildContext context,
    WidgetRef ref,
    ActionSuggestion suggestion,
  ) async {
    if (suggestion.added) return;
    await ref
        .read(todoActionsProvider)
        .add(
          title: suggestion.title,
          personId: suggestion.personId,
          source: TodoSource.suggestion,
          insightId: suggestion.insightId,
          now: ref.read(clockProvider)(),
        );
    if (context.mounted) showAppToast(context, '체크리스트에 담았어요');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const margin = EdgeInsets.symmetric(horizontal: AppSpacing.pageMargin);

    Widget card(Widget child) => Padding(padding: margin, child: child);

    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 상단 바(고정)가 차지하는 자리.
              SizedBox(height: HomeTopBar.heightOf(context)),
              const SizedBox(height: HomeLayout.headerToDate),
              HomeGreeting(today: summary.today, nickname: summary.nickname),
              const SizedBox(height: HomeLayout.greetingToRecordCard),
              card(
                summary.todayRecorded
                    ? RecordCardAfter(
                        streak: summary.streak,
                        peopleCount: summary.todayPeopleCount,
                        onViewToday: () {
                          final id = summary.todayEntryId;
                          if (id != null) {
                            context.push(AppRoutes.recordDetail(id));
                          }
                        },
                      )
                    : RecordCardBefore(
                        onRecord: () => context.go(AppRoutes.record),
                      ),
              ),
              const SizedBox(height: HomeLayout.recordCardToSignalTitle),
              SectionTitleRow(
                title: '최근 관계 신호',
                onSeeAll: () => context.go(AppRoutes.relations),
              ),
              const SizedBox(height: HomeLayout.sectionTitleToCard),
              if (summary.relationSignals.isEmpty)
                card(
                  Text(
                    '아직 감지된 관계 변화가 없어요. 기록이 쌓이면 알려 드릴게요.',
                    style: AppTextStyles.body.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                )
              else
                for (final signal in summary.relationSignals)
                  card(
                    RelationSignalCard(
                      signal: signal,
                      onTap: () => context.push(
                        AppRoutes.insightDetail(signal.insightId),
                      ),
                    ),
                  ),
              const SizedBox(height: HomeLayout.signalCardToGraph),
              card(WeeklyEmotionCard(flow: summary.weeklyEmotion)),
              const SizedBox(height: HomeLayout.graphToActionTitle),
              const SectionTitleRow(title: '오늘 해볼까요?', trailingChevron: true),
              const SizedBox(height: HomeLayout.sectionTitleToCard),
              if (summary.suggestions.isEmpty)
                card(
                  Text(
                    '관계 변화가 감지되면 해 볼 만한 일을 제안해 드려요.',
                    style: AppTextStyles.body.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              for (var i = 0; i < summary.suggestions.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.actionCardGap),
                card(
                  ActionSuggestionCard(
                    suggestion: summary.suggestions[i],
                    onTap: () => context.push(
                      AppRoutes.insightDetail(summary.suggestions[i].insightId),
                    ),
                    onAdd: () => _add(context, ref, summary.suggestions[i]),
                  ),
                ),
              ],
              const SizedBox(height: BottomNavTokens.scrollBottomPadding),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: HomeTopBar(onLogoTap: _scrollToTop),
        ),
      ],
    );
  }
}
