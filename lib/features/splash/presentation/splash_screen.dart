import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_assets.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../home/presentation/home_providers.dart';

/// 스플래시 화면: 흰 배경 한가운데에 로고만 보여 주고, 홈 화면 데이터가 준비되면 투데이(홈)로 넘어간다.
/// 로고는 처음부터 끝까지 같은 불투명 원본 색으로 그린다(투명도·크기 애니메이션 없음).
/// 홈으로 넘어갈 때는 홈이 이 화면 위로 서서히 나타난다(`router.dart`의 크로스페이드).
/// 로그인이 생기면 여기서 로그인 여부를 확인해 로그인 화면과 홈 중 한 곳으로 보낸다.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(_goHomeWhenReady());
  }

  /// 최소 표시 시간과 홈 데이터 준비를 모두 기다린 뒤 홈으로 간다.
  /// 홈 데이터가 오래 걸리거나 실패해도 [SplashLayout.maxDuration] 안에 넘어간다
  /// (실패하면 홈이 자체 오류 화면을 보여 준다).
  Future<void> _goHomeWhenReady() async {
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
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Center(
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
    );
  }
}
