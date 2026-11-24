import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_assets.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../home/presentation/home_providers.dart';
import '../../onboarding/data/intro_store.dart';
import '../../settings/presentation/settings_providers.dart';

/// 스플래시 화면(Figma 805:953): 흰 배경 한가운데에 로고, 아래에 팀 표기 "TeamSpaklx".
/// 로그인한 상태면 홈 화면 데이터가 준비되는 대로 투데이(홈)로, 아니면 로그인 화면으로 넘어간다.
/// 설치 후 처음 켠 것이면 로그인 앞에 인트로 온보딩이 한 번 끼어든다.
/// 로고는 처음부터 끝까지 같은 불투명 원본 색으로 그린다(투명도·크기 애니메이션 없음).
/// 홈으로 넘어갈 때는 홈이 이 화면 위로 서서히 나타난다(`router.dart`의 크로스페이드).
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 저장된 설정대로 기록 리마인드 예약을 맞춘다(실패해도 앱 시작은 막지 않는다).
    unawaited(
      ref.read(settingsActionsProvider).syncReminder().catchError((_) {}),
    );
    unawaited(_goNext());
  }

  /// 스플래시가 끝난 뒤 어디로 갈지는 이 함수 하나에서 정한다.
  /// 로그인 상태가 아니면 최소 표시 시간만 지나고 인트로(설치 후 처음이면) 또는 로그인 화면으로 간다.
  /// 로그인 상태면 최소 표시 시간과 홈 데이터 준비를 모두 기다린 뒤 투데이로 간다(인트로는 건너뜀).
  /// 홈 데이터가 오래 걸리거나 실패해도 [SplashLayout.maxDuration] 안에 넘어간다
  /// (실패하면 홈이 자체 오류 화면을 보여 준다).
  Future<void> _goNext() async {
    if (ref.read(sessionProvider) == null) {
      await Future<void>.delayed(SplashLayout.minDuration);
      if (!mounted) return;
      final seenIntro = ref.read(introStoreProvider).seen;
      context.go(seenIntro ? AppRoutes.login : AppRoutes.intro);
      return;
    }
    final homeReady = ref
        .read(homeSummaryProvider.future)
        .then<void>((_) {}, onError: (_) {});
    await Future.wait<void>([
      Future<void>.delayed(SplashLayout.minDuration),
      homeReady,
    ]).timeout(SplashLayout.maxDuration, onTimeout: () => <void>[]);
    if (mounted) context.go(AppRoutes.today);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.splashBackground,
      body: Stack(
        children: [
          Center(
            child: Transform.translate(
              offset: SplashLayout.logoOffset,
              child: Image.asset(
                AppAssets.logoMark,
                width: SplashLayout.logoSize,
                height: SplashLayout.logoSize,
                // 스크린 리더에는 앱 이름만 읽어 준다.
                semanticLabel: 'Re:Born',
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: SplashLayout.brandBottom,
                ),
                child: Text(
                  'TeamSpaklx',
                  style: AppTextStyles.splashBrand.copyWith(
                    color: colors.textBlack,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
