import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

import 'theme/app_motion.dart';

/// 탭 위로 쌓이는 화면의 페이지. iOS·Android 모두 오른쪽에서 밀려 들어오고(iOS식 전환),
/// **화면 어디서나** 오른쪽으로 밀면 손가락을 따라 이전 페이지로 돌아간다(토스·인스타식).
///
/// - 놓았을 때 절반 넘게 밀었거나 오른쪽으로 빠르게 튕기면 뒤로 가고, 아니면 제자리로 돌아온다(iOS 기본 규칙).
/// - 가로로 미는 안쪽 요소(입력창 글자 선택, 가로 목록, 밀어서 삭제)가 있으면 그 요소가 먼저다.
/// - 첫 화면, `PopScope(canPop: false)`로 막은 화면은 밀리지 않는다.
///
/// Flutter의 iOS 뒤로 끌기는 화면 왼쪽 20pt에서만 되고 안쪽 제스처보다 먼저 이기므로, 같은 규칙을 직접 구현했다.
class SwipeBackPage<T> extends Page<T> {
  const SwipeBackPage({
    required this.child,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) => _SwipeBackRoute<T>(this);
}

class _SwipeBackRoute<T> extends PageRoute<T> {
  _SwipeBackRoute(SwipeBackPage<T> page) : super(settings: page);

  SwipeBackPage<T> get _page => settings as SwipeBackPage<T>;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => AppMotion.normal;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: _page.child,
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return CupertinoPageTransition(
      primaryRouteAnimation: animation,
      secondaryRouteAnimation: secondaryAnimation,
      // 손가락으로 끄는 동안에는 곡선 없이 손가락 위치 그대로 움직인다.
      linearTransition: popGestureInProgress,
      child: _SwipeBackDetector(route: this, child: child),
    );
  }

  // ── 끌기 처리: controller는 라우트 안에서만 다룰 수 있어 여기서 처리한다 ──

  void _dragStart() => navigator!.didStartUserGesture();

  /// [fraction]: 화면 폭 대비 오른쪽으로 민 비율(오른쪽이 +).
  void _dragUpdate(double fraction) {
    final c = controller!;
    c.value = (c.value - fraction).clamp(0.0, 1.0);
  }

  /// [velocity]: 화면 폭 대비 초당 속도(오른쪽이 +). iOS `CupertinoPageRoute`와 같은 규칙과 시간.
  void _dragEnd(double velocity) {
    final c = controller!;
    final nav = navigator!;
    final stay = velocity.abs() >= AppMotion.swipeBackFlingVelocity
        ? velocity <= 0
        : c.value > 0.5;
    if (stay) {
      final ms = math.min(lerpDouble(800, 0, c.value)!.floor(), 300);
      c.animateTo(
        1,
        duration: Duration(milliseconds: ms),
        curve: Curves.fastEaseInToSlowEaseOut,
      );
    } else {
      nav.pop();
      if (c.isAnimating) {
        final ms = lerpDouble(0, 800, c.value)!.floor();
        c.animateBack(
          0,
          duration: Duration(
            milliseconds: math.max(
              ms,
              AppMotion.swipeBackMinDuration.inMilliseconds,
            ),
          ),
          curve: Curves.fastEaseInToSlowEaseOut,
        );
      }
    }
    if (c.isAnimating) {
      late final AnimationStatusListener done;
      done = (status) {
        nav.didStopUserGesture();
        c.removeStatusListener(done);
      };
      c.addStatusListener(done);
    } else {
      nav.didStopUserGesture();
    }
  }

  @override
  String get debugLabel => '${super.debugLabel}(${_page.name})';
}

/// 페이지 전체를 감싸 가로 끌기를 받는다. 안쪽 위젯보다 바깥(조상)에 있어서, 안쪽의 가로 제스처가 먼저 이긴다.
class _SwipeBackDetector<T> extends StatefulWidget {
  const _SwipeBackDetector({required this.route, required this.child});

  final _SwipeBackRoute<T> route;
  final Widget child;

  @override
  State<_SwipeBackDetector<T>> createState() => _SwipeBackDetectorState<T>();
}

class _SwipeBackDetectorState<T> extends State<_SwipeBackDetector<T>> {
  late final HorizontalDragGestureRecognizer _recognizer =
      HorizontalDragGestureRecognizer(debugOwner: this)
        ..onStart = _onStart
        ..onUpdate = _onUpdate
        ..onEnd = _onEnd
        ..onCancel = _onCancel;
  bool _dragging = false;

  @override
  void dispose() {
    _recognizer.dispose();
    if (_dragging) {
      // 끄는 도중 화면이 사라지면(다른 이유로 닫힘) 제스처 상태만 정리한다.
      final nav = widget.route.navigator;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (nav?.mounted ?? false) nav!.didStopUserGesture();
      });
    }
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    if (widget.route.popGestureEnabled) _recognizer.addPointer(event);
  }

  void _onStart(DragStartDetails details) {
    _dragging = true;
    widget.route._dragStart();
  }

  void _onUpdate(DragUpdateDetails details) {
    if (!_dragging) return;
    widget.route._dragUpdate(details.primaryDelta! / context.size!.width);
  }

  void _onEnd(DragEndDetails details) {
    if (!_dragging) return;
    _dragging = false;
    widget.route._dragEnd(
      details.velocity.pixelsPerSecond.dx / context.size!.width,
    );
  }

  void _onCancel() {
    if (!_dragging) return;
    _dragging = false;
    widget.route._dragEnd(0);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerDown,
      child: widget.child,
    );
  }
}
