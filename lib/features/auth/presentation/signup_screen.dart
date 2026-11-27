import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/errors/app_error_log.dart';
import '../../../shared/widgets/app_dialogs.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/bottom_cta_bar.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../models/auth_user.dart';
import '../models/auth_validator.dart';
import 'auth_providers.dart';
import 'legal_notice.dart';
import 'login_screen.dart';
import 'password_field.dart';

/// 이메일 회원가입 (F-01, T-02): 이메일·닉네임·비밀번호·비밀번호 확인을 한 화면에서 받는다.
/// 검증을 통과하면 가입 → 바로 로그인 상태로 투데이에 간다. 동의는 아래 약관 안내로 받는다.
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _email = TextEditingController();
  final _nickname = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String? _emailError;
  String? _nicknameError;
  String? _passwordError;
  String? _confirmError;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _nickname.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() {
      _emailError = AuthValidator.validateEmail(_email.text);
      _nicknameError = AuthValidator.validateNickname(_nickname.text);
      _passwordError = AuthValidator.validatePassword(_password.text);
      _confirmError = AuthValidator.validatePasswordConfirm(
        _password.text,
        _confirm.text,
      );
    });
    if (_emailError != null ||
        _nicknameError != null ||
        _passwordError != null ||
        _confirmError != null) {
      return;
    }

    FocusScope.of(context).unfocus();
    final router = GoRouter.of(context);
    setState(() => _busy = true);
    try {
      await ref
          .read(authActionsProvider)
          .signUp(
            email: _email.text.trim(),
            password: _password.text,
            nickname: _nickname.text,
          );
      if (!mounted) return;
      goHomeAfterAuth(router, ref);
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      if (failure.type == AuthFailureType.emailTaken) {
        setState(() => _emailError = failure.message);
      } else {
        showAppToast(context, failure.message);
      }
    } catch (error, stack) {
      ref.read(appErrorLogProvider).record(error, stack, where: 'signup');
      if (mounted) {
        showAppToast(
          context,
          const AuthFailure(AuthFailureType.unknown).message,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    void clear(String? current, VoidCallback reset) {
      if (current != null) setState(reset);
    }

    return PageScaffold(
      title: '리본에 오신 걸\n환영해요',
      subtitle: '계정 정보를 입력해 주세요.',
      largeTitle: true,
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageMargin,
          AppSpacing.space8,
          AppSpacing.pageMargin,
          AppSpacing.space24,
        ),
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                fieldKey: const Key('signup-email'),
                controller: _email,
                label: '이메일',
                hint: 'example@email.com',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                errorText: _emailError,
                onChanged: (_) => clear(_emailError, () => _emailError = null),
              ),
              const SizedBox(height: AppSpacing.space20),
              AppTextField(
                fieldKey: const Key('signup-nickname'),
                controller: _nickname,
                label: '닉네임',
                hint: '리본에서 부를 이름',
                helperText:
                    '${AuthValidator.maxNicknameLength}자 이내, 홈 화면 인사에 쓰여요.',
                textInputAction: TextInputAction.next,
                errorText: _nicknameError,
                onChanged: (_) =>
                    clear(_nicknameError, () => _nicknameError = null),
              ),
              const SizedBox(height: AppSpacing.space20),
              PasswordField(
                fieldKey: const Key('signup-password'),
                controller: _password,
                label: '비밀번호',
                hint: '${AuthValidator.minPasswordLength}자 이상',
                textInputAction: TextInputAction.next,
                errorText: _passwordError,
                onChanged: (_) =>
                    clear(_passwordError, () => _passwordError = null),
              ),
              const SizedBox(height: AppSpacing.space20),
              PasswordField(
                fieldKey: const Key('signup-confirm'),
                controller: _confirm,
                label: '비밀번호 확인',
                hint: '한 번 더 입력',
                textInputAction: TextInputAction.done,
                errorText: _confirmError,
                onChanged: (_) =>
                    clear(_confirmError, () => _confirmError = null),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.space32),
              const LegalNotice(key: Key('signup-legal'), action: '가입은'),
            ],
          ),
        ),
      ),
      bottom: BottomCtaBar(
        key: const Key('signup-submit'),
        label: _busy ? '가입 중…' : '가입하기',
        onPressed: _busy ? null : _submit,
      ),
    );
  }
}
