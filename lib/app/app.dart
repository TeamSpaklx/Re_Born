import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/security/presentation/app_lock_gate.dart';
import '../features/settings/presentation/settings_providers.dart';
import 'router.dart';
import 'theme/app_overlay_styles.dart';
import 'theme/app_theme.dart';

class RebornApp extends ConsumerWidget {
  const RebornApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Re:Born',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // 설정의 다크 모드 토글이 라이트/다크를 고른다(시스템 설정은 따르지 않는다).
      themeMode: ref.watch(themeModeProvider),
      // 모드를 바꿀 때 색이 중간값을 거치지 않고 한 번에 바뀐다(네이티브 탭 바를 모드마다 한 번만 다시 만든다).
      themeAnimationDuration: Duration.zero,
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) {
        // 글자 크기 배율 1.0 고정: 시스템 글자 크기 설정을 무시한다.
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.noScaling),
          // 상태 바 글자색은 앱 밝기를 따른다(라이트: 어두운 글자, 다크: 밝은 글자).
          // 검은 화면(인트로 끝)이 따로 밝게 바꾸고, 그 화면이 사라지면 이 값으로 돌아오게 앱 전체를 한 번 감싼다.
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: AppOverlayStyles.of(Theme.of(context).brightness),
            // 앱 잠금이 켜져 있으면 모든 화면 위에 잠금 화면을 덮는다.
            child: AppLockGate(child: child ?? const SizedBox.shrink()),
          ),
        );
      },
    );
  }
}
