import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/app/app.dart';
import 'package:reborn_app/app/data_providers.dart';
import 'package:reborn_app/app/main_shell.dart';
import 'package:reborn_app/core/providers/clock_provider.dart';
import 'package:reborn_app/features/analysis/data/sample_data.dart';
import 'package:reborn_app/features/insights/data/in_memory_insights_repository.dart';
import 'package:reborn_app/features/people/data/in_memory_people_repository.dart';
import 'package:reborn_app/features/relations/presentation/person_form_screen.dart';

final fixedNow = DateTime(2026, 10, 22, 12);

void main() {
  Future<ProviderContainer> pumpApp(
    WidgetTester tester, {
    bool noPeople = false,
    bool noHistory = false,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(402, 874);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clockProvider.overrideWithValue(() => fixedNow),
          if (noPeople)
            peopleRepositoryProvider.overrideWithValue(
              InMemoryPeopleRepository(),
            ),
          if (noHistory)
            indexHistoryRepositoryProvider.overrideWithValue(
              InMemoryIndexHistoryRepository(),
            ),
        ],
        child: const RebornApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('관계'));
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(MainShell)));
  }

  Future<void> openAddForm(WidgetTester tester) async {
    await tester.tap(find.text('인물 추가').first);
    await tester.pumpAndSettle();
  }

  Future<void> tapSave(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      find.text('저장'),
      100,
      scrollable: find
          .descendant(
            of: find.byType(PersonFormScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
  }

  testWidgets('관계 탭: 인물 목록에 이름·관계·지수가 보인다', (tester) async {
    await pumpApp(tester);

    expect(find.text('지민'), findsOneWidget);
    expect(find.text('승현'), findsOneWidget);
    expect(find.text('친구'), findsWidgets);
    expect(find.text('관계 지수'), findsWidgets);
    expect(find.text('데이터 부족'), findsNothing, reason: '샘플은 두 인물 모두 3건 이상');
  });

  testWidgets('T-09: 인물이 없으면 안내와 추가 버튼이 보인다', (tester) async {
    await pumpApp(tester, noPeople: true);
    expect(find.text('아직 등록한 인물이 없어요'), findsOneWidget);
  });

  testWidgets('T-06: 이름 "하은", 친구로 추가하면 목록에 표시된다', (tester) async {
    final container = await pumpApp(tester);
    await openAddForm(tester);

    await tester.enterText(find.byKey(const Key('person-name')), '하은');
    await tapSave(tester);

    expect(find.text('하은'), findsOneWidget);
    expect(
      (await container.read(peopleRepositoryProvider).list()).map(
        (p) => p.name,
      ),
      contains('하은'),
    );
  });

  testWidgets('T-07·T-08: 빈 이름·중복 이름은 거부한다', (tester) async {
    await pumpApp(tester);
    await openAddForm(tester);

    await tapSave(tester);
    expect(find.text('이름을 입력해 주세요.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('person-name')), '지민');
    await tapSave(tester);
    expect(find.text('이미 있는 이름이에요.'), findsOneWidget);
    expect(find.text('인물 추가'), findsWidgets);
  });

  testWidgets('T-27: 인물 상세에 지수·선 그래프·시작 대비 변화량이 보인다', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('지민'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('person-index')), findsOneWidget);
    expect(find.byKey(const Key('index-chart')), findsOneWidget);
    expect(find.textContaining('시작 대비'), findsOneWidget);
    expect(find.text('최근 부정적인 기록이 늘었어요'), findsOneWidget, reason: '지민의 인사이트');

    await tester.tap(find.text('1주'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('index-chart')), findsOneWidget);
  });

  testWidgets('T-28: 지수 이력이 없으면 안내가 나온다', (tester) async {
    await pumpApp(tester, noHistory: true);
    await tester.tap(find.text('지민'));
    await tester.pumpAndSettle();

    expect(find.text('기록이 더 쌓이면 그래프가 보여요'), findsOneWidget);
    expect(find.byKey(const Key('index-chart')), findsNothing);
  });

  testWidgets('삭제: "기록은 남기기"를 고르면 인물만 지워지고 기록은 인물 없음으로 남는다', (tester) async {
    final container = await pumpApp(tester);
    final entries = container.read(entriesRepositoryProvider);
    final before = (await entries.list()).length;

    await tester.tap(find.text('지민'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('기록은 남기기'));
    await tester.pumpAndSettle();

    final people = await container.read(peopleRepositoryProvider).list();
    expect(people.map((p) => p.name), isNot(contains('지민')));
    final after = await entries.list();
    expect(after.length, before);
    expect(after.where((e) => e.personId == 'p1'), isEmpty);
    expect(
      await container.read(insightsRepositoryProvider).list(personId: 'p1'),
      isEmpty,
    );
  });

  testWidgets('삭제: "기록도 함께 삭제"를 고르면 그 인물의 기록도 지워진다', (tester) async {
    final container = await pumpApp(tester);
    final entries = container.read(entriesRepositoryProvider);
    final own = (await entries.list(personId: 'p1')).length;
    final before = (await entries.list()).length;

    await tester.tap(find.text('지민'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('기록도 함께 삭제'));
    await tester.pumpAndSettle();

    expect((await entries.list()).length, before - own);
  });

  test('샘플 데이터는 지민·승현 모두 지수 이력이 있다', () {
    final data = buildSampleData(fixedNow);
    for (final id in ['p1', 'p2']) {
      expect(data.indexPoints.where((p) => p.personId == id), isNotEmpty);
    }
  });
}
