import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/app/app.dart';
import 'package:reborn_app/app/data_providers.dart';
import 'package:reborn_app/app/data_revision.dart';
import 'package:reborn_app/app/main_shell.dart';
import 'package:reborn_app/core/providers/clock_provider.dart';
import 'package:reborn_app/features/analysis/data/sample_data.dart';
import 'package:reborn_app/features/todos/data/in_memory_todos_repository.dart';
import 'package:reborn_app/shared/widgets/app_bottom_nav_bar.dart';

final fixedNow = DateTime(2026, 10, 22, 12);

/// 체크리스트(F-04)는 기록 탭의 "체크리스트" 칸에 있다.
void main() {
  Future<ProviderContainer> pumpChecklist(
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
        matching: find.text('기록'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('체크리스트'));
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(MainShell)));
  }

  testWidgets('기록 탭 체크리스트 칸: 항목과 완료율이 보이고 "기록하기" 버튼은 숨는다', (tester) async {
    await pumpChecklist(tester);
    final sample = buildSampleData(fixedNow).todos;

    for (final t in sample) {
      expect(find.text(t.title), findsOneWidget);
    }
    expect(find.text('1/2 완료 · 50%'), findsOneWidget);
    expect(find.text('기록하기'), findsNothing);
  });

  testWidgets('T-15: 항목을 추가하고 체크하면 상태가 저장되고 완료율이 바뀐다', (tester) async {
    final container = await pumpChecklist(tester);

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
    final container = await pumpChecklist(tester);
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
    await pumpChecklist(tester, emptyTodos: true);
    expect(find.text('체크리스트가 비어 있어요'), findsOneWidget);
    expect(find.text('0/0 완료 · 0%'), findsOneWidget);
  });

  testWidgets('삭제하면 항목이 사라진다', (tester) async {
    final container = await pumpChecklist(tester);
    final todo = (await container.read(todosRepositoryProvider).list()).first;

    await tester.tap(find.byKey(Key('todo-delete-${todo.id}')));
    await tester.pumpAndSettle();

    expect(await container.read(todosRepositoryProvider).list(), hasLength(1));
  });

  testWidgets('일기가 하나도 없어도 체크리스트는 보인다', (tester) async {
    final container = await pumpChecklist(tester);
    await container.read(entriesRepositoryProvider).deleteAll();
    container.read(dataRevisionProvider.notifier).bump();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('todo-title')), findsOneWidget);
    await tester.tap(find.text('달력'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('체크리스트'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('todo-title')), findsOneWidget);
  });
}
