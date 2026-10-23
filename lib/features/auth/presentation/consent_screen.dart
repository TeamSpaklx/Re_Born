import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/errors/app_error_log.dart';
import '../../../shared/widgets/app_bottom_sheet.dart';
import '../../../shared/widgets/app_dialogs.dart';
import '../../../shared/widgets/bottom_cta_bar.dart';
import '../../../shared/widgets/consent_row.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../../shared/widgets/step_progress_bar.dart';
import '../../settings/models/app_settings.dart';
import '../models/auth_user.dart';
import 'auth_providers.dart';
import 'consent_texts.dart';

/// 가입 2/4: 약관 동의. 필수(개인정보·감정 분석)에 동의해야 가입된다(F-01, T-03).
class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({super.key});

  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen> {
  Consents _consents = const Consents(
    privacy: false,
    aiAnalysis: false,
    analytics: false,
  );
  bool _showError = false;
  bool _busy = false;

  bool get _all =>
      _consents.privacy && _consents.aiAnalysis && _consents.analytics;
  bool get _requiredOk => _consents.privacy && _consents.aiAnalysis;

  void _set(Consents value) => setState(() {
    _consents = value;
    if (_requiredOk) _showError = false;
  });

  Future<void> _view(String title, String body) {
    final colors = context.colors;
    return showAppBottomSheet<void>(
      context,
      title: title,
      builder: (context) => Text(
        body,
        style: AppTextStyles.body.copyWith(
          color: colors.textSecondary,
          height: 1.6,
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_requiredOk) {
      setState(() => _showError = true);
      return;
    }
    setState(() => _busy = true);
    final router = GoRouter.of(context);
    try {
      await ref
          .read(authActionsProvider)
          .signUp(ref.read(signupDraftProvider).copyWith(consents: _consents));
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      setState(() => _busy = false);
      showAppToast(context, failure.message);
      if (failure.type == AuthFailureType.emailTaken) router.pop();
      return;
    } catch (error, stack) {
      ref.read(appErrorLogProvider).record(error, stack, where: 'sign-up');
      if (!mounted) return;
      setState(() => _busy = false);
      showAppToast(context, const AuthFailure(AuthFailureType.unknown).message);
      return;
    }
    if (!mounted) return;
    router.go(AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PageScaffold(
      title: '약관에\n동의해 주세요',
      subtitle: '내 기록은 나만 볼 수 있어요.',
      largeTitle: true,
      progress: const StepProgressBar(current: 2, total: 4),
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
            ConsentRow(
              key: const Key('consent-all'),
              label: '전체 동의',
              emphasized: true,
              checked: _all,
              onChanged: (v) =>
                  _set(Consents(privacy: v, aiAnalysis: v, analytics: v)),
            ),
            const SizedBox(height: AppSpacing.space12),
            ConsentRow(
              key: const Key('consent-privacy-row'),
              tag: '필수',
              label: ConsentTexts.privacyTitle,
              checked: _consents.privacy,
              onChanged: (v) => _set(_consents.copyWith(privacy: v)),
              onView: () =>
                  _view(ConsentTexts.privacyTitle, ConsentTexts.privacy),
            ),
            ConsentRow(
              key: const Key('consent-ai-row'),
              tag: '필수',
              label: ConsentTexts.aiTitle,
              checked: _consents.aiAnalysis,
              onChanged: (v) => _set(_consents.copyWith(aiAnalysis: v)),
              onView: () => _view(ConsentTexts.aiTitle, ConsentTexts.ai),
            ),
            ConsentRow(
              key: const Key('consent-analytics-row'),
              tag: '선택',
              label: ConsentTexts.analyticsTitle,
              checked: _consents.analytics,
              onChanged: (v) => _set(_consents.copyWith(analytics: v)),
              onView: () =>
                  _view(ConsentTexts.analyticsTitle, ConsentTexts.analytics),
            ),
            if (_showError) ...[
              const SizedBox(height: AppSpacing.space12),
              Semantics(
                liveRegion: true,
                child: Text(
                  '필수 항목에 동의해야 가입할 수 있어요.',
                  key: const Key('consent-error'),
                  style: AppTextStyles.body.copyWith(color: colors.danger),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.space24),
            Text(
              '동의는 언제든 설정에서 바꿀 수 있어요. 선택 항목에 동의하지 않아도 앱을 쓸 수 있어요.',
              style: AppTextStyles.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      bottom: BottomCtaBar(
        label: _busy ? '가입 중…' : '동의하고 가입하기',
        onPressed: _busy ? null : _submit,
      ),
    );
  }
}
