import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_assets.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/widgets/cta_button.dart';
import '../data/intro_store.dart';

/// 인트로 온보딩 (Figma 8877:1945): 설치 후 처음 켰을 때 스플래시와 로그인 사이에 한 번만 보인다.
/// 위에는 앱 화면 목업, 아래에는 제목·설명·"시작하기". 누르면 본 것으로 기록하고 로그인으로 간다.
/// Figma의 A/B 시안(상단 진행 막대)은 실험안이라 만들지 않았다.
class IntroScreen extends ConsumerWidget {
  const IntroScreen({super.key});

  Future<void> _start(BuildContext context, WidgetRef ref) async {
    final router = GoRouter.of(context);
    // 저장이 실패해도 로그인으로는 보낸다(다음 실행에 인트로가 한 번 더 보일 뿐이다).
    try {
      await ref.read(introStoreProvider).markSeen();
    } catch (_) {}
    router.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.splashBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: IntroLayout.previewTopInset),
            // 작은 화면에서는 목업이 줄어들어 글자·버튼이 밀려 나가지 않게 한다.
            const Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.topCenter,
                child: _Preview(),
              ),
            ),
            const SizedBox(height: IntroLayout.previewToText),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageMargin,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: IntroLayout.titleTop),
                  Semantics(
                    header: true,
                    child: Text(
                      '이제, 인간관계를 기록할 수 있어요',
                      style: AppTextStyles.introTitle.copyWith(
                        color: colors.textBlack,
                      ),
                    ),
                  ),
                  const SizedBox(height: IntroLayout.titleToBody),
                  Text(
                    '오늘 만난 사람과의 일, 1분만 남겨보세요.\n적으면 관계의 흐름이 보여요.',
                    style: AppTextStyles.introBody.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: IntroLayout.bodyToCta),
                  CtaButton(
                    key: const Key('intro-start'),
                    label: '시작하기',
                    height: IntroLayout.ctaHeight,
                    onPressed: () => _start(context, ref),
                  ),
                ],
              ),
            ),
            const SizedBox(height: IntroLayout.ctaBottom),
          ],
        ),
      ),
    );
  }
}

/// 앱 화면 목업 314×490. 이미지는 Figma 상자 안에서 아래쪽이 잘려 있고, 맨 아래는 흰색으로 사라진다.
class _Preview extends StatelessWidget {
  const _Preview();

  @override
  Widget build(BuildContext context) {
    final fade = context.colors.splashBackground;
    return SizedBox(
      width: IntroLayout.previewWidth,
      height: IntroLayout.previewHeight,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            left: 0,
            top: IntroLayout.previewHeight * IntroLayout.previewImageTopFactor,
            width: IntroLayout.previewWidth,
            height:
                IntroLayout.previewHeight *
                IntroLayout.previewImageHeightFactor,
            child: Image.asset(
              AppAssets.introPreview,
              fit: BoxFit.fill,
              semanticLabel: 'Re:Born 홈 화면 미리보기',
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: IntroLayout.previewFade,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  // Figma: 아래 58.75%까지 흰색, 위로 갈수록 투명.
                  colors: [fade, fade.withValues(alpha: 0)],
                  stops: const [0.5875, 1],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
