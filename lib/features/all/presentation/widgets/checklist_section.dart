import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_assets.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/errors/app_error_log.dart';
import '../../../../core/providers/clock_provider.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/cta_button.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../todos/models/todo.dart';
import '../../../todos/presentation/todos_providers.dart';

/// 전체 탭의 체크리스트 (F-04). **임시 디자인**.
/// 추가(제목 1~100자) · 체크(완료 시각 기록) · 삭제 · 완료율 · 빈 상태.
class ChecklistSection extends ConsumerStatefulWidget {
  const ChecklistSection({super.key});

  @override
  ConsumerState<ChecklistSection> createState() => _ChecklistSectionState();
}

class _ChecklistSectionState extends ConsumerState<ChecklistSection> {
  final _title = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final error = TodoValidator.validateTitle(_title.text);
    setState(() => _error = error);
    if (error != null) return;
    final now = ref.read(clockProvider)();
    await ref.read(todoActionsProvider).add(title: _title.text, now: now);
    _title.clear();
  }

  Future<void> _toggle(Todo todo) async {
    final now = ref.read(clockProvider)();
    try {
      await ref.read(todoActionsProvider).setDone(todo, !todo.done, now);
    } catch (error, stack) {
      ref.read(appErrorLogProvider).record(error, stack, where: 'toggle-todo');
      // 저장에 실패하면 화면은 바뀌지 않고(원래대로) 안내만 보여 준다.
      if (mounted) showAppToast(context, '저장하지 못했어요. 다시 시도해 주세요.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final todos = ref.watch(todosProvider).value ?? const <Todo>[];
    final done = todos.where((t) => t.done).length;
    final rate = todos.isEmpty ? 0 : (done * 100 / todos.length).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              '체크리스트',
              style: AppTextStyles.sectionTitle.copyWith(
                color: colors.textBlack,
              ),
            ),
            const Spacer(),
            Text(
              '$done/${todos.length} 완료 · $rate%',
              key: const Key('checklist-rate'),
              style: AppTextStyles.seeAll.copyWith(color: colors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                fieldKey: const Key('todo-title'),
                controller: _title,
                hint: '할 일을 적어 보세요.',
                errorText: _error,
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 72,
              child: CtaButton(label: '추가', height: 52, onPressed: _add),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (todos.isEmpty)
          const EmptyState(
            message: '체크리스트가 비어 있어요',
            hint: '해 보고 싶은 일을 적거나, 인사이트의 제안을 담아 보세요.',
          )
        else
          for (final todo in todos) ...[
            _TodoTile(
              todo: todo,
              onToggle: () => _toggle(todo),
              onDelete: () => ref.read(todoActionsProvider).delete(todo.id),
            ),
            const SizedBox(height: AppSpacing.actionCardGap),
          ],
      ],
    );
  }
}

class _TodoTile extends StatelessWidget {
  const _TodoTile({
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard.white(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          Semantics(
            button: true,
            checked: todo.done,
            label: '${todo.title} 완료 체크',
            excludeSemantics: true,
            onTap: onToggle,
            child: GestureDetector(
              key: Key('todo-check-${todo.id}'),
              behavior: HitTestBehavior.opaque,
              onTap: () {
                AppHaptics.selection();
                onToggle();
              },
              child: SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: todo.done ? colors.brand : Colors.transparent,
                      border: Border.all(
                        color: todo.done ? colors.brand : colors.cardBorder,
                        width: 2,
                      ),
                    ),
                    child: todo.done
                        ? Padding(
                            padding: const EdgeInsets.all(4),
                            child: SvgPicture.asset(
                              AppAssets.check,
                              colorFilter: ColorFilter.mode(
                                colors.onCta,
                                BlendMode.srcIn,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              todo.title,
              style: AppTextStyles.body.copyWith(
                color: todo.done ? colors.textSecondary : colors.textBlack,
                decoration: todo.done ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          Semantics(
            button: true,
            label: '삭제',
            excludeSemantics: true,
            onTap: onDelete,
            child: GestureDetector(
              key: Key('todo-delete-${todo.id}'),
              behavior: HitTestBehavior.opaque,
              onTap: onDelete,
              child: SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: SvgPicture.asset(
                    AppAssets.trash,
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      colors.textSecondary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
