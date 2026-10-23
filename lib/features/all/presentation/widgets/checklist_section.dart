import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_assets.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_motion.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/errors/app_error_log.dart';
import '../../../../core/providers/clock_provider.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/check_row.dart';
import '../../../../shared/widgets/cta_button.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/list_section_header.dart';
import '../../../../shared/widgets/swipe_to_delete.dart';
import '../../../todos/models/todo.dart';
import '../../../todos/presentation/todos_providers.dart';

/// 전체 탭의 체크리스트 (F-04): 완료율 막대, 추가 입력줄, "해야 할 일 / 완료" 두 묶음.
/// 체크하면 핑크 원이 차오르고(완료 시각 기록), 밀거나 휴지통을 누르면 지워진다.
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

  Widget _tile(Todo todo) {
    final colors = context.colors;
    void delete() => ref.read(todoActionsProvider).delete(todo.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space8),
      child: SwipeToDelete(
        dismissKey: Key('todo-${todo.id}'),
        onDelete: delete,
        child: Container(
          padding: const EdgeInsets.only(left: AppSpacing.space16),
          decoration: BoxDecoration(
            color: colors.cardWhite,
            borderRadius: BorderRadius.circular(AppRadii.card - 8),
          ),
          child: KeyedSubtree(
            key: Key('todo-check-${todo.id}'),
            child: CheckRow(
              title: todo.title,
              checked: todo.done,
              onChanged: (_) => _toggle(todo),
              trailing: Semantics(
                button: true,
                label: '${todo.title} 삭제',
                excludeSemantics: true,
                onTap: delete,
                child: GestureDetector(
                  key: Key('todo-delete-${todo.id}'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    AppHaptics.tap();
                    delete();
                  },
                  child: SizedBox(
                    width: 48,
                    height: 48,
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
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final todos = ref.watch(todosProvider).value ?? const <Todo>[];
    final open = todos.where((t) => !t.done).toList();
    final doneList = todos.where((t) => t.done).toList();
    final rate = todos.isEmpty
        ? 0
        : (doneList.length * 100 / todos.length).round();

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
              '${doneList.length}/${todos.length} 완료 · $rate%',
              key: const Key('checklist-rate'),
              style: AppTextStyles.seeAll.copyWith(color: colors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 6,
            child: Stack(
              children: [
                Positioned.fill(child: ColoredBox(color: colors.chip)),
                AnimatedFractionallySizedBox(
                  duration: AppMotion.normal,
                  curve: AppMotion.move,
                  alignment: Alignment.centerLeft,
                  heightFactor: 1,
                  widthFactor: rate / 100,
                  child: ColoredBox(color: colors.brand),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.space16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                fieldKey: const Key('todo-title'),
                controller: _title,
                hint: '할 일을 적어 보세요.',
                errorText: _error,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _add(),
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
              ),
            ),
            const SizedBox(width: AppSpacing.space8),
            SizedBox(
              width: 72,
              child: CtaButton(label: '추가', height: 52, onPressed: _add),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space8),
        if (todos.isEmpty)
          const AppCard.white(
            padding: EdgeInsets.zero,
            child: EmptyState(
              message: '체크리스트가 비어 있어요',
              hint: '해 보고 싶은 일을 적거나, 인사이트의 제안을 담아 보세요.',
            ),
          )
        else ...[
          for (final todo in open) _tile(todo),
          if (doneList.isNotEmpty) ...[
            ListSectionHeader(title: '완료 ${doneList.length}'),
            for (final todo in doneList) _tile(todo),
          ],
        ],
      ],
    );
  }
}
