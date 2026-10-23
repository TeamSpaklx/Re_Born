import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/bottom_nav_tokens.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/providers/clock_provider.dart';
import '../../../app/theme/app_motion.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_dialogs.dart';
import '../../../shared/widgets/cta_button.dart';
import '../../todos/models/todo.dart';
import '../../todos/presentation/todos_providers.dart';
import '../models/action_suggestion.dart';
import '../models/home_summary.dart';
import 'home_providers.dart';
import 'widgets/action_suggestion_card.dart';
import 'widgets/home_error_view.dart';
import 'widgets/home_greeting.dart';
import 'widgets/home_skeleton.dart';
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
        loading: () => const HomeSkeleton(),
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

  /// 방금 담은 제안: 채워진 원을 잠깐 보여 준 뒤 목록에서 뺀다(자리 번호와 함께 보관).
  final _justAdded = <String, ({ActionSuggestion suggestion, int slot})>{};

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

  /// 제안을 체크리스트에 담는다. 담으면 원이 채워지고 잠시 뒤 다음 제안이 그 자리로 온다.
  Future<void> _add(
    BuildContext context,
    WidgetRef ref,
    ActionSuggestion suggestion,
    int slot,
  ) async {
    if (suggestion.added || _justAdded.containsKey(suggestion.id)) return;
    setState(() {
      _justAdded[suggestion.id] = (
        suggestion: suggestion.asAdded(),
        slot: slot,
      );
    });
    Future<void>.delayed(HomeLayout.suggestionSwapDelay, () {
      if (mounted) setState(() => _justAdded.remove(suggestion.id));
    });
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

  /// 화면에 보일 제안: 새로 계산된 제안 앞에 방금 담은 카드를 제자리에 끼워 넣고 두 장으로 자른다.
  List<ActionSuggestion> _visibleSuggestions() {
    final shown = [...summary.suggestions];
    final kept = _justAdded.values.toList()
      ..sort((a, b) => a.slot.compareTo(b.slot));
    for (final k in kept) {
      shown.insert(k.slot.clamp(0, shown.length), k.suggestion);
    }
    return shown.take(2).toList();
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
              card(
                WeeklyEmotionCard(
                  flow: summary.weeklyEmotion,
                  onTitleTap: () => context.go(AppRoutes.record),
                ),
              ),
              const SizedBox(height: HomeLayout.graphToActionTitle),
              SectionTitleRow(
                title: '오늘 해볼까요?',
                trailingChevron: true,
                onTitleTap: () => context.go(AppRoutes.all),
              ),
              const SizedBox(height: HomeLayout.sectionTitleToCard),
              if (_visibleSuggestions().isEmpty)
                card(
                  summary.suggestionsDone
                      ? _SuggestionsDone(
                          onOpenChecklist: () => context.go(AppRoutes.all),
                        )
                      : Text(
                          '관계 변화가 감지되면 해 볼 만한 일을 제안해 드려요.',
                          style: AppTextStyles.body.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                ),
              for (final (i, s) in _visibleSuggestions().indexed) ...[
                if (i > 0) const SizedBox(height: AppSpacing.actionCardGap),
                card(
                  AnimatedSwitcher(
                    duration: AppMotion.normal,
                    switchInCurve: AppMotion.enter,
                    child: ActionSuggestionCard(
                      key: ValueKey(s.id),
                      suggestion: s,
                      onTap: () =>
                          context.push(AppRoutes.insightDetail(s.insightId)),
                      onAdd: () => _add(context, ref, s, i),
                    ),
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

/// 제안을 모두 담았을 때의 한 줄 안내와 체크리스트로 가는 버튼.
class _SuggestionsDone extends StatelessWidget {
  const _SuggestionsDone({required this.onOpenChecklist});

  final VoidCallback onOpenChecklist;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard.white(
      padding: const EdgeInsets.all(AppSpacing.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '오늘 제안을 모두 담았어요',
            style: AppTextStyles.groupTitle.copyWith(color: colors.textBlack),
          ),
          const SizedBox(height: 4),
          Text(
            '체크리스트에서 하나씩 해 보세요.',
            style: AppTextStyles.body.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.space12),
          CtaButton(
            label: '체크리스트 보기',
            height: 44,
            variant: CtaVariant.soft,
            onPressed: onOpenChecklist,
          ),
        ],
      ),
    );
  }
}
