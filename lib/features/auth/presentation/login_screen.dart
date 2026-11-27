import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_assets.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/errors/app_error_log.dart';
import '../../../shared/widgets/app_dialogs.dart';
import '../../../shared/widgets/app_text_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/cta_button.dart';
import '../../onboarding/data/intro_store.dart';
import '../models/auth_user.dart';
import '../models/auth_validator.dart';
import 'auth_providers.dart';
import 'password_field.dart';

/// 로그인·가입이 끝난 뒤 갈 곳: 설치 후 처음이면 "시작할 준비가 끝났어요" 화면을 한 번 거치고, 아니면 투데이.
void goHomeAfterAuth(GoRouter router, WidgetRef ref) {
  final startSeen = ref.read(introStoreProvider).startSeen;
  router.go(startSeen ? AppRoutes.today : AppRoutes.start);
}

/// 이메일 로그인 (F-01). 흰 배경 위쪽에 RE:BORN 워드마크, 아래에 이메일·비밀번호와 로그인 버튼,
/// "이메일로 회원가입" 링크, 약관 안내. Figma에 이메일 로그인 화면이 없어 공통 컴포넌트로 구성했다.
///
/// - 형식이 틀리면 입력창 아래에 바로 안내한다(서버에 보내지 않음).
/// - 이메일·비밀번호가 맞지 않으면 비밀번호 아래에, 네트워크·알 수 없는 오류는 토스트로 알린다.
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
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() {
      _emailError = AuthValidator.validateEmail(_email.text);
      _passwordError = _password.text.isEmpty ? '비밀번호를 입력해 주세요.' : null;
    });
    if (_emailError != null || _passwordError != null) return;

    FocusScope.of(context).unfocus();
    final router = GoRouter.of(context);
    setState(() => _busy = true);
    try {
      await ref
          .read(authActionsProvider)
          .signIn(_email.text.trim(), _password.text);
      if (!mounted) return;
      goHomeAfterAuth(router, ref);
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      if (failure.type == AuthFailureType.invalidCredentials) {
        setState(() => _passwordError = failure.message);
      } else {
        showAppToast(context, failure.message);
      }
    } catch (error, stack) {
      ref.read(appErrorLogProvider).record(error, stack, where: 'login');
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
    final colors = context.colors;
    void clear(String? current, VoidCallback reset) {
      if (current != null) setState(reset);
    }

    return Scaffold(
      backgroundColor: colors.splashBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(
              horizontal: LoginLayout.horizontalMargin,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    Center(
                      child: Image.asset(
                        AppAssets.logo,
                        width: LoginLayout.logoWidth,
                        height: LoginLayout.logoHeight,
                        semanticLabel: 'Re:Born',
                      ),
                    ),
                    const SizedBox(height: LoginLayout.logoToForm),
                    AutofillGroup(
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
                            onChanged: (_) =>
                                clear(_emailError, () => _emailError = null),
                          ),
                          const SizedBox(height: AppSpacing.space16),
                          PasswordField(
                            fieldKey: const Key('login-password'),
                            controller: _password,
                            label: '비밀번호',
                            hint: '비밀번호',
                            textInputAction: TextInputAction.done,
                            errorText: _passwordError,
                            onChanged: (_) => clear(
                              _passwordError,
                              () => _passwordError = null,
                            ),
                            onSubmitted: (_) => _submit(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space24),
                    CtaButton(
                      key: const Key('login-submit'),
                      label: _busy ? '로그인 중…' : '로그인',
                      height: LoginLayout.buttonHeight,
                      onPressed: _busy ? null : _submit,
                    ),
                    const SizedBox(height: AppSpacing.space8),
                    Center(
                      child: AppTextButton(
                        key: const Key('login-signup'),
                        label: '이메일로 회원가입',
                        color: colors.textSecondary,
                        onTap: () => context.push(AppRoutes.signup),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: AppSpacing.space24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
