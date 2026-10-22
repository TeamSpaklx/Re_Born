import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/app/app.dart';
import 'package:reborn_app/app/data_providers.dart';
import 'package:reborn_app/app/main_shell.dart';
import 'package:reborn_app/core/providers/clock_provider.dart';
import 'package:reborn_app/features/entries/models/emotion.dart';
import 'package:reborn_app/features/people/data/in_memory_people_repository.dart';
import 'package:reborn_app/features/record/presentation/record_form_screen.dart';

final fixedNow = DateTime(2026, 10, 22, 12);

/// 작성 화면 전체를 감싸는 스크롤(맨 바깥 Scrollable).
Finder formScrollable() => find
    .descendant(
      of: find.byType(RecordFormScreen),
      matching: find.byType(Scrollable),
    )
    .first;

void main() {
  void useDesignScreen(WidgetTester tester) {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(402, 874);
    addTearDown(tester.view.reset);
  }

  Future<ProviderContainer> pumpApp(
    WidgetTester tester, {
    bool noPeople = false,
  }) async {
    useDesignScreen(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clockProvider.overrideWithValue(() => fixedNow),
          if (noPeople)
            peopleRepositoryProvider.overrideWithValue(
              InMemoryPeopleRepository(),
            ),
        ],
        child: const RebornApp(),
      ),
    );
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(MainShell)));
  }

  Future<void> openRecordForm(WidgetTester tester) async {
    await tester.tap(find.text('기록'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('감정 기록하기').last);
    await tester.pumpAndSettle();
  }

  Future<void> pickEmotionAndIntensity(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      find.text('서운함'),
      100,
      scrollable: formScrollable(),
    );
    await tester.tap(find.text('서운함'));
    await tester.scrollUntilVisible(
      find.text('2 보통'),
      100,
      scrollable: formScrollable(),
    );
    await tester.tap(find.text('2 보통'));
    await tester.pump();
  }

  Future<void> tapSave(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      find.text('저장'),
      100,
      scrollable: formScrollable(),
    );
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
  }

  testWidgets('기록 탭: 날짜별 목록과 "감정 기록하기" 버튼이 보인다', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('기록'));
    await tester.pumpAndSettle();

    expect(find.text('감정 기록하기'), findsWidgets);
    expect(find.text('10월 21일 수요일'), findsOneWidget);
    expect(find.text('지민이가 답장을 늦게 해서 서운했다.'), findsWidgets);
  });

  testWidgets('T-11: 공백만 입력하고 저장하면 안내가 나오고 저장되지 않는다', (tester) async {
    final container = await pumpApp(tester);
    final before =
        (await container.read(entriesRepositoryProvider).list()).length;
    await openRecordForm(tester);

    await tester.enterText(find.byKey(const Key('record-body')), '   ');
    await tapSave(tester);

    expect(find.text('내용을 입력해 주세요.'), findsOneWidget);
    expect(
      (await container.read(entriesRepositoryProvider).list()).length,
      before,
    );
  });

  testWidgets('T-12: 감정·강도를 고르지 않으면 저장할 수 없다', (tester) async {
    await pumpApp(tester);
    await openRecordForm(tester);

    await tester.enterText(find.byKey(const Key('record-body')), '오늘은 조금 힘들었다');
    await tapSave(tester);

    expect(find.text('감정을 선택해 주세요.'), findsOneWidget);
    expect(find.text('강도를 선택해 주세요.'), findsOneWidget);
    expect(find.text('새 기록'), findsOneWidget, reason: '작성 화면에 남아 있다');
  });

  testWidgets('T-10: 본문·서운함·강도 2로 저장하면 목록에 생기고 점수는 −2', (tester) async {
    final container = await pumpApp(tester);
    await openRecordForm(tester);

    await tester.enterText(
      find.byKey(const Key('record-body')),
      '하은이가 노트를 돌려줄 때 고맙다는 말이 없어 서운했다',
    );
    await pickEmotionAndIntensity(tester);
    await tapSave(tester);

    final saved =
        (await container.read(entriesRepositoryProvider).list()).first;
    expect(saved.body, contains('하은이가'));
    expect(saved.emotion, Emotion.hurt);
    expect(saved.score, -2);
    expect(find.textContaining('하은이가 노트를'), findsOneWidget);
  });

  testWidgets('T-33: 위기 표현이면 안내를 보여 주고 저장은 그대로 진행한다', (tester) async {
    final container = await pumpApp(tester);
    await openRecordForm(tester);

    await tester.enterText(
      find.byKey(const Key('record-body')),
      '요즘 너무 힘들어서 죽고 싶다',
    );
    await pickEmotionAndIntensity(tester);
    await tapSave(tester);

    expect(find.text('마음이 많이 힘드신 것 같아요'), findsOneWidget);
    await tester.tap(find.text('확인했어요'));
    await tester.pumpAndSettle();

    final saved =
        (await container.read(entriesRepositoryProvider).list()).first;
    expect(saved.body, contains('죽고 싶다'));
  });

  testWidgets('T-33: 일반 문장에는 안내가 나오지 않는다', (tester) async {
    await pumpApp(tester);
    await openRecordForm(tester);

    await tester.enterText(
      find.byKey(const Key('record-body')),
      '오늘은 친구와 즐거웠다',
    );
    await pickEmotionAndIntensity(tester);
    await tapSave(tester);

    expect(find.text('마음이 많이 힘드신 것 같아요'), findsNothing);
  });

  testWidgets('T-09: 인물이 없으면 선택 시트에 안내가 나온다', (tester) async {
    await pumpApp(tester, noPeople: true);
    await openRecordForm(tester);

    await tester.tap(find.byKey(const Key('record-person')));
    await tester.pumpAndSettle();

    expect(find.textContaining('등록된 인물이 없어요'), findsOneWidget);
    await tester.tap(find.text('인물 없음').last);
    await tester.pumpAndSettle();
  });

  testWidgets('T-14: 상세에서 삭제하면 기록이 사라지고 지수가 다시 계산된다', (tester) async {
    final container = await pumpApp(tester);
    final history = container.read(indexHistoryRepositoryProvider);
    final entries = container.read(entriesRepositoryProvider);
    final target = (await entries.list(personId: 'p1')).first;
    await tester.tap(find.text('기록'));
    await tester.pumpAndSettle();

    await tester.tap(find.text(target.body).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();
    expect(find.text('기록을 삭제할까요?'), findsOneWidget);
    await tester.tap(find.text('삭제').last);
    await tester.pumpAndSettle();

    expect(await entries.get(target.id), isNull);
    final today = (await history.list('p1')).where(
      (p) => p.date.day == fixedNow.day && p.date.month == fixedNow.month,
    );
    expect(today, isNotEmpty, reason: '남은 기록으로 오늘 지수가 다시 저장됨');
  });
}
