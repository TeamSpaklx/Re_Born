import 'package:flutter/cupertino.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_motion.dart';
import '../../core/utils/app_haptics.dart';

/// 당겨서 새로고침(iOS 스타일, iOS·Android 공통). `CustomScrollView`의 첫 sliver
/// (또는 고정 헤더 바로 다음)에 넣고, 스크롤은 튀는 물리(`BouncingScrollPhysics`)를 쓴다.
///
/// - 기준만큼 당기면 가벼운 햅틱과 함께 [onRefresh]를 부른다.
/// - 데이터가 바로 와도 스피너를 [AppMotion.refreshMinDuration]만큼은 보여 준다.
/// - [onRefresh]가 실패를 직접 처리해야 한다(여기서는 오류를 삼키지 않는다).
class AppRefreshControl extends StatelessWidget {
  const AppRefreshControl({super.key, required this.onRefresh});

  final Future<void> Function() onRefresh;

  Future<void> _refresh() async {
    AppHaptics.tap();
    await Future.wait<void>([
      onRefresh(),
      Future<void>.delayed(AppMotion.refreshMinDuration),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colors.textSecondary;
    return CupertinoSliverRefreshControl(
      onRefresh: _refresh,
      builder:
          (
            context,
            state,
            pulledExtent,
            refreshTriggerPullDistance,
            refreshIndicatorExtent,
          ) {
            final Widget indicator = switch (state) {
              RefreshIndicatorMode.inactive => const SizedBox.shrink(),
              RefreshIndicatorMode.drag =>
                CupertinoActivityIndicator.partiallyRevealed(
                  color: color,
                  progress: (pulledExtent / refreshTriggerPullDistance).clamp(
                    0.0,
                    1.0,
                  ),
                ),
              RefreshIndicatorMode.armed ||
              RefreshIndicatorMode.refresh => Semantics(
                label: '새로고침 중',
                liveRegion: true,
                child: CupertinoActivityIndicator(color: color),
              ),
              RefreshIndicatorMode.done =>
                CupertinoActivityIndicator.partiallyRevealed(
                  color: color,
                  progress: (pulledExtent / refreshIndicatorExtent).clamp(
                    0.0,
                    1.0,
                  ),
                ),
            };
            return Center(
              key: const Key('app-refresh-indicator'),
              child: indicator,
            );
          },
    );
  }
}
