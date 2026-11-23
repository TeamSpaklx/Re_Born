import 'package:flutter/cupertino.dart';
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

/// 소셜 로그인을 처리한다: 성공하면 신규·기존 회원 모두 바로 투데이로 보낸다.
///
/// - 사용자가 로그인 창을 닫으면(취소) 아무 안내 없이 그대로 둔다.
/// - 네트워크·알 수 없는 오류는 토스트로 알리고, 알 수 없는 오류는 오류 기록에 남긴다.
/// 진행 중 연타 막기는 부르는 화면이 맡는다(버튼을 끄고 로딩 표시).
Future<void> handleSocialSignIn(
  BuildContext context,
  WidgetRef ref,
  SocialProvider provider,
) async {
  final router = GoRouter.of(context);
  try {
    await ref.read(authActionsProvider).signInWithSocial(provider);
    router.go(AppRoutes.today);
  } on AuthFailure catch (failure) {
    if (failure.type == AuthFailureType.cancelled) return;
    if (context.mounted) showAppToast(context, failure.message);
  } catch (error, stack) {
    ref.read(appErrorLogProvider).record(error, stack, where: 'social-login');
    if (context.mounted) {
      showAppToast(context, const AuthFailure(AuthFailureType.unknown).message);
    }
  }
}

/// 구글·카카오 버튼 한 쌍(구글 위, 카카오 아래, Figma 8877:1931).
/// 하나를 누르면 끝날 때까지 두 버튼 모두 막고, 누른 버튼에 로딩 표시를 한다.
class SocialLoginButtonPair extends ConsumerStatefulWidget {
  const SocialLoginButtonPair({super.key});

  @override
  ConsumerState<SocialLoginButtonPair> createState() =>
      _SocialLoginButtonPairState();
}

class _SocialLoginButtonPairState extends ConsumerState<SocialLoginButtonPair> {
  SocialProvider? _busy;

  Future<void> _signIn(SocialProvider provider) async {
    if (_busy != null) return;
    setState(() => _busy = provider);
    try {
      await handleSocialSignIn(context, ref, provider);
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final idle = _busy == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SocialLoginButton(
          key: const Key('social-google'),
          label: '구글로 로그인',
          iconAsset: AppAssets.googleG,
          background: colors.cardWhite,
          foreground: colors.textBlack,
          borderColor: colors.socialBorder,
          loading: _busy == SocialProvider.google,
          onTap: idle ? () => _signIn(SocialProvider.google) : null,
        ),
        const SizedBox(height: LoginLayout.buttonGap),
        SocialLoginButton(
          key: const Key('social-kakao'),
          label: '카카오로 로그인',
          iconAsset: AppAssets.kakaoBubble,
          background: colors.kakaoYellow,
          foreground: colors.textBlack,
          loading: _busy == SocialProvider.kakao,
          onTap: idle ? () => _signIn(SocialProvider.kakao) : null,
        ),
      ],
    );
  }
}

/// 소셜 로그인 버튼 하나(Figma 8877:1932): 높이 55 알약, 아이콘 24 + 간격 16 + 14 SemiBold.
/// [onTap]이 null이면 눌리지 않는다. [loading]이면 아이콘·글자 자리에 로딩 표시를 한다.
class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    required this.label,
    required this.iconAsset,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.borderColor,
    this.loading = false,
  });

  final String label;
  final String iconAsset;
  final Color background;
  final Color foreground;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final tap = onTap;
    void press() {
      AppHaptics.tap();
      tap?.call();
    }

    return Semantics(
      button: true,
      enabled: tap != null,
      label: loading ? '$label, 로그인 중' : label,
      excludeSemantics: true,
      onTap: tap == null ? null : press,
      child: Pressable(
        onTap: tap == null ? null : press,
        child: Container(
          height: LoginLayout.buttonHeight,
          decoration: BoxDecoration(
            color: background,
            borderRadius: AppRadii.pillBorderRadius,
            border: borderColor == null
                ? null
                : Border.all(color: borderColor!),
          ),
          alignment: Alignment.center,
          child: loading
              ? CupertinoActivityIndicator(color: foreground)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox.square(
                      dimension: LoginLayout.iconSize,
                      child: Center(child: SvgPicture.asset(iconAsset)),
                    ),
                    const SizedBox(width: LoginLayout.iconGap),
                    Text(
                      label,
                      style: AppTextStyles.socialButton.copyWith(
                        color: foreground,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
