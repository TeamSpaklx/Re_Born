import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_assets.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../shared/widgets/pressable.dart';
import '../data/intro_store.dart';

/// 인트로 끝 "시작할 준비가 끝났어요" 화면 (Figma 8877:1965): 첫 로그인 직후 투데이 앞에 한 번만 보인다.
/// 검은 배경에 제목·설명, 기울어진 앱 화면 목업이 있고 아래에서 검정으로 사라진다. "시작하기"를 누르면 투데이로 간다.
///
/// Figma 메모대로 분홍 버튼 위 글자는 흰색 대신 어두운 색(`onStartCta`)을 쓴다(흰 글자는 대비 2.36:1).
/// 목업은 어디까지나 분위기용이라 스크린 리더에는 읽히지 않게 한다.
class StartScreen extends ConsumerWidget {
  const StartScreen({super.key});

  Future<void> _start(BuildContext context, WidgetRef ref) async {
    final router = GoRouter.of(context);
    AppHaptics.tap();
    // 저장이 실패해도 투데이로는 보낸다(다음 로그인에 한 번 더 보일 뿐이다).
    try {
      await ref.read(introStoreProvider).markStartSeen();
    } catch (_) {}
    router.go(AppRoutes.today);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final top = MediaQuery.paddingOf(context).top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // 검은 배경이라 상태 바 글자를 밝게 한다.
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: colors.startBackground,
        body: Stack(
          children: [
            Positioned(
              top: top + StartLayout.previewTop,
              left: 0,
              right: 0,
              child: const ExcludeSemantics(child: Center(child: _Preview())),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _BottomFade(),
            ),
            Positioned(
              top: top + StartLayout.titleTop,
              left: AppSpacing.pageMargin,
              right: AppSpacing.pageMargin,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      '시작할 준비가 끝났어요.',
                      style: AppTextStyles.startTitle.copyWith(
                        color: colors.startTitle,
                      ),
                    ),
                  ),
                  const SizedBox(height: StartLayout.titleToBody),
                  Text(
                    '오늘의 감정부터 가볍게 기록해보세요.\n나와 소중한 관계를 알아가는 첫걸음이에요.',
                    style: AppTextStyles.startBody.copyWith(
                      color: colors.startBody,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: AppSpacing.pageMargin,
              right: AppSpacing.pageMargin,
              bottom:
                  MediaQuery.paddingOf(context).bottom + StartLayout.ctaBottom,
              child: _StartButton(onTap: () => _start(context, ref)),
            ),
          ],
        ),
      ),
    );
  }
}

/// 기울어진 앱 화면 목업 338×560 (불투명도 82%). 이미지는 상자 안에서 잘려 들어 있다.
class _Preview extends StatelessWidget {
  const _Preview();

  @override
  Widget build(BuildContext context) {
    const w = StartLayout.previewWidth;
    const h = StartLayout.previewHeight;
    return Opacity(
      opacity: StartLayout.previewOpacity,
      child: SizedBox(
        width: w,
        height: h,
        child: ClipRect(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: w * StartLayout.imageLeftFactor,
                top: h * StartLayout.imageTopFactor,
                width: w * StartLayout.imageWidthFactor,
                height: h * StartLayout.imageHeightFactor,
                child: Image.asset(AppAssets.startPreview, fit: BoxFit.fill),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 목업 아래쪽을 검정으로 덮는 그라데이션. 버튼이 이 위에 올라간다.
class _BottomFade extends StatelessWidget {
  const _BottomFade();

  @override
  Widget build(BuildContext context) {
    final black = context.colors.startBackground;
    return IgnorePointer(
      child: SizedBox(
        height: StartLayout.fadeHeight + MediaQuery.paddingOf(context).bottom,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [black.withValues(alpha: 0), black, black],
              stops: const [0, StartLayout.fadeSolidFrom, 1],
            ),
          ),
        ),
      ),
    );
  }
}

/// 분홍 알약 버튼, 글자는 어두운 색. 공통 `CtaButton`은 글자가 흰색 고정이라 이 화면만 따로 그린다.
class _StartButton extends StatelessWidget {
  const _StartButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: '시작하기',
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        key: const Key('start-go'),
        onTap: onTap,
        child: Container(
          height: StartLayout.ctaHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.ctaPrimary,
            borderRadius: AppRadii.pillBorderRadius,
          ),
          child: Text(
            '시작하기',
            style: AppTextStyles.ctaLarge.copyWith(color: colors.onStartCta),
          ),
        ),
      ),
    );
  }
}
