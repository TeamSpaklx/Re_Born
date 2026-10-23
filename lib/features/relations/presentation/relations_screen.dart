import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/app_text_button.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/summary_card.dart';
import '../../../shared/widgets/tab_page_scaffold.dart';
import '../../people/presentation/people_providers.dart';
import 'widgets/person_card.dart';

/// 관계 탭: 인물 목록과 인물별 관계 지수 (F-02, F-09).
/// 위 요약(인물 수·전체 기록·평균 지수) 아래에 인물 카드를 쌓는다.
class RelationsScreen extends ConsumerWidget {
  const RelationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final summaries = ref.watch(personSummariesProvider);

    return TabPageScaffold(
      title: '관계',
      trailing: AppTextButton(
        label: '인물 추가',
        color: colors.brand,
        onTap: () => context.push(AppRoutes.relationsNew),
      ),
      children: [
        const SizedBox(height: AppSpacing.space8),
        summaries.when(
          data: (list) {
            if (list.isEmpty) {
              return EmptyState(
                message: '아직 등록한 인물이 없어요',
                hint: '기록을 남길 사람을 먼저 추가해 보세요.',
                showMascot: true,
                actionLabel: '인물 추가',
                onAction: () => context.push(AppRoutes.relationsNew),
              );
            }
            final indexes = [
              for (final s in list)
                if (s.index != null) s.index!,
            ];
            final average = indexes.isEmpty
                ? '–'
                : '${(indexes.reduce((a, b) => a + b) / indexes.length).round()}';
            final total = list.fold<int>(0, (a, s) => a + s.entryCount);
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageMargin,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SummaryCard(
                    items: [
                      SummaryItem(value: '${list.length}', label: '인물'),
                      SummaryItem(value: '$total', label: '전체 기록'),
                      SummaryItem(value: average, label: '평균 지수'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space16),
                  for (final s in list) ...[
                    PersonCard(
                      summary: s,
                      onTap: () =>
                          context.push(AppRoutes.relationsDetail(s.person.id)),
                    ),
                    const SizedBox(height: AppSpacing.actionCardGap),
                  ],
                ],
              ),
            );
          },
          loading: () => const SizedBox(height: 200),
          error: (e, st) => ErrorState(
            onRetry: () => ref.invalidate(personSummariesProvider),
          ),
        ),
      ],
    );
  }
}
