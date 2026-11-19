import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:reborn_app/app/swipe_back_page.dart';

/// 쌓인 화면은 화면 어디서나 오른쪽으로 밀어 이전 페이지로 돌아간다(iOS·Android 공통).
void main() {
  const width = 402.0;

  Future<GoRouter> pumpRouter(
    WidgetTester tester, {
    Widget? second,
    String initial = '/a',
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(width, 874);
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: initial,
      routes: [
        GoRoute(
          path: '/a',
          pageBuilder: (context, state) => SwipeBackPage<void>(
            key: state.pageKey,
            child: const Scaffold(body: Center(child: Text('A 화면'))),
          ),
        ),
        GoRoute(
          path: '/b',
          pageBuilder: (context, state) => SwipeBackPage<void>(
            key: state.pageKey,
            child: second ?? const Scaffold(body: Center(child: Text('B 화면'))),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    return router;
  }

  Future<void> openB(WidgetTester tester, GoRouter router) async {
    router.push('/b');
    await tester.pumpAndSettle();
    expect(find.text('B 화면'), findsOneWidget);
  }

  Offset middle() => const Offset(width / 2, 437);

  double bLeft(WidgetTester tester) =>
      tester.getTopLeft(find.text('B 화면')).dx -
      (width - tester.getSize(find.text('B 화면')).width) / 2;

  testWidgets('화면 가운데에서 폭의 60%를 오른쪽으로 밀면 이전 화면으로 돌아간다', (tester) async {
    final router = await pumpRouter(tester);
    await openB(tester, router);

    final gesture = await tester.startGesture(middle());
    await gesture.moveBy(const Offset(20, 0)); // 끌기 시작 문턱
    await gesture.moveBy(const Offset(width * 0.6 - 20, 0));
    await tester.pump();
    expect(bLeft(tester), closeTo(width * 0.6 - 20, 30), reason: '손가락을 따라온다');

    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('B 화면'), findsNothing);
    expect(find.text('A 화면'), findsOneWidget);
  });

  testWidgets('20%만 천천히 밀고 놓으면 제자리로 돌아온다', (tester) async {
    final router = await pumpRouter(tester);
    await openB(tester, router);

    await tester.timedDragFrom(
      middle(),
      const Offset(width * 0.2, 0),
      const Duration(seconds: 1),
    );
    await tester.pumpAndSettle();
    expect(find.text('B 화면'), findsOneWidget);
    expect(bLeft(tester), closeTo(0, 0.5));
  });

  testWidgets('짧게라도 오른쪽으로 빠르게 튕기면 돌아간다', (tester) async {
    final router = await pumpRouter(tester);
    await openB(tester, router);

    await tester.flingFrom(middle(), const Offset(80, 0), 1500);
    await tester.pumpAndSettle();
    expect(find.text('B 화면'), findsNothing);
  });

  testWidgets('왼쪽으로 밀면 아무 일도 없다', (tester) async {
    final router = await pumpRouter(tester);
    await openB(tester, router);

    await tester.flingFrom(middle(), const Offset(-200, 0), 1500);
    await tester.pumpAndSettle();
    expect(find.text('B 화면'), findsOneWidget);
    expect(bLeft(tester), closeTo(0, 0.5));
  });

  testWidgets('가로 목록 위에서 밀면 목록이 먼저 움직이고 화면은 그대로다', (tester) async {
    final controller = ScrollController(initialScrollOffset: 400);
    addTearDown(controller.dispose);
    final router = await pumpRouter(
      tester,
      second: Scaffold(
        body: Column(
          children: [
            const Expanded(child: Center(child: Text('B 화면'))),
            SizedBox(
              height: 100,
              child: ListView(
                controller: controller,
                scrollDirection: Axis.horizontal,
                children: [
                  for (var i = 0; i < 20; i++)
                    SizedBox(width: 100, child: Text('칸 $i')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    await openB(tester, router);

    await tester.dragFrom(const Offset(width / 2, 824), const Offset(250, 0));
    await tester.pumpAndSettle();
    expect(find.text('B 화면'), findsOneWidget);
    expect(controller.offset, lessThan(400), reason: '목록이 왼쪽으로 스크롤됨');
  });

  testWidgets('PopScope(canPop: false)인 화면은 밀어도 남아 있다', (tester) async {
    final router = await pumpRouter(
      tester,
      second: const PopScope(
        canPop: false,
        child: Scaffold(body: Center(child: Text('B 화면'))),
      ),
    );
    await openB(tester, router);

    await tester.dragFrom(middle(), const Offset(width * 0.8, 0));
    await tester.pumpAndSettle();
    expect(find.text('B 화면'), findsOneWidget);
  });

  testWidgets('첫 화면은 밀어도 아무 일 없다', (tester) async {
    await pumpRouter(tester);
    await tester.dragFrom(middle(), const Offset(width * 0.8, 0));
    await tester.pumpAndSettle();
    expect(find.text('A 화면'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('PopScope가 막은 화면을 충분히 밀면 그 화면의 확인 처리(maybePop)를 부른다', (
    tester,
  ) async {
    var asked = 0;
    final router = await pumpRouter(
      tester,
      second: PopScope<Object?>(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) asked++;
        },
        child: const Scaffold(body: Center(child: Text('B 화면'))),
      ),
    );
    await openB(tester, router);

    // 조금만 천천히 밀면 묻지 않는다.
    final gesture = await tester.startGesture(middle());
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(const Offset(6, 0));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await gesture.up();
    await tester.pumpAndSettle();
    expect(asked, 0);

    await tester.dragFrom(middle(), const Offset(width * 0.8, 0));
    await tester.pumpAndSettle();
    expect(asked, 1);
    expect(find.text('B 화면'), findsOneWidget);
  });
}
