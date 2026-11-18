import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'app/router.dart';
import 'core/config/supabase_config.dart';
import 'core/errors/app_error_log.dart';
import 'core/errors/error_handlers.dart';

const _initialRoute = String.fromEnvironment('INITIAL_ROUTE');

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 처리되지 않은 오류를 앱 안 기록에 남긴다(본문·인물 이름 제외, SPEC F-12).
  final errorLog = AppErrorLog();
  installErrorHandlers(errorLog);

  // 세로 방향은 iOS Info.plist와 AndroidManifest에서 고정한다.
  // 상태바·내비게이션 바 설정은 첫 화면을 기다리게 하지 않는다.
  unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
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
        // 개발 중 특정 화면에서 바로 시작하려면: flutter run --dart-define=INITIAL_ROUTE=/dev/gallery
        initialLocationProvider.overrideWithValue(
          kDebugMode && _initialRoute.isNotEmpty
              ? _initialRoute
              : AppRoutes.splash,
        ),
      ],
      child: const RebornApp(),
    ),
  );

  // 현재 화면은 Supabase를 쓰지 않으므로 첫 프레임 이후에 초기화한다.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(_initSupabase(errorLog));
  });
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
