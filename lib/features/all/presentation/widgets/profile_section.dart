import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/cta_button.dart';
import '../../../../shared/widgets/profile_row.dart';
import '../../../../shared/widgets/summary_card.dart';
import '../../../auth/models/auth_validator.dart';
import '../../../auth/presentation/auth_providers.dart';
import '../../../entries/presentation/entries_providers.dart';
import '../../../people/presentation/people_providers.dart';
import '../../../settings/presentation/settings_providers.dart';
import '../../../todos/presentation/todos_providers.dart';

/// 전체 탭 맨 위: 프로필 행(닉네임·이메일, 누르면 닉네임 변경)과 요약 카드(기록·인물·체크리스트 완료).
class ProfileSection extends ConsumerWidget {
  const ProfileSection({super.key});

  Future<void> _editNickname(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final saved = await showAppBottomSheet<String>(
      context,
      title: '닉네임 변경',
      message: '홈 화면 인사에 쓰여요.',
      builder: (context) => _NicknameForm(initial: current),
    );
    if (saved == null || !context.mounted) return;
    await ref.read(settingsActionsProvider).saveNickname(saved);
    if (context.mounted) showAppToast(context, '닉네임을 바꿨어요');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nickname = ref.watch(settingsProvider).value?.nickname ?? '';
    final email = ref.watch(sessionProvider)?.email;
    final entries = ref.watch(entriesProvider).value?.length ?? 0;
    final people = ref.watch(peopleProvider).value?.length ?? 0;
    final todos = ref.watch(todosProvider).value ?? const [];
    final done = todos.where((t) => t.done).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard.white(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
          child: ProfileRow(
            title: nickname.isEmpty ? '닉네임을 정해 주세요' : nickname,
            subtitle: email,
            onTap: () => _editNickname(context, ref, nickname),
          ),
        ),
        const SizedBox(height: AppSpacing.space12),
        SummaryCard(
          items: [
            SummaryItem(value: '$entries', label: '기록'),
            SummaryItem(value: '$people', label: '인물'),
            SummaryItem(value: '$done/${todos.length}', label: '체크 완료'),
          ],
        ),
      ],
    );
  }
}

class _NicknameForm extends StatefulWidget {
  const _NicknameForm({required this.initial});

  final String initial;

  @override
  State<_NicknameForm> createState() => _NicknameFormState();
}

class _NicknameFormState extends State<_NicknameForm> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final error = AuthValidator.validateNickname(_controller.text);
    setState(() => _error = error);
    if (error == null) Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          fieldKey: const Key('nickname-field'),
          controller: _controller,
          hint: '닉네임',
          autofocus: true,
          errorText: _error,
          helperText: '${AuthValidator.maxNicknameLength}자 이내',
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: AppSpacing.space16),
        CtaButton(label: '저장', height: 52, onPressed: _submit),
        const SizedBox(height: AppSpacing.space8),
        Text(
          '언제든 다시 바꿀 수 있어요.',
          textAlign: TextAlign.center,
          style: AppTextStyles.caption.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}
