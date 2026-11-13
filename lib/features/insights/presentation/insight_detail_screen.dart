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
import '../../../shared/widgets/cta_button.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../../shared/widgets/summary_card.dart';
import '../../analysis/suggestion_pool.dart';
import '../../people/presentation/people_providers.dart';
import '../../todos/models/todo.dart';
import '../../todos/presentation/todos_providers.dart';
import '../models/insight.dart';
import 'insights_providers.dart';

/// 인사이트 상세와 행동 제안 (F-07, F-08): 핵심 문구 → 근거 수치(이전·지금·변화) → 제안 목록.
/// 제안마다 "체크리스트에 담기"를 누르면 체크리스트(source = suggestion)에 항목이 생긴다.
class InsightDetailScreen extends ConsumerStatefulWidget {
  const InsightDetailScreen({super.key, required this.insightId});

  final String insightId;

  @override
  ConsumerState<InsightDetailScreen> createState() =>
      _InsightDetailScreenState();
}

class _InsightDetailScreenState extends ConsumerState<InsightDetailScreen> {
  @override
  void initState() {
    super.initState();
    // 열어 보면 읽음 처리한다.
    Future.microtask(() => ref.read(markInsightReadProvider)(widget.insightId));
  }

  Future<void> _addToChecklist(Insight insight, String title) async {
    final now = ref.read(clockProvider)();
    await ref
        .read(todoActionsProvider)
        .add(
          title: title,
          personId: insight.personId,
          source: TodoSource.suggestion,
          insightId: insight.id,
          now: now,
        );
    if (mounted) showAppToast(context, '체크리스트에 담았어요');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final insight = ref.watch(insightProvider(widget.insightId)).value;
    if (insight == null) {
      return const PageScaffold(
        title: '인사이트',
        body: Center(child: EmptyState(message: '인사이트를 찾을 수 없어요')),
      );
    }

    final person = ref.watch(personProvider(insight.personId));
    final name = person?.name ?? '이 인물';
    final todos = ref.watch(todosProvider).value ?? const <Todo>[];
    final e = insight.evidence;
    final change = e.indexTo - e.indexFrom;
    final negative = insight.type == InsightType.negativeTrend;

    return PageScaffold(
      title: '인사이트',
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
            AppCard.pink(
              padding: const EdgeInsets.all(AppSpacing.space20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        negative ? AppAssets.forum : AppAssets.sealCheck,
                        width: 28,
                        height: 28,
                      ),
                      const SizedBox(width: AppSpacing.space8),
                      Text(
                        name,
                        style: AppTextStyles.groupTitle.copyWith(
                          color: colors.brand,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space12),
                  Semantics(
                    header: true,
                    child: Text(
                      insight.message,
                      style: AppTextStyles.greeting.copyWith(
                        color: colors.textBlack,
                        height: 1.3,
                      ),
                    ),
                  ),
                  if (negative && e.negCount != null) ...[
                    const SizedBox(height: AppSpacing.space8),
                    Text(
                      '최근 10일 동안 부정적인 기록이 ${e.negCount}건 있었어요.',
                      style: AppTextStyles.recordCardSubtitle.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space12),
            SummaryCard(
              items: [
                SummaryItem(value: '${e.indexFrom}', label: '이전 지수'),
                SummaryItem(value: '${e.indexTo}', label: '지금 지수'),
                SummaryItem(
                  value: '${change > 0 ? '+' : ''}$change',
                  label: '변화',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space32),
            Text(
              '이렇게 해 보면 어떨까요?',
              style: AppTextStyles.sectionTitle.copyWith(
                color: colors.textBlack,
              ),
            ),
            const SizedBox(height: AppSpacing.space12),
            for (final suggestion in SuggestionPool.forInsight(
              insight.type,
              name,
            )) ...[
              _SuggestionTile(
                text: suggestion,
                added: todos.any(
                  (t) => t.insightId == insight.id && t.title == suggestion,
                ),
                onAdd: () => _addToChecklist(insight, suggestion),
              ),
              const SizedBox(height: AppSpacing.actionCardGap),
            ],
            if (person != null) ...[
              const SizedBox(height: AppSpacing.space8),
              CtaButton(
                label: '$name 관계 보러 가기',
                height: 52,
                variant: CtaVariant.secondary,
                onPressed: () =>
                    context.push(AppRoutes.relationsDetail(person.id)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    required this.text,
    required this.added,
    required this.onAdd,
  });

  final String text;
  final bool added;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard.white(
      padding: const EdgeInsets.all(AppSpacing.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: AppTextStyles.rowTitle.copyWith(
              color: colors.textBlack,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.space16),
          added
              ? Row(
                  children: [
                    SvgPicture.asset(
                      AppAssets.check,
                      width: 16,
                      height: 16,
                      colorFilter: ColorFilter.mode(
                        colors.brand,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '체크리스트에 담았어요',
                      style: AppTextStyles.button.copyWith(color: colors.brand),
                    ),
                  ],
                )
              : SizedBox(
                  width: 180,
                  child: CtaButton(
                    label: '체크리스트에 담기',
                    height: 44,
                    variant: CtaVariant.soft,
                    onPressed: onAdd,
                  ),
                ),
        ],
      ),
    );
  }
}
