import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/errors/app_error_log.dart';
import '../../../shared/widgets/app_text_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/bottom_cta_bar.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../models/auth_user.dart';
import '../models/auth_validator.dart';
import 'auth_providers.dart';
import 'password_field.dart';

/// 로그인 (F-01). 이메일 + 비밀번호. 실패하면 문구를 보여 주고 다시 시도할 수 있다.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _emailError;
  String? _passwordError;
  String? _formError;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _emailError = AuthValidator.validateEmail(_email.text);
      _passwordError = _password.text.isEmpty ? '비밀번호를 입력해 주세요.' : null;
      _formError = null;
    });
    if (_emailError != null || _passwordError != null) return;

    setState(() => _busy = true);
    final router = GoRouter.of(context);
    try {
      await ref.read(authActionsProvider).signIn(_email.text, _password.text);
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _formError = failure.message;
      });
      return;
    } catch (error, stack) {
      ref.read(appErrorLogProvider).record(error, stack, where: 'sign-in');
      if (!mounted) return;
      setState(() {
        _busy = false;
        _formError = const AuthFailure(AuthFailureType.unknown).message;
      });
      return;
    }
    if (!mounted) return;
    router.go(AppRoutes.today);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PageScaffold(
      title: '다시 만나서\n반가워요',
      subtitle: '이메일로 로그인해 주세요.',
      largeTitle: true,
      showBack: false,
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
            AppTextField(
              fieldKey: const Key('login-email'),
              controller: _email,
              label: '이메일',
              hint: 'example@email.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              errorText: _emailError,
              onChanged: (_) {
                if (_emailError != null) setState(() => _emailError = null);
              },
            ),
            const SizedBox(height: AppSpacing.space20),
            PasswordField(
              fieldKey: const Key('login-password'),
              controller: _password,
              label: '비밀번호',
              hint: '비밀번호',
              textInputAction: TextInputAction.done,
              errorText: _passwordError,
              onChanged: (_) {
                if (_passwordError != null) {
                  setState(() => _passwordError = null);
                }
              },
              onSubmitted: (_) => _busy ? null : _submit(),
            ),
            if (_formError != null) ...[
              const SizedBox(height: AppSpacing.space12),
              Semantics(
                liveRegion: true,
                child: Text(
                  _formError!,
                  key: const Key('login-error'),
                  style: AppTextStyles.body.copyWith(color: colors.danger),
                ),
              ),
            ],
          ],
        ),
      ),
      bottom: BottomCtaBar(
        label: _busy ? '로그인 중…' : '로그인',
        onPressed: _busy ? null : _submit,
        secondary: AppTextButton(
          label: '처음이에요 · 회원가입',
          color: colors.textSecondary,
          onTap: () => context.push(AppRoutes.signup),
        ),
      ),
    );
  }
}
