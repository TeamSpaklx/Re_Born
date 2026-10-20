import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/all/presentation/all_screen.dart';
import '../features/home/presentation/today_screen.dart';
import '../features/record/presentation/record_screen.dart';
import '../features/relations/presentation/relations_screen.dart';
import 'main_shell.dart';

/// 화면 경로. 화면 이동은 문자열 대신 이 상수를 사용한다.
/// 순서는 하단 탭 순서(투데이 / 관계 / 기록 / 전체)와 같다.
abstract final class AppRoutes {
  static const today = '/today';
  static const relations = '/relations';
  static const record = '/record';
  static const all = '/all';
}

/// 앱 라우터. 로그인 화면은 디자인이 나올 때까지 없고, 앱은 투데이(홈)로 바로 시작한다.
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.today,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
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
