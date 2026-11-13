import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_assets.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';

/// 스플래시 화면: 흰 배경 한가운데에 로고만 보여 주고 잠시 뒤 투데이(홈)로 넘어간다.
/// 프론트 시연에서는 로그인 화면으로 이동한다.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(SplashLayout.duration, () {
      if (!mounted) return;
      context.go(AppRoutes.auth);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
