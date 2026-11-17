import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/all/presentation/all_screen.dart';
import '../features/auth/presentation/account_delete_screen.dart';
import '../features/auth/presentation/consent_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/onboarding_screen.dart';
import '../features/auth/presentation/permission_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/home/presentation/today_screen.dart';
import '../features/insights/presentation/insight_detail_screen.dart';
import '../features/notifications/presentation/notification_settings_screen.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/record/presentation/record_detail_screen.dart';
import '../features/record/presentation/record_form_screen.dart';
import '../features/record/presentation/record_screen.dart';
import '../features/relations/presentation/person_detail_screen.dart';
import '../features/relations/presentation/person_form_screen.dart';
import '../features/relations/presentation/relations_screen.dart';
import '../shared/dev/design_gallery_screen.dart';
import 'main_shell.dart';

/// 화면 경로. 화면 이동은 문자열 대신 이 상수를 사용한다.
/// 순서는 하단 탭 순서(투데이 / 관계 / 기록 / 전체)와 같다.
abstract final class AppRoutes {
  /// 디자인 갤러리(개발용). 디버그 빌드에서만 등록된다.
  static const devGallery = '/dev/gallery';

  // 인증·온보딩
  static const login = '/login';
  static const signup = '/signup';
  static const signupConsent = '/signup/consent';
  static const onboarding = '/onboarding';
  static const onboardingPermission = '/onboarding/permission';
  static const accountDelete = '/account/delete';
  static const notifications = '/notifications';
  static const notificationSettings = '/notifications/settings';

  static const today = '/today';
  static const relations = '/relations';
  static const record = '/record';
  static const all = '/all';

  // 탭 위로 쌓이는 전체 화면
  static const recordNew = '/record/new';
  static String recordDetail(String id) => '/record/$id';
  static String recordEdit(String id) => '/record/$id/edit';
  static String insightDetail(String id) => '/insight/$id';
  static const relationsNew = '/relations/new';
  static String relationsDetail(String id) => '/relations/$id';
  static String relationsEdit(String id) => '/relations/$id/edit';
}

/// 앱이 처음 여는 경로. 기본값은 투데이이며, 디버그 실행에서 경로를 바꿀 수 있다.
final initialLocationProvider = Provider<String>((ref) => AppRoutes.today);

/// 앱 라우터. 앱은 투데이(홈)로 시작한다.
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: ref.read(initialLocationProvider),
    routes: [
      if (kDebugMode)
        GoRoute(
          path: AppRoutes.devGallery,
          builder: (context, state) => const DesignGalleryScreen(),
        ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.signupConsent,
        pageBuilder: (context, state) =>
            defaultTargetPlatform == TargetPlatform.iOS
            ? CupertinoPage<void>(
                key: state.pageKey,
                child: const ConsentScreen(),
              )
            : MaterialPage<void>(
                key: state.pageKey,
                child: const ConsentScreen(),
              ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingPermission,
        builder: (context, state) => const PermissionScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.notificationSettings,
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.accountDelete,
        builder: (context, state) => const AccountDeleteScreen(),
      ),
      GoRoute(
        path: AppRoutes.recordNew,
        builder: (context, state) => const RecordFormScreen(),
      ),
      GoRoute(
        path: '/insight/:id',
        builder: (context, state) =>
            InsightDetailScreen(insightId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/record/:id/edit',
        builder: (context, state) =>
            RecordFormScreen(entryId: state.pathParameters['id']),
      ),
      GoRoute(
        path: AppRoutes.relationsNew,
        builder: (context, state) => const PersonFormScreen(),
      ),
      GoRoute(
        path: '/relations/:id/edit',
        builder: (context, state) =>
            PersonFormScreen(personId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/relations/:id',
        builder: (context, state) =>
            PersonDetailScreen(personId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/record/:id',
        builder: (context, state) =>
            RecordDetailScreen(entryId: state.pathParameters['id']!),
      ),
      StatefulShellRoute.indexedStack(
        // 하단 탭 셸은 별도 화면 전환 없이 바로 표시한다.
        pageBuilder: (context, state, navigationShell) =>
            NoTransitionPage<void>(
              key: state.pageKey,
              child: MainShell(navigationShell: navigationShell),
            ),
        branches: [
          _branch(AppRoutes.today, const TodayScreen()),
          _branch(AppRoutes.relations, const RelationsScreen()),
          _branch(AppRoutes.record, const RecordScreen()),
          _branch(AppRoutes.all, const AllScreen()),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

StatefulShellBranch _branch(String path, Widget screen) {
  return StatefulShellBranch(
    routes: [GoRoute(path: path, builder: (context, state) => screen)],
  );
}
