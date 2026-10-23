import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_assets.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/errors/app_error_log.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../shared/widgets/app_dialogs.dart';
import '../../../shared/widgets/pressable.dart';
import '../models/auth_user.dart';
import 'auth_providers.dart';

/// 소셜 로그인을 처리한다: 처음 온 사용자는 약관 동의(→ 온보딩)로, 기존 사용자는 홈으로 보낸다.
/// 실패하면 안내 토스트를 보여 준다.
Future<void> handleSocialSignIn(
  BuildContext context,
  WidgetRef ref,
  SocialProvider provider,
) async {
  final router = GoRouter.of(context);
  try {
    final isNew = await ref
        .read(authActionsProvider)
        .signInWithSocial(provider);
    router.go(isNew ? AppRoutes.signupConsent : AppRoutes.today);
  } on AuthFailure catch (failure) {
    if (context.mounted) showAppToast(context, failure.message);
  } catch (error, stack) {
    ref.read(appErrorLogProvider).record(error, stack, where: 'social-login');
    if (context.mounted) {
      showAppToast(context, const AuthFailure(AuthFailureType.unknown).message);
    }
  }
}

/// 구글·카카오 로그인 버튼 두 개. [dividerLabel]이 있으면 위나 아래에 "또는 …" 구분선을 둔다.
class SocialLoginButtons extends ConsumerWidget {
  const SocialLoginButtons({
    super.key,
    required this.dividerLabel,
    this.dividerOnTop = false,
  });

  final String dividerLabel;
  final bool dividerOnTop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final divider = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space20),
      child: Row(
        children: [
          Expanded(
            child: ColoredBox(
              color: colors.chip,
              child: const SizedBox(height: 1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space12),
            child: Text(
              dividerLabel,
              style: AppTextStyles.body.copyWith(color: colors.textSecondary),
            ),
          ),
          Expanded(
            child: ColoredBox(
              color: colors.chip,
              child: const SizedBox(height: 1),
            ),
          ),
        ],
      ),
    );
    final buttons = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SocialButton(
          key: const Key('social-kakao'),
          label: '카카오로 계속하기',
          iconAsset: AppAssets.kakaoBubble,
          background: colors.kakaoYellow,
          foreground: colors.onKakao,
          onTap: () => handleSocialSignIn(context, ref, SocialProvider.kakao),
        ),
        const SizedBox(height: AppSpacing.space12),
        _SocialButton(
          key: const Key('social-google'),
          label: 'Google로 계속하기',
          iconAsset: AppAssets.googleG,
          background: colors.cardWhite,
          foreground: colors.textBlack,
          borderColor: colors.cardBorder,
          onTap: () => handleSocialSignIn(context, ref, SocialProvider.google),
        ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: dividerOnTop ? [divider, buttons] : [buttons, divider],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    super.key,
    required this.label,
    required this.iconAsset,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.borderColor,
  });

  final String label;
  final String iconAsset;
  final Color background;
  final Color foreground;
  final Color? borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    void press() {
      AppHaptics.tap();
      onTap();
    }

    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: press,
      child: Pressable(
        onTap: press,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppRadii.button),
            border: borderColor == null
                ? null
                : Border.all(color: borderColor!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(iconAsset, width: 20, height: 20),
              const SizedBox(width: AppSpacing.space8),
              Text(
                label,
                style: AppTextStyles.buttonLarge.copyWith(color: foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
