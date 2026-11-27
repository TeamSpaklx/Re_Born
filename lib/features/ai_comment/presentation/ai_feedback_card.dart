import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/errors/app_error_log.dart';
import '../../../core/providers/clock_provider.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_dialogs.dart';
import '../../../shared/widgets/app_text_button.dart';
import '../../../shared/widgets/cta_button.dart';
import '../../entries/models/entry.dart';
import '../../entries/presentation/entries_providers.dart';
import '../../todos/models/todo.dart';
import '../../todos/presentation/todos_providers.dart';

/// 일기 한 건의 AI 코멘트 카드: 받는 중 / 실패(다시 분석) / 코멘트 + 행동 제안(체크리스트에 담기).
/// 저장 직후 결과 화면과 기록 상세가 같이 쓴다.
class AiFeedbackCard extends ConsumerWidget {
  const AiFeedbackCard({super.key, required this.entry});

  final Entry entry;

  Future<void> _addTodo(
    BuildContext context,
    WidgetRef ref,
    String title,
  ) async {
    try {
      await ref
          .read(todoActionsProvider)
          .add(
            title: title,
            source: TodoSource.suggestion,
            entryId: entry.id,
            now: ref.read(clockProvider)(),
          );
      if (context.mounted) {
        showAppToast(context, '체크리스트에 담았어요', success: true);
      }
    } catch (error, stack) {
      ref.read(appErrorLogProvider).record(error, stack, where: 'add-todo');
      if (context.mounted) showAppToast(context, '담지 못했어요. 다시 시도해 주세요.');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final feedback = entry.feedback;
    final todos = ref.watch(todosProvider).value ?? const <Todo>[];
    bool added(String title) =>
        todos.any((t) => t.entryId == entry.id && t.title == title);

    final Widget body;
    if (feedback != null) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            feedback.comment,
            key: const Key('ai-comment'),
            style: AppTextStyles.recordCardSubtitle.copyWith(
              color: colors.textBlack,
              height: 1.6,
            ),
          ),
          if (feedback.suggestions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.space20),
            Text(
              '이런 걸 해 보면 어떨까요?',
              style: AppTextStyles.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.space8),
            for (final (i, s) in feedback.suggestions.indexed)
              _SuggestionRow(
                key: Key('ai-suggestion-$i'),
                title: s,
                added: added(s),
                onAdd: () => _addTodo(context, ref, s),
              ),
          ],
        ],
      );
    } else if (entry.analysisStatus == AnalysisStatus.failed) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'AI 코멘트를 받지 못했어요.',
            style: AppTextStyles.body.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.space12),
          CtaButton(
            label: '다시 분석',
            height: 48,
            onPressed: () =>
                ref.read(recordActionsProvider).retryAnalysis(entry.id),
          ),
        ],
      );
    } else {
      body = Row(
        key: const Key('ai-comment-pending'),
        children: [
          CupertinoActivityIndicator(color: colors.brand, radius: 8),
          const SizedBox(width: AppSpacing.space12),
          Expanded(
            child: Text(
              '일기를 읽고 코멘트를 쓰고 있어요…',
              style: AppTextStyles.body.copyWith(color: colors.textSecondary),
            ),
          ),
        ],
      );
    }

    return AppCard.white(
      padding: const EdgeInsets.all(AppSpacing.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'AI 코멘트',
            style: AppTextStyles.groupTitle.copyWith(color: colors.brand),
          ),
          const SizedBox(height: AppSpacing.space12),
          body,
        ],
      ),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({
    super.key,
    required this.title,
    required this.added,
    required this.onAdd,
  });

  final String title;
  final bool added;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.space8),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space16,
        AppSpacing.space12,
        AppSpacing.space12,
        AppSpacing.space12,
      ),
      decoration: BoxDecoration(
        color: colors.chip,
        borderRadius: BorderRadius.circular(AppRadii.button),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.body.copyWith(color: colors.textStrong),
            ),
          ),
          const SizedBox(width: AppSpacing.space8),
          added
              ? Text(
                  '담았어요',
                  style: AppTextStyles.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                )
              : AppTextButton(
                  label: '체크리스트에 담기',
                  color: colors.brand,
                  onTap: onAdd,
                ),
        ],
      ),
    );
  }
}
