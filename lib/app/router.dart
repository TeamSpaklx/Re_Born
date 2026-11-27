import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/all/presentation/all_screen.dart';
import '../features/analysis_tab/presentation/analysis_screen.dart';
import '../features/auth/presentation/account_delete_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/onboarding/presentation/intro_screen.dart';
import '../features/onboarding/presentation/start_screen.dart';
import '../features/home/presentation/today_screen.dart';
import '../features/notifications/presentation/notification_settings_screen.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/record/presentation/record_detail_screen.dart';
import '../features/record/presentation/record_form_screen.dart';
import '../features/record/presentation/record_result_screen.dart';
import '../features/record/presentation/record_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../shared/dev/design_gallery_screen.dart';
import 'main_shell.dart';
import 'swipe_back_page.dart';
import 'theme/app_spacing.dart';

/// 화면 경로. 화면 이동은 문자열 대신 이 상수를 사용한다.
/// 탭 경로 순서는 하단 탭 순서(홈 / 분석 / 기록 / 마이)와 같다. today·all은 예전 이름(투데이·전체) 그대로다.
abstract final class AppRoutes {
  static const splash = '/splash';

  /// 디자인 갤러리(개발용). 디버그 빌드에서만 등록된다.
  static const devGallery = '/dev/gallery';

  // 인증
  static const login = '/login';
  static const signup = '/signup';
  static const intro = '/intro';
  static const start = '/start';
  static const accountDelete = '/account/delete';
  static const notifications = '/notifications';
  static const notificationSettings = '/notifications/settings';

  static const today = '/today';
  static const analysis = '/analysis';
  static const record = '/record';
  static const all = '/all';

  /// 기록 탭의 체크리스트 칸.
  static const checklist = '/record?view=checklist';

  // 탭 위로 쌓이는 전체 화면
  static const recordNew = '/record/new';
  static String recordDetail(String id) => '/record/$id';
  static String recordEdit(String id) => '/record/$id/edit';

  /// 저장 직후 AI 코멘트를 보여 주는 결과 화면.
  static String recordResult(String id) => '/record/$id/result';
}

/// 앱이 처음 여는 경로. 실제 앱은 `main.dart`에서 스플래시로 바꾸고,
/// 테스트는 기본값(투데이)으로 바로 화면을 확인한다.
final initialLocationProvider = Provider<String>((ref) => AppRoutes.today);

/// 앱 라우터. 앱은 스플래시로 시작해 투데이(홈)로 넘어간다.
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: ref.read(initialLocationProvider),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      if (kDebugMode)
        GoRoute(
          path: AppRoutes.devGallery,
          pageBuilder: (context, state) =>
              _swipe(state, const DesignGalleryScreen()),
        ),
      // 로그인은 뒤로 갈 곳이 없는 첫 화면이라 스와이프 백 없이, 스플래시 위로 서서히 나타난다.
      GoRoute(
        path: AppRoutes.intro,
        pageBuilder: (context, state) => _fade(state, const IntroScreen()),
      ),
      GoRoute(
        path: AppRoutes.start,
        pageBuilder: (context, state) => _fade(state, const StartScreen()),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => _fade(state, const LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.signup,
        pageBuilder: (context, state) => _swipe(state, const SignupScreen()),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        pageBuilder: (context, state) =>
            _swipe(state, const NotificationsScreen()),
      ),
      GoRoute(
        path: AppRoutes.notificationSettings,
        pageBuilder: (context, state) =>
            _swipe(state, const NotificationSettingsScreen()),
      ),
      GoRoute(
        path: AppRoutes.accountDelete,
        pageBuilder: (context, state) =>
            _swipe(state, const AccountDeleteScreen()),
      ),
      GoRoute(
        path: AppRoutes.recordNew,
        pageBuilder: (context, state) =>
            _swipe(state, const RecordFormScreen()),
      ),
      GoRoute(
        path: '/record/:id/edit',
        pageBuilder: (context, state) => _swipe(
          state,
          RecordFormScreen(entryId: state.pathParameters['id']),
        ),
      ),
      GoRoute(
        path: '/record/:id/result',
        pageBuilder: (context, state) => _swipe(
          state,
          RecordResultScreen(entryId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/record/:id',
        pageBuilder: (context, state) => _swipe(
          state,
          RecordDetailScreen(entryId: state.pathParameters['id']!),
        ),
      ),
      StatefulShellRoute.indexedStack(
        // 스플래시에서 넘어올 때 옆에서 밀리지 않고, 로고 화면 위로 서서히 나타난다.
        pageBuilder: (context, state, navigationShell) =>
            _fade(state, MainShell(navigationShell: navigationShell)),
        branches: [
          _branch(AppRoutes.today, (_) => const TodayScreen()),
          _branch(AppRoutes.analysis, (_) => const AnalysisScreen()),
          _branch(
            AppRoutes.record,
            (state) => RecordScreen(
              initialView: RecordView.fromQuery(
                state.uri.queryParameters['view'],
              ),
            ),
          ),
          _branch(AppRoutes.all, (_) => const AllScreen()),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

/// 스플래시에서 넘어가는 첫 화면(투데이·로그인): 옆에서 밀리지 않고 로고 화면 위로 서서히 나타난다.
Page<void> _fade(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      transitionDuration: SplashLayout.fadeDuration,
      reverseTransitionDuration: SplashLayout.fadeDuration,
      transitionsBuilder: (context, animation, secondary, child) =>
          FadeTransition(
            opacity: animation.drive(CurveTween(curve: Curves.easeInOut)),
            child: child,
          ),
      child: child,
    );

/// 탭 위로 쌓이는 화면: 화면 어디서나 오른쪽으로 밀어 뒤로 갈 수 있다([SwipeBackPage]).
Page<void> _swipe(GoRouterState state, Widget child) =>
    SwipeBackPage<void>(key: state.pageKey, name: state.uri.path, child: child);

StatefulShellBranch _branch(
  String path,
  Widget Function(GoRouterState state) screen,
) {
  return StatefulShellBranch(
    routes: [GoRoute(path: path, builder: (context, state) => screen(state))],
  );
}
