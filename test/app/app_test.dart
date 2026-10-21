import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/app/app.dart';
import 'package:reborn_app/app/main_shell.dart';
import 'package:reborn_app/app/router.dart';
import 'package:reborn_app/features/all/presentation/all_screen.dart';
import 'package:reborn_app/features/home/presentation/today_screen.dart';
import 'package:reborn_app/features/record/presentation/record_screen.dart';
import 'package:reborn_app/features/relations/presentation/relations_screen.dart';

void main() {
  /// 햅틱 호출을 기록한다 (`HapticFeedback.xxx`는 platform 채널의 `HapticFeedback.vibrate`).
  late List<String> haptics;

  setUp(() {
    haptics = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            haptics.add(call.arguments as String);
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Future<ProviderContainer> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: RebornApp()));
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(MainShell)));
  }

  String currentPath(ProviderContainer container) {
    return container
        .read(routerProvider)
        .routeInformationProvider
        .value
        .uri
        .path;
  }

  testWidgets('로그인 없이 투데이 탭에서 시작한다', (tester) async {
    final container = await pumpApp(tester);

    expect(currentPath(container), AppRoutes.today);
    expect(find.byType(TodayScreen), findsOneWidget);
    for (final label in ['투데이', '관계', '기록', '전체']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('탭을 누르면 해당 화면으로 이동한다', (tester) async {
    final container = await pumpApp(tester);

    await tester.tap(find.text('관계'));
    await tester.pumpAndSettle();
    expect(currentPath(container), AppRoutes.relations);
    expect(find.byType(RelationsScreen), findsOneWidget);

    await tester.tap(find.text('기록'));
    await tester.pumpAndSettle();
    expect(currentPath(container), AppRoutes.record);
    expect(find.byType(RecordScreen), findsOneWidget);

    await tester.tap(find.text('전체'));
    await tester.pumpAndSettle();
    expect(currentPath(container), AppRoutes.all);
    expect(find.byType(AllScreen), findsOneWidget);

    await tester.tap(find.text('투데이'));
    await tester.pumpAndSettle();
    expect(currentPath(container), AppRoutes.today);
  });

  testWidgets('"감정 기록하기"는 기록 탭으로, "전체 보기"는 관계 탭으로 이동한다', (tester) async {
    final container = await pumpApp(tester);

    await tester.tap(find.text('감정 기록하기'));
    await tester.pumpAndSettle();
    expect(currentPath(container), AppRoutes.record);

    await tester.tap(find.text('투데이'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('전체 보기'));
    await tester.pumpAndSettle();
    expect(currentPath(container), AppRoutes.relations);
  });

  testWidgets('다른 탭으로 바꿀 때만 선택 햅틱이 울린다', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('관계'));
    await tester.pumpAndSettle();
    expect(haptics, ['HapticFeedbackType.selectionClick']);

    await tester.tap(find.text('관계')); // 같은 탭을 다시 누르면 울리지 않는다
    await tester.pumpAndSettle();
    expect(haptics, hasLength(1));
  });

  testWidgets('버튼과 "전체 보기"를 누르면 가벼운 햅틱이 울린다', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('전체 보기'));
    await tester.pumpAndSettle();
    expect(haptics, ['HapticFeedbackType.lightImpact']);

    await tester.tap(find.text('투데이'));
    await tester.pumpAndSettle();
    haptics.clear();
    await tester.tap(find.text('감정 기록하기'));
    await tester.pumpAndSettle();
    expect(haptics, ['HapticFeedbackType.lightImpact']);
  });

  testWidgets('디자인이 없는 탭은 흰 배경의 빈 화면이다', (tester) async {
    await pumpApp(tester);

    final screens = {
      '관계': find.byType(RelationsScreen),
      '기록': find.byType(RecordScreen),
      '전체': find.byType(AllScreen),
    };
    for (final entry in screens.entries) {
      await tester.tap(find.text(entry.key));
      await tester.pumpAndSettle();
      final scaffold = tester.widget<Scaffold>(
        find.descendant(of: entry.value, matching: find.byType(Scaffold)),
      );
      expect(scaffold.backgroundColor, Colors.white, reason: entry.key);
      expect(scaffold.appBar, isNull, reason: entry.key);
      expect(scaffold.body, isNull, reason: entry.key);
    }
  });

  testWidgets('시스템 글자 크기를 키워도 앱 글자 배율은 1.0이다', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pumpApp(tester);

    final context = tester.element(find.byType(MainShell));
    expect(MediaQuery.textScalerOf(context).scale(10), 10);
  });
}
