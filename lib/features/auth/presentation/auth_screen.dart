import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_assets.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/cta_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = true;
  bool _consentPrivacy = false;
  bool _consentAiAnalysis = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
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

    setState(() => _error = null);
    context.go(AppRoutes.today);
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
                        ? '화면을 미리 둘러보세요. 계정은 만들어지지 않아요.'
                        : '화면을 미리 둘러보세요. 로그인 정보는 저장되지 않아요.',
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
                  const SizedBox(height: AppSpacing.recordCardPadding),
                  CtaButton(
                    label: _isSignUp ? '회원가입' : '로그인',
                    onPressed: _submit,
                    height: HomeLayout.ctaButtonHeightAfter,
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      _isSignUp = !_isSignUp;
                      _error = null;
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
