import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/data_providers.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_assets.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/network/backend_api_client.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/cta_button.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = true;
  bool _busy = false;
  bool _consentPrivacy = false;
  bool _consentAiAnalysis = false;
  String? _error;
  String? _message;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      setState(() => _error = '이메일 주소를 확인해 주세요.');
      return;
    }
    if (password.length < 8) {
      setState(() => _error = '비밀번호는 8자 이상 입력해 주세요.');
      return;
    }
    if (_isSignUp && (!_consentPrivacy || !_consentAiAnalysis)) {
      setState(() => _error = '가입에 필요한 동의 항목을 확인해 주세요.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
      _message = null;
    });

    try {
      final auth = ref.read(authServiceProvider);
      if (_isSignUp) {
        final hasSession = await auth.signUp(
          email: email,
          password: password,
          consentPrivacy: _consentPrivacy,
          consentAiAnalysis: _consentAiAnalysis,
        );
        if (!hasSession) {
          setState(() {
            _message = '인증 메일을 확인한 뒤 로그인해 주세요.';
            _isSignUp = false;
          });
          return;
        }
      } else {
        await auth.signIn(email: email, password: password);
      }
      if (mounted) context.go(AppRoutes.today);
    } on AuthException catch (exception) {
      setState(() => _error = exception.message);
    } on BackendApiException catch (exception) {
      setState(() => _error = '로그인은 됐지만 백엔드 연결에 실패했어요. ${exception.message}');
    } catch (_) {
      setState(() => _error = '연결에 실패했어요. 잠시 후 다시 시도해 주세요.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.pageMargin),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AuthLayout.maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Image.asset(
                      AppAssets.logoMark,
                      width: AuthLayout.logoSize,
                      height: AuthLayout.logoSize,
                      semanticLabel: 'Re:Born',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.recordCardPadding),
                  Text(
                    _isSignUp ? '리본을 시작해요' : '다시 만났어요',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.greeting.copyWith(
                      color: colors.textBlack,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.actionCardGap),
                  Text(
                    _isSignUp
                        ? '이메일로 계정을 만들고 마음을 기록해 보세요.'
                        : '이메일과 비밀번호로 로그인해 주세요.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.recordCardPadding),
                  Text(
                    '이메일',
                    style: AppTextStyles.button.copyWith(
                      color: colors.textBlack,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.actionCardGap),
                  AppTextField(
                    controller: _emailController,
                    hint: 'name@example.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppSpacing.actionCardGap),
                  Text(
                    '비밀번호',
                    style: AppTextStyles.button.copyWith(
                      color: colors.textBlack,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.actionCardGap),
                  AppTextField(
                    controller: _passwordController,
                    hint: '8자 이상 입력해 주세요',
                    obscureText: true,
                  ),
                  if (_isSignUp) ...[
                    const SizedBox(height: AppSpacing.actionCardGap),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _consentPrivacy,
                      activeColor: colors.brand,
                      onChanged: (value) =>
                          setState(() => _consentPrivacy = value ?? false),
                      title: Text(
                        '개인정보 수집·이용에 동의합니다 (필수)',
                        style: AppTextStyles.body.copyWith(
                          color: colors.textBlack,
                        ),
                      ),
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _consentAiAnalysis,
                      activeColor: colors.brand,
                      onChanged: (value) =>
                          setState(() => _consentAiAnalysis = value ?? false),
                      title: Text(
                        '앱 내 규칙 기반 감정 분석에 동의합니다 (필수)',
                        style: AppTextStyles.body.copyWith(
                          color: colors.textBlack,
                        ),
                      ),
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.actionCardGap),
                    Text(
                      _error!,
                      style: AppTextStyles.body.copyWith(color: colors.brand),
                    ),
                  ],
                  if (_message != null) ...[
                    const SizedBox(height: AppSpacing.actionCardGap),
                    Text(
                      _message!,
                      style: AppTextStyles.body.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.recordCardPadding),
                  CtaButton(
                    label: _busy
                        ? '잠시만요…'
                        : _isSignUp
                        ? '회원가입'
                        : '로그인',
                    onPressed: _busy ? () {} : _submit,
                    height: HomeLayout.ctaButtonHeightAfter,
                  ),
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => setState(() {
                            _isSignUp = !_isSignUp;
                            _error = null;
                            _message = null;
                          }),
                    child: Text(
                      _isSignUp ? '이미 계정이 있나요? 로그인' : '계정이 없나요? 회원가입',
                      style: AppTextStyles.body.copyWith(color: colors.brand),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
