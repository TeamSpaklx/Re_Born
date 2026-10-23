import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/all/presentation/all_screen.dart';
import '../features/home/presentation/today_screen.dart';
import '../features/insights/presentation/insight_detail_screen.dart';
import '../features/record/presentation/record_detail_screen.dart';
import '../features/record/presentation/record_form_screen.dart';
import '../features/record/presentation/record_screen.dart';
import '../features/relations/presentation/person_detail_screen.dart';
import '../features/relations/presentation/person_form_screen.dart';
import '../features/relations/presentation/relations_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import 'main_shell.dart';
import 'theme/app_spacing.dart';

/// 화면 경로. 화면 이동은 문자열 대신 이 상수를 사용한다.
/// 순서는 하단 탭 순서(투데이 / 관계 / 기록 / 전체)와 같다.
abstract final class AppRoutes {
  static const splash = '/splash';

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

/// 앱이 처음 여는 경로. 실제 앱은 `main.dart`에서 스플래시로 바꾸고,
/// 테스트는 기본값(투데이)으로 바로 화면을 확인한다.
final initialLocationProvider = Provider<String>((ref) => AppRoutes.today);

/// 앱 라우터. 앱은 스플래시로 시작해 투데이(홈)로 넘어간다. 로그인 화면은 디자인이 나올 때까지 없다.
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: ref.read(initialLocationProvider),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
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
        // 스플래시에서 넘어올 때 옆에서 밀리지 않고, 로고 화면 위로 서서히 나타난다.
        pageBuilder: (context, state, navigationShell) =>
            CustomTransitionPage<void>(
              key: state.pageKey,
              transitionDuration: SplashLayout.fadeDuration,
              reverseTransitionDuration: SplashLayout.fadeDuration,
              transitionsBuilder: (context, animation, secondary, child) =>
                  FadeTransition(
                    opacity: animation.drive(
                      CurveTween(curve: Curves.easeInOut),
                    ),
                    child: child,
                  ),
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
