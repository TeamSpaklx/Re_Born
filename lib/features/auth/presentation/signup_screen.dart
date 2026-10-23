import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/bottom_cta_bar.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../../shared/widgets/step_progress_bar.dart';
import '../models/auth_validator.dart';
import 'auth_providers.dart';
import 'password_field.dart';

/// 가입 1/4: 이메일·닉네임·비밀번호. 검증을 통과해야 다음 단계(동의)로 간다(F-01, T-02).
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  late final TextEditingController _email;
  late final TextEditingController _nickname;
  late final TextEditingController _password;
  final _confirm = TextEditingController();
  String? _emailError;
  String? _nicknameError;
  String? _passwordError;
  String? _confirmError;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(signupDraftProvider);
    _email = TextEditingController(text: draft.email);
    _nickname = TextEditingController(text: draft.nickname);
    _password = TextEditingController(text: draft.password);
  }

  @override
  void dispose() {
    _email.dispose();
    _nickname.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _next() {
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
    ref
        .read(signupDraftProvider.notifier)
        .update(
          (d) => d.copyWith(
            email: _email.text.trim(),
            nickname: _nickname.text.trim(),
            password: _password.text,
          ),
        );
    context.push(AppRoutes.signupConsent);
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
      progress: const StepProgressBar(current: 1, total: 4),
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
              hint: '8자 이상',
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
              onSubmitted: (_) => _next(),
            ),
          ],
        ),
      ),
      bottom: BottomCtaBar(label: '다음', onPressed: _next),
    );
  }
}
