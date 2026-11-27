import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'app/theme/app_overlay_styles.dart';
import 'app/data_providers.dart';
import 'app/router.dart';
import 'core/config/supabase_config.dart';
import 'core/errors/app_error_log.dart';
import 'core/errors/error_handlers.dart';
import 'features/auth/data/auth_session_store.dart';
import 'features/auth/data/in_memory_auth_repository.dart';
import 'features/onboarding/data/intro_store.dart';
import 'features/security/data/app_lock_store.dart';
import 'features/settings/data/theme_mode_store.dart';
import 'features/security/presentation/app_lock_back_guard.dart';

const _initialRoute = String.fromEnvironment('INITIAL_ROUTE');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 처리되지 않은 오류를 앱 안 기록에 남긴다(본문·인물 이름 제외, SPEC F-12).
  final errorLog = AppErrorLog();
  installErrorHandlers(errorLog);

  // 세로 방향은 iOS Info.plist와 AndroidManifest에서 고정한다.
  // 상태바·내비게이션 바 설정은 첫 화면을 기다리게 하지 않는다.
  unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
  // 앱 잠금 켜짐 여부는 첫 프레임 전에 읽는다(켜져 있으면 첫 화면부터 잠금 화면이 덮여야 한다).
  final appLockStore = await _loadAppLockStore(errorLog);
  // 로그인 상태도 첫 화면(로그인 / 투데이)을 정해야 해서 미리 읽는다.
  final authSessionStore = await _loadAuthSessionStore(errorLog);
  // 인트로를 이미 봤는지도 스플래시가 끝날 때 바로 필요해서 미리 읽는다.
  final introStore = await _loadIntroStore(errorLog);
  // 다크 모드 선택도 첫 프레임 색을 정해서 미리 읽는다.
  final themeModeStore = await _loadThemeModeStore(errorLog);
  // 첫 프레임 전의 상태 바 글자색도 저장된 모드에 맞춘다(이후에는 앱이 화면별로 정한다).
  SystemChrome.setSystemUIOverlayStyle(
    AppOverlayStyles.of(switch (themeModeStore.mode) {
      ThemeMode.dark => Brightness.dark,
      ThemeMode.light => Brightness.light,
      ThemeMode.system => PlatformDispatcher.instance.platformBrightness,
    }),
  );
  // 잠긴 동안 뒤로 버튼을 막는 관찰자는 라우터보다 먼저 등록해야 먼저 불린다.
  AppLockBackGuard.instance.install();

  runApp(
    ProviderScope(
      overrides: [
        appErrorLogProvider.overrideWithValue(errorLog),
        appLockStoreProvider.overrideWithValue(appLockStore),
        introStoreProvider.overrideWithValue(introStore),
        themeModeStoreProvider.overrideWithValue(themeModeStore),
        // Supabase Auth를 붙이면 이 줄을 Supabase 구현으로 바꾼다.
        authRepositoryProvider.overrideWithValue(
          InMemoryAuthRepository(store: authSessionStore),
        ),
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

/// 저장소를 못 읽으면 잠금 꺼짐으로 시작한다(앱이 못 켜지는 것보다 낫다). 오류는 기록에 남긴다.
Future<AppLockStore> _loadAppLockStore(AppErrorLog errorLog) async {
  try {
    return await PrefsAppLockStore.create();
  } catch (error, stack) {
    errorLog.record(error, stack, where: 'app_lock_store');
    return InMemoryAppLockStore();
  }
}

/// 저장소를 못 읽으면 로그아웃 상태로 시작한다(로그인 화면이 뜬다). 오류는 기록에 남긴다.
Future<AuthSessionStore> _loadAuthSessionStore(AppErrorLog errorLog) async {
  try {
    return await PrefsAuthSessionStore.create();
  } catch (error, stack) {
    errorLog.record(error, stack, where: 'auth_session_store');
    return InMemoryAuthSessionStore();
  }
}

/// 저장소를 못 읽으면 처음 켠 것으로 보고 인트로를 보여 준다. 오류는 기록에 남긴다.
Future<IntroStore> _loadIntroStore(AppErrorLog errorLog) async {
  try {
    return await PrefsIntroStore.create();
  } catch (error, stack) {
    errorLog.record(error, stack, where: 'intro_store');
    return InMemoryIntroStore();
  }
}

/// 저장소를 못 읽으면 기기 설정을 따른다. 오류는 기록에 남긴다.
Future<ThemeModeStore> _loadThemeModeStore(AppErrorLog errorLog) async {
  try {
    return await PrefsThemeModeStore.create();
  } catch (error, stack) {
    errorLog.record(error, stack, where: 'theme_mode_store');
    return InMemoryThemeModeStore();
  }
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
