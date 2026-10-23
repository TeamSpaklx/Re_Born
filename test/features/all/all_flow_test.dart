import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/app/app.dart';
import 'package:reborn_app/app/data_providers.dart';
import 'package:reborn_app/app/main_shell.dart';
import 'package:reborn_app/app/theme/app_spacing.dart';
import 'package:reborn_app/core/providers/clock_provider.dart';
import 'package:reborn_app/features/todos/data/in_memory_todos_repository.dart';
import 'package:reborn_app/features/todos/models/todo.dart';
import 'package:reborn_app/shared/widgets/app_bottom_nav_bar.dart';
import 'package:reborn_app/shared/widgets/app_toggle.dart';

final fixedNow = DateTime(2026, 10, 22, 12);

void main() {
  Future<ProviderContainer> pumpAll(
    WidgetTester tester, {
    bool emptyTodos = false,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(402, 1400);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clockProvider.overrideWithValue(() => fixedNow),
          if (emptyTodos)
            todosRepositoryProvider.overrideWithValue(
              InMemoryTodosRepository(),
            ),
        ],
        child: const RebornApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AppBottomNavBar),
        matching: find.text('전체'),
      ),
    );
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(MainShell)));
  }

  testWidgets('전체 탭: 체크리스트와 설정이 보인다', (tester) async {
    await pumpAll(tester);

    expect(find.text('체크리스트'), findsOneWidget);
    expect(find.text('지민님에게 가볍게 안부 묻기'), findsOneWidget);
    expect(find.text('이번 주 일기 3번 쓰기'), findsOneWidget);
    expect(find.text('1/2 완료 · 50%'), findsOneWidget);
    expect(find.text('설정'), findsOneWidget);
  });

  testWidgets('T-15: 항목을 추가하고 체크하면 상태가 저장되고 완료율이 바뀐다', (tester) async {
    final container = await pumpAll(tester);

    await tester.enterText(find.byKey(const Key('todo-title')), '하은에게 연락하기');
    await tester.tap(find.text('추가'));
    await tester.pumpAndSettle();
    expect(find.text('하은에게 연락하기'), findsOneWidget);
    expect(find.text('1/3 완료 · 33%'), findsOneWidget);

    final todos = await container.read(todosRepositoryProvider).list();
    final added = todos.firstWhere((t) => t.title == '하은에게 연락하기');
    await tester.tap(find.byKey(Key('todo-check-${added.id}')));
    await tester.pumpAndSettle();

    final after = (await container.read(todosRepositoryProvider).list())
        .firstWhere((t) => t.id == added.id);
    expect(after.done, isTrue);
    expect(after.doneAt, fixedNow);
    expect(find.text('2/3 완료 · 67%'), findsOneWidget);
  });

  testWidgets('T-16: 빈 제목은 저장되지 않는다', (tester) async {
    final container = await pumpAll(tester);
    final before =
        (await container.read(todosRepositoryProvider).list()).length;

    await tester.tap(find.text('추가'));
    await tester.pumpAndSettle();

    expect(find.text('제목을 입력해 주세요.'), findsOneWidget);
    expect(
      (await container.read(todosRepositoryProvider).list()).length,
      before,
    );
  });

  testWidgets('T-17: 항목이 없으면 빈 상태 안내가 나온다', (tester) async {
    await pumpAll(tester, emptyTodos: true);
    expect(find.text('체크리스트가 비어 있어요'), findsOneWidget);
    expect(find.text('0/0 완료 · 0%'), findsOneWidget);
  });

  testWidgets('삭제하면 항목이 사라진다', (tester) async {
    final container = await pumpAll(tester);
    final todo = (await container.read(todosRepositoryProvider).list()).first;

    await tester.tap(find.byKey(Key('todo-delete-${todo.id}')));
    await tester.pumpAndSettle();

    expect(await container.read(todosRepositoryProvider).list(), hasLength(1));
  });

  testWidgets('T-26: 인사이트의 제안을 체크리스트에 담으면 source = suggestion 항목이 생긴다', (
    tester,
  ) async {
    final container = await pumpAll(tester);
    final insight =
        (await container.read(insightsRepositoryProvider).list()).first;

    await tester.tap(
      find.descendant(
        of: find.byType(AppBottomNavBar),
        matching: find.text('관계'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('지민'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('최근 부정적인 기록이 늘었어요'));
    await tester.pumpAndSettle();

    expect(find.text('이렇게 해 보면 어떨까요?'), findsOneWidget);
    await tester.tap(find.text('체크리스트에 담기').first);
    await tester.pump(); // 토스트는 3초 뒤 사라지므로 settle하지 않고 바로 확인한다
    await tester.pump(ComponentLayout.toastFade);

    final todos = await container.read(todosRepositoryProvider).list();
    final added = todos.where(
      (t) => t.insightId == insight.id && t.source == TodoSource.suggestion,
    );
    expect(added.map((t) => t.title), contains('지민님에게 가볍게 안부 묻기'));
    expect(find.text('체크리스트에 담았어요'), findsWidgets);
    final opened = await container
        .read(insightsRepositoryProvider)
        .get(insight.id);
    expect(opened!.read, isTrue, reason: '열어 보면 읽음 처리');
  });

  testWidgets('T-30: 동의를 끄면 설정에 저장된다', (tester) async {
    final container = await pumpAll(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('consent-ai')),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('consent-ai')),
        matching: find.byType(AppToggle),
      ),
    );
    await tester.pumpAndSettle();

    final settings = await container.read(settingsRepositoryProvider).get();
    expect(settings.consents.aiAnalysis, isFalse);
    expect(settings.consents.privacy, isTrue);
  });

  testWidgets('F-11: 기록 전체 삭제는 확인 후 기록·지수·인사이트를 지우고 인물은 남긴다', (tester) async {
    final container = await pumpAll(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('delete-records')),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.tap(find.byKey(const Key('delete-records')));
    await tester.pumpAndSettle();
    expect(find.text('기록을 모두 삭제할까요?'), findsOneWidget);
    await tester.tap(find.text('삭제').last);
    await tester.pumpAndSettle();

    expect(await container.read(entriesRepositoryProvider).list(), isEmpty);
    expect(await container.read(insightsRepositoryProvider).list(), isEmpty);
    expect(
      await container.read(indexHistoryRepositoryProvider).list('p1'),
      isEmpty,
    );
    expect(await container.read(peopleRepositoryProvider).list(), isNotEmpty);
  });

  testWidgets('계정 삭제는 로그인 연결 뒤에 사용할 수 있다는 안내만 보여 준다', (tester) async {
    await pumpAll(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('delete-account')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('delete-account')));
    await tester.pumpAndSettle();
    expect(find.textContaining('로그인 기능이 연결된 뒤'), findsOneWidget);
  });
}
