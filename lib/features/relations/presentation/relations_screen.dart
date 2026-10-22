import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/widgets/cta_button.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/tab_page_scaffold.dart';
import '../../people/presentation/people_providers.dart';
import 'widgets/person_card.dart';

/// 관계 탭: 인물 목록과 인물별 관계 지수 (F-02, F-09). **임시 디자인**.
class RelationsScreen extends ConsumerWidget {
  const RelationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final summaries = ref.watch(personSummariesProvider);

    return TabPageScaffold(
      title: '관계',
      trailing: TextButton(
        onPressed: () => context.push(AppRoutes.relationsNew),
        child: Text(
          '인물 추가',
          style: AppTextStyles.button.copyWith(color: colors.brand),
        ),
      ),
      children: [
        const SizedBox(height: HomeLayout.headerToDate),
        summaries.when(
          data: (list) => list.isEmpty
              ? Column(
                  children: [
                    const EmptyState(
                      message: '아직 등록한 인물이 없어요',
                      hint: '기록을 남길 사람을 먼저 추가해 보세요.',
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.pageMargin,
                      ),
                      child: CtaButton(
                        label: '인물 추가',
                        height: 52,
                        onPressed: () => context.push(AppRoutes.relationsNew),
                      ),
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageMargin,
                  ),
                  child: Column(
                    children: [
                      for (final s in list) ...[
                        SizedBox(
                          width: double.infinity,
                          child: PersonCard(
                            summary: s,
                            onTap: () => context.push(
                              AppRoutes.relationsDetail(s.person.id),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.actionCardGap),
                      ],
                    ],
                  ),
                ),
          loading: () => const SizedBox.shrink(),
          error: (e, st) =>
              const EmptyState(message: '불러오지 못했어요', hint: '잠시 뒤 다시 시도해 주세요.'),
        ),
      ],
    );
  }
}
