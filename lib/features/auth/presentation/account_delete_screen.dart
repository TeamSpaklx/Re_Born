import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/errors/app_error_log.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_dialogs.dart';
import '../../../shared/widgets/bottom_cta_bar.dart';
import '../../../shared/widgets/consent_row.dart';
import '../../../shared/widgets/cta_button.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../models/auth_user.dart';
import 'auth_providers.dart';
import 'password_field.dart';

/// 계정 삭제 (F-11, T-31): 삭제되는 것 안내 → 확인 체크 → 비밀번호 재인증 → 확인 팝업 → 완료.
class AccountDeleteScreen extends ConsumerStatefulWidget {
  const AccountDeleteScreen({super.key});

  @override
  ConsumerState<AccountDeleteScreen> createState() =>
      _AccountDeleteScreenState();
}

class _AccountDeleteScreenState extends ConsumerState<AccountDeleteScreen> {
  final _password = TextEditingController();
  bool _confirmed = false;
  bool _busy = false;
  bool _done = false;
  String? _error;

  static const _items = [
    '남긴 모든 기록과 감정 분석 결과',
    '등록한 인물과 관계 지수 이력',
    '인사이트와 체크리스트',
    '이메일·닉네임 등 계정 정보',
  ];

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    if (_password.text.isEmpty) {
      setState(() => _error = '비밀번호를 입력해 주세요.');
      return;
    }
    final ok = await showAppConfirmDialog(
      context,
      title: '정말 삭제할까요?',
      message: '계정과 모든 데이터가 지워지고 되돌릴 수 없어요.',
      confirmLabel: '삭제',
      destructive: true,
    );
    if (!ok || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authActionsProvider).deleteAccount(_password.text);
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = failure.type == AuthFailureType.invalidCredentials
            ? '비밀번호가 맞지 않아요.'
            : failure.message;
      });
      return;
    } catch (error, stack) {
      ref
          .read(appErrorLogProvider)
          .record(error, stack, where: 'delete-account');
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = '삭제를 마치지 못했어요. 다시 시도해 주세요.';
      });
      return;
    }
    if (mounted) setState(() => _done = true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (_done) {
      return PageScaffold(
        title: '',
        showBack: false,
        body: Center(
          child: EmptyState(
            message: '계정을 삭제했어요',
            hint: '그동안 리본과 함께해 주셔서 고마워요.',
            showMascot: true,
            actionLabel: '처음으로',
            onAction: () => context.go(AppRoutes.login),
          ),
        ),
      );
    }

    return PageScaffold(
      title: '계정을\n삭제할까요?',
      subtitle: '삭제하면 되돌릴 수 없어요.',
      largeTitle: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageMargin,
          AppSpacing.space8,
          AppSpacing.pageMargin,
          AppSpacing.space24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppCard.white(
              padding: const EdgeInsets.all(AppSpacing.space20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '이런 정보가 모두 지워져요',
                    style: AppTextStyles.groupTitle.copyWith(
                      color: colors.textBlack,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space12),
                  for (final item in _items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.space8),
                      child: Text(
                        '• $item',
                        style: AppTextStyles.rowTitle.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space16),
            ConsentRow(
              key: const Key('delete-confirm'),
              label: '위 내용을 모두 확인했어요',
              checked: _confirmed,
              onChanged: (v) => setState(() => _confirmed = v),
            ),
            const SizedBox(height: AppSpacing.space16),
            PasswordField(
              fieldKey: const Key('delete-password'),
              controller: _password,
              label: '비밀번호 확인',
              hint: '본인 확인을 위해 비밀번호를 입력해 주세요',
              errorText: _error,
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
            ),
          ],
        ),
      ),
      bottom: BottomCtaBar(
        label: _busy ? '삭제 중…' : '계정 삭제',
        variant: CtaVariant.destructive,
        onPressed: (_confirmed && !_busy) ? _delete : null,
      ),
    );
  }
}
