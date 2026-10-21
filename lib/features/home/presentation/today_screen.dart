import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/bottom_nav_tokens.dart';
import '../models/home_summary.dart';
import 'home_providers.dart';
import 'widgets/action_suggestion_card.dart';
import 'widgets/home_error_view.dart';
import 'widgets/home_greeting.dart';
import 'widgets/home_top_bar.dart';
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

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    const margin = EdgeInsets.symmetric(horizontal: AppSpacing.pageMargin);

    Widget card(Widget child) => Padding(padding: margin, child: child);

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 상단 바(고정)가 차지하는 자리.
              SizedBox(height: HomeTopBar.heightOf(context)),
              const SizedBox(height: HomeLayout.headerToDate),
              HomeGreeting(today: summary.today, nickname: summary.nickname),
              const SizedBox(height: HomeLayout.greetingToRecordCard),
              card(
                RecordCardBefore(onRecord: () => context.go(AppRoutes.record)),
              ),
              const SizedBox(height: HomeLayout.recordCardToSignalTitle),
              SectionTitleRow(
                title: '최근 관계 신호',
                onSeeAll: () => context.go(AppRoutes.relations),
              ),
              const SizedBox(height: HomeLayout.sectionTitleToCard),
              for (final signal in summary.relationSignals)
                card(RelationSignalCard(signal: signal)),
              const SizedBox(height: HomeLayout.signalCardToGraph),
              card(WeeklyEmotionCard(flow: summary.weeklyEmotion)),
              const SizedBox(height: HomeLayout.graphToActionTitle),
              const SectionTitleRow(title: '오늘 해볼까요?', trailingChevron: true),
              const SizedBox(height: HomeLayout.sectionTitleToCard),
              for (var i = 0; i < summary.suggestions.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.actionCardGap),
                card(ActionSuggestionCard(suggestion: summary.suggestions[i])),
              ],
              const SizedBox(height: BottomNavTokens.scrollBottomPadding),
            ],
          ),
        ),
        const Positioned(left: 0, right: 0, top: 0, child: HomeTopBar()),
      ],
    );
  }
}
