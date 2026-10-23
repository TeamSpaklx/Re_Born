import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'app/router.dart';
import 'core/config/supabase_config.dart';
import 'core/errors/app_error_log.dart';
import 'core/errors/error_handlers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 처리되지 않은 오류를 앱 안 기록에 남긴다(본문·인물 이름 제외, SPEC F-12).
  final errorLog = AppErrorLog();
  installErrorHandlers(errorLog);

  // 세로 방향만 지원한다 (iOS Info.plist, AndroidManifest에서도 고정).
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // 상태바·내비게이션 바 뒤까지 앱 화면을 그리고, 상태바 글자는 어둡게 한다.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        appErrorLogProvider.overrideWithValue(errorLog),
        initialLocationProvider.overrideWithValue(AppRoutes.splash),
      ],
      child: const RebornApp(),
    ),
  );

  // 아직 화면이 Supabase를 쓰지 않으므로, 첫 화면(스플래시 로고)이 뜨는 것을 막지 않게 앱을 켠 뒤에 준비한다.
  // Supabase를 처음 쓰는 코드가 생기면 이 준비가 끝난 뒤에 쓰도록 바꾼다.
  unawaited(_initSupabase(errorLog));
}

Future<void> _initSupabase(AppErrorLog errorLog) async {
  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
    );
  } catch (error, stack) {
    errorLog.record(error, stack, where: 'supabase');
  }
}
