import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_lock_back_guard.dart';
import 'app_lock_controller.dart';
import 'lock_screen.dart';

/// 앱 전체를 감싸 잠금 화면을 덮는다(`app.dart`의 `MaterialApp.builder`).
///
/// 라우트를 바꾸지 않고 위에 덮기만 해서, 잠금을 풀면 보던 화면 그대로 돌아온다.
/// 잠긴 동안 뒤 화면은 그리지 않고(Offstage) 터치·스크린 리더에서도 빠진다.
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate> {
  late final AppLifecycleListener _lifecycle;

  AppLockController get _controller =>
      ref.read(appLockControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    AppLockBackGuard.instance.blocking = ref
        .read(appLockControllerProvider)
        .obscured;
    _lifecycle = AppLifecycleListener(
      onInactive: () => _controller.onInactive(),
      onHide: () => _controller.onBackground(),
      onPause: () => _controller.onBackground(),
      onResume: () => _controller.onResume(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // 아직 생명주기 알림을 못 받았으면(null) 앞에 있다고 본다. 두 번 불려도 인증 중이면 무시된다.
      final state = WidgetsBinding.instance.lifecycleState;
      final foreground = state == null || state == AppLifecycleState.resumed;
      unawaited(_controller.start(foreground: foreground));
    });
  }

  @override
  void dispose() {
    AppLockBackGuard.instance.blocking = false;
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      appLockControllerProvider.select((s) => s.obscured),
      (_, obscured) => AppLockBackGuard.instance.blocking = obscured,
    );
    final lock = ref.watch(appLockControllerProvider);
    final obscured = lock.obscured;
    return Stack(
      children: [
        // 가려진 동안은 그리지도, 터치·스크린 리더에 넣지도 않는다(상태는 유지).
        // 그리지 않아야 iOS 네이티브 탭 바(플랫폼 뷰)도 잠금 화면 위로 비치지 않는다.
        Offstage(offstage: obscured, child: widget.child),
        if (obscured)
          Positioned.fill(
            child: LockScreen(
              key: const Key('lock-screen'),
              onRetry: lock.phase == AppLockPhase.failed
                  ? () => unawaited(_controller.unlock())
                  : null,
            ),
          ),
      ],
    );
  }
}
