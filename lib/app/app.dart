import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/security/presentation/app_lock_gate.dart';
import 'router.dart';
import 'theme/app_theme.dart';

/// 상태 바·내비게이션 바 기본 모양(`main.dart`의 시작 설정과 같은 값).
const _defaultOverlayStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.dark,
  statusBarBrightness: Brightness.light,
  systemNavigationBarColor: Colors.transparent,
  systemNavigationBarIconBrightness: Brightness.dark,
  systemNavigationBarContrastEnforced: false,
);

class RebornApp extends ConsumerWidget {
  const RebornApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Re:Born',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // 라이트 모드만 지원한다. 다크 모드는 나중에 darkTheme을 추가해서 넣는다.
      themeMode: ThemeMode.light,
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) {
        // 글자 크기 배율 1.0 고정: 시스템 글자 크기 설정을 무시한다.
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.noScaling),
          // 상태 바 글자는 기본이 어두운 색이다. 검은 화면(인트로 끝)이 따로 밝게 바꾸고,
          // 그 화면이 사라지면 이 기본값으로 돌아오게 앱 전체를 한 번 감싼다.
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: _defaultOverlayStyle,
            // 앱 잠금이 켜져 있으면 모든 화면 위에 잠금 화면을 덮는다.
            child: AppLockGate(child: child ?? const SizedBox.shrink()),
          ),
        );
      },
    );
  }
}
