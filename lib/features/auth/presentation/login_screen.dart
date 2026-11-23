import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/data_providers.dart';
import '../../../app/theme/app_assets.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/widgets/app_bottom_sheet.dart';
import '../../../shared/widgets/app_toggle.dart';
import '../../../shared/widgets/pressable.dart';
import '../../../shared/widgets/select_card.dart';
import '../data/in_memory_auth_repository.dart';
import 'consent_texts.dart';
import 'social_login_buttons.dart';

/// 로그인 (F-01, Figma 8877:1929): 흰 배경 가운데 RE:BORN 워드마크, 아래에 구글·카카오 버튼과 약관 안내.
/// 로그인하면 신규·기존 회원 모두 바로 투데이로 간다([handleSocialSignIn]).
///
/// 디버그 빌드에서는 워드마크를 길게 누르면 다음 로그인 결과(취소·오류·지연)를 고르는 패널이 뜬다.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final logo = Image.asset(
      AppAssets.logo,
      width: LoginLayout.logoWidth,
      height: LoginLayout.logoHeight,
      semanticLabel: 'Re:Born',
    );
    // Scaffold 없이 그리므로 기본 글자 스타일을 직접 준다(없으면 글자에 노란 밑줄이 생긴다).
    return DefaultTextStyle(
      style: AppTextStyles.loginLegal.copyWith(color: colors.loginLegalText),
      child: ColoredBox(
        color: colors.splashBackground,
        child: Stack(
          children: [
            Align(
              alignment: LoginLayout.logoAlignment,
              child: kDebugMode
                  ? GestureDetector(
                      key: const Key('login-debug-trigger'),
                      onLongPress: () => _showDebugPanel(context, ref),
                      child: logo,
                    )
                  : logo,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    LoginLayout.horizontalMargin,
                    0,
                    LoginLayout.horizontalMargin,
                    LoginLayout.legalBottom,
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SocialLoginButtonPair(),
                      SizedBox(height: LoginLayout.buttonsToLegal),
                      _LegalNotice(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 디버그 전용: 백엔드가 없어 항상 성공하는 로그인을 원하는 결과로 바꿔 본다.
  void _showDebugPanel(BuildContext context, WidgetRef ref) {
    final repo = ref.read(authRepositoryProvider);
    if (repo is! InMemoryAuthRepository) return;
    showAppBottomSheet<void>(
      context,
      title: '다음 로그인 결과 (디버그)',
      message: '출시 빌드에는 없는 테스트용 패널이에요.',
      builder: (context) => _DebugAuthPanel(repo: repo),
    );
  }
}

/// "로그인은 개인정보 보호 정책 및 서비스 약관에 동의하는 것으로 간주됩니다."
/// Figma 메모대로 두 문서를 각각 열 수 있는 링크로 나눴다(밑줄은 추정 스타일).
/// 링크는 글자 인식기 대신 문장 안에 넣은 작은 탭 위젯이라, 탭과 스크린 리더 "링크"가 확실히 잡힌다.
class _LegalNotice extends StatelessWidget {
  const _LegalNotice();

  void _open(BuildContext context, String title, String body) {
    final colors = context.colors;
    showAppBottomSheet<void>(
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

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.loginLegal.copyWith(
      color: context.colors.loginLegalText,
    );
    InlineSpan link(String label, String title, String body) => WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: Semantics(
        link: true,
        label: label,
        excludeSemantics: true,
        onTap: () => _open(context, title, body),
        child: Pressable(
          key: Key('login-legal-$title'),
          onTap: () => _open(context, title, body),
          child: Text(
            label,
            style: style.copyWith(decoration: TextDecoration.underline),
          ),
        ),
      ),
    );
    return Text.rich(
      key: const Key('login-legal'),
      TextSpan(
        style: style,
        children: [
          const TextSpan(text: '로그인은 '),
          link('개인정보 보호 정책', ConsentTexts.privacyTitle, ConsentTexts.privacy),
          const TextSpan(text: ' 및 '),
          link('서비스 약관', ConsentTexts.termsTitle, ConsentTexts.terms),
          const TextSpan(text: '에\n동의하는 것으로 간주됩니다.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _DebugAuthPanel extends StatefulWidget {
  const _DebugAuthPanel({required this.repo});

  final InMemoryAuthRepository repo;

  @override
  State<_DebugAuthPanel> createState() => _DebugAuthPanelState();
}

class _DebugAuthPanelState extends State<_DebugAuthPanel> {
  static const _delay = Duration(seconds: 2);

  @override
  Widget build(BuildContext context) {
    final repo = widget.repo;
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final outcome in SocialOutcome.values) ...[
          SelectCard(
            key: Key('debug-outcome-${outcome.name}'),
            title: outcome.label,
            selected: repo.nextOutcome == outcome,
            onTap: () => setState(() => repo.nextOutcome = outcome),
          ),
          const SizedBox(height: AppSpacing.space8),
        ],
        const SizedBox(height: AppSpacing.space8),
        Row(
          children: [
            Expanded(
              child: Text(
                '2초 지연(로딩 확인)',
                style: AppTextStyles.rowTitle.copyWith(color: colors.textBlack),
              ),
            ),
            AppToggle(
              key: const Key('debug-latency'),
              value: repo.latency > Duration.zero,
              onChanged: (on) =>
                  setState(() => repo.latency = on ? _delay : Duration.zero),
            ),
          ],
        ),
      ],
    );
  }
}
