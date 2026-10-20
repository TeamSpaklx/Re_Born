import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme/app_theme.dart';

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
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
