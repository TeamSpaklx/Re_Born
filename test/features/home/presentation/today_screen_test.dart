import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/app/app.dart';
import 'package:reborn_app/app/data_providers.dart';
import 'package:reborn_app/app/main_shell.dart';
import 'package:reborn_app/app/theme/app_colors.dart';
import 'package:reborn_app/app/theme/app_radii.dart';
import 'package:reborn_app/app/theme/app_spacing.dart';
import 'package:reborn_app/app/theme/app_theme.dart';
import 'package:reborn_app/core/providers/clock_provider.dart';
import 'package:reborn_app/features/entries/data/in_memory_entries_repository.dart';
import 'package:reborn_app/app/data_revision.dart';
import 'package:reborn_app/features/entries/models/emotion.dart';
import 'package:reborn_app/features/entries/models/entry.dart';
import 'package:reborn_app/features/home/presentation/today_screen.dart';
import 'package:reborn_app/features/home/presentation/widgets/action_suggestion_card.dart';
import 'package:reborn_app/features/home/presentation/widgets/home_header.dart';
import 'package:reborn_app/features/home/presentation/widgets/home_top_bar.dart';
import 'package:reborn_app/features/home/presentation/widgets/record_card_after.dart';
import 'package:reborn_app/features/home/presentation/widgets/record_card_before.dart';
import 'package:reborn_app/features/home/presentation/widgets/relation_signal_card.dart';
import 'package:reborn_app/features/home/presentation/widgets/weekly_emotion_card.dart';
import 'package:reborn_app/shared/widgets/app_bottom_nav_bar.dart';
import 'package:reborn_app/shared/widgets/centered_line.dart';

import '../../../helpers/load_fonts.dart';

/// 처음에는 실패하고 다시 부르면 성공하는 기록 저장소 (홈 오류·재시도 확인).
class _FlakyEntries extends InMemoryEntriesRepository {
  _FlakyEntries(this.calls);

  final List<int> calls;

  @override
  Future<List<Entry>> list({String? personId}) async {
    calls.add(1);
    if (calls.length == 1) throw StateError('network');
    return super.list(personId: personId);
  }
}

/// 불러오는 데 1초 걸리는 기록 저장소 (로딩 상태 확인).
class _SlowEntries extends InMemoryEntriesRepository {
  @override
  Future<List<Entry>> list({String? personId}) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return super.list(personId: personId);
  }
}

void main() {
  setUpAll(loadPretendard);

  // 샘플 데이터 기준 시각: 2026-10-22(목) 12시. 오늘 기록은 아직 없다.
  final now = DateTime(2026, 10, 22, 12);

  /// 디자인 기준 화면(402×874, 상태바 영역 62)으로 맞춘다.
  void useDesignScreen(WidgetTester tester, {double width = 402}) {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, 874);
    tester.view.padding = const FakeViewPadding(top: 62);
    addTearDown(tester.view.reset);
  }

  Future<void> pumpHome(
    WidgetTester tester, {
    List<Override> overrides = const [],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [clockProvider.overrideWithValue(() => now), ...overrides],
        child: MaterialApp(theme: AppTheme.light, home: const TodayScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  double top(WidgetTester tester, Finder finder) =>
      tester.getTopLeft(finder).dy;

  testWidgets('샘플 데이터로 홈이 채워진다 (Before: 오늘 기록 없음)', (tester) async {
    useDesignScreen(tester);
    await pumpHome(tester);

    for (final text in [
      '10월 22일 목요일',
      '규리님, 오늘도 즐거운\n하루 보내세요!',
      '아직 오늘의 마음을 기록하지 않았어요',
      '1분만 천천히 돌아볼까요?',
      '감정 기록하기',
      '최근 관계 신호',
      '전체 보기',
      '지민',
      '친구',
      '최근 부정적인 기록이 늘었어요',
      '마지막 기록 1일 전',
      '이번 주 감정 흐름',
      '✦ 10월',
      '오늘 해볼까요?',
      '지민님에게 가볍게 안부 묻기',
    ]) {
      expect(find.text(text), findsWidgets, reason: text);
    }
    expect(find.byType(RecordCardAfter), findsNothing);
    expect(find.textContaining('긍정적인 감정이', findRichText: true), findsOneWidget);
  });

  testWidgets('402×874에서 각 요소의 y가 Figma 좌표와 ±1px 안에서 같다', (tester) async {
    useDesignScreen(tester);
    await pumpHome(tester);

    void expectY(String name, Finder finder, double y) =>
        expect(top(tester, finder), closeTo(y, 1), reason: name);

    expectY(
      '날짜',
      find.ancestor(
        of: find.text('10월 22일 목요일'),
        matching: find.byType(CenteredLine),
      ),
      HomeLayout.dateY,
    );
    expectY('인사말', find.textContaining('규리님'), HomeLayout.greetingY);
    expectY('기록 카드', find.byType(RecordCardBefore), HomeLayout.recordCardY);
    expectY('관계 신호 제목', find.text('최근 관계 신호'), HomeLayout.signalTitleY);
    expectY('신호 카드', find.byType(RelationSignalCard), HomeLayout.signalCardY);
    expectY('그래프 카드', find.byType(WeeklyEmotionCard), HomeLayout.graphCardY);
    expectY('오늘 해볼까요 제목', find.text('오늘 해볼까요?'), HomeLayout.actionTitleY);
    final actions = find.byType(ActionSuggestionCard);
    expect(actions, findsNWidgets(2));
    expectY('액션 카드 1', actions.at(0), HomeLayout.actionCardY1);
    expectY('액션 카드 2', actions.at(1), HomeLayout.actionCardY2);
  });

  testWidgets('카드 크기: 폭 354, 높이는 Figma와 같다', (tester) async {
    useDesignScreen(tester);
    await pumpHome(tester);

    void expectSize(Finder f, double h) {
      final size = tester.getSize(f);
      expect(size.width, 354);
      expect(size.height, h);
    }

    expectSize(
      find.byType(RecordCardBefore),
      HomeLayout.recordCardHeightBefore,
    );
    expectSize(find.byType(RelationSignalCard), HomeLayout.signalCardHeight);
    expectSize(find.byType(WeeklyEmotionCard), HomeLayout.graphCardHeight);
    expectSize(
      find.byType(ActionSuggestionCard).first,
      HomeLayout.actionCardHeight,
    );
  });

  testWidgets('주간 그래프: 이번 주 월~수 기록의 평균 점수로 막대가 그려지고 나머지 요일은 막대가 없다', (
    tester,
  ) async {
    useDesignScreen(tester);
    await pumpHome(tester);

    final bars = find.byWidgetPredicate((w) {
      if (w is! DecoratedBox) return false;
      final d = w.decoration;
      return d is BoxDecoration &&
          d.color == AppColors.light.brand &&
          d.borderRadius == AppRadii.graphBarBorderRadius;
    });
    // 월(평온 0과 서운함 −2의 평균 −1 → 0.3333), 화(−2와 +1의 평균 → 0.4167), 수(−2 → 0.1667)
    expect(bars, findsNWidgets(3));
    const expected = [0.33333, 0.41667, 0.16667];
    for (var i = 0; i < 3; i++) {
      expect(
        tester.getSize(bars.at(i)).height,
        closeTo(expected[i] * GraphLayout.maxBarHeight, 0.05),
        reason: 'bar $i',
      );
    }
    expect(
      find.text('긍정적인 감정이 조금씩 줄고 있어요.', findRichText: true),
      findsOneWidget,
      reason: '첫 3일은 평균이 내려가는 흐름',
    );
    expect(find.textContaining('조금씩 줄고', findRichText: true), findsOneWidget);
    expect(find.text('🙂'), findsOneWidget, reason: '가장 높은 화요일(0.4167)');
  });

  testWidgets('폭 360에서도 오버플로 없이 카드가 폭을 채운다', (tester) async {
    useDesignScreen(tester, width: 360);
    await pumpHome(tester);

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(WeeklyEmotionCard)).width, 312);
    expect(tester.getSize(find.byType(RecordCardBefore)).width, 312);
  });

  testWidgets('맨 아래에 탭 바 여백 148이 남는다', (tester) async {
    useDesignScreen(tester);
    await pumpHome(tester);

    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
    // 내용 높이 1205(Figma 프레임) − 화면 874
    expect(scrollable.position.maxScrollExtent, closeTo(1205 - 874, 1));
  });

  testWidgets('상단 바는 스크롤해도 화면 위에 고정되고 블러 배경을 가진다', (tester) async {
    useDesignScreen(tester);
    await pumpHome(tester);

    final bar = find.byType(HomeTopBar);
    expect(tester.getTopLeft(bar).dy, 0);
    expect(tester.getSize(bar).height, 62 + HomeLayout.headerHeight);
    expect(
      find.descendant(of: bar, matching: find.byType(BackdropFilter)),
      findsOneWidget,
    );
    final headerY = tester.getTopLeft(find.byType(HomeHeader)).dy;
    final recordCardY = tester.getTopLeft(find.byType(RecordCardBefore)).dy;

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.byType(HomeHeader)).dy, headerY);
    expect(tester.getTopLeft(bar).dy, 0);
    expect(
      tester.getTopLeft(find.byType(RecordCardBefore)).dy,
      closeTo(recordCardY - 200, 1),
    );
  });

  testWidgets('불러오는 동안은 배경만 보인다', (tester) async {
    useDesignScreen(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clockProvider.overrideWithValue(() => now),
          entriesRepositoryProvider.overrideWith((ref) => _SlowEntries()),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const TodayScreen()),
      ),
    );
    await tester.pump();

    expect(find.byType(RecordCardBefore), findsNothing);
    expect(find.text('불러오지 못했어요'), findsNothing);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.byType(RecordCardBefore), findsOneWidget);
  });

  testWidgets('실패하면 오류 문구와 "다시 시도"가 나오고, 누르면 다시 불러온다', (tester) async {
    useDesignScreen(tester);
    final calls = <int>[];
    await pumpHome(
      tester,
      overrides: [
        entriesRepositoryProvider.overrideWith((ref) => _FlakyEntries(calls)),
      ],
    );

    expect(find.text('불러오지 못했어요'), findsOneWidget);
    expect(calls.length, 1, reason: '자동 재시도 없음');

    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();

    expect(calls.length, 2);
    expect(find.byType(RecordCardBefore), findsOneWidget);
  });

  group('홈 After와 데이터 연결', () {
    Future<ProviderContainer> pumpApp(WidgetTester tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(402, 1400);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [clockProvider.overrideWithValue(() => now)],
          child: const RebornApp(),
        ),
      );
      await tester.pumpAndSettle();
      return ProviderScope.containerOf(tester.element(find.byType(MainShell)));
    }

    testWidgets('오늘 기록을 저장하면 홈이 After로 바뀌고 출석 체크가 계산된다', (tester) async {
      final container = await pumpApp(tester);
      expect(find.byType(RecordCardBefore), findsOneWidget);

      await container
          .read(analysisServiceProvider)
          .saveEntry(
            body: '오늘은 기분이 좋았다',
            emotion: Emotion.joy,
            intensity: 2,
            personId: 'p2',
            createdAt: now,
          );
      container.read(dataRevisionProvider.notifier).bump();
      await tester.pumpAndSettle();

      expect(find.byType(RecordCardBefore), findsNothing);
      expect(find.byType(RecordCardAfter), findsOneWidget);
      expect(
        tester.getSize(find.byType(RecordCardAfter)).height,
        HomeLayout.recordCardHeightAfter,
      );
      expect(
        find.text('오늘도 기록 완료!', findRichText: true, skipOffstage: false),
        findsNothing,
      );
      expect(
        find.textContaining('일 연속 마음을 기록하고 있어요', findRichText: true),
        findsOneWidget,
      );
      // 샘플은 최근 5일 연속 → 오늘 기록하면 6일, 최장 20일
      expect(find.textContaining('최장 기록 20일 · 6/20일'), findsOneWidget);
      Finder pills(String prefix) => find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith(prefix),
      );
      expect(pills('pill-filled'), findsNWidgets(6));
      expect(pills('pill-empty'), findsNothing);
      expect(find.text('오늘 기록 보기'), findsOneWidget);
    });

    testWidgets('"오늘 기록 보기"를 누르면 오늘 쓴 기록 상세가 열린다', (tester) async {
      final container = await pumpApp(tester);
      await container
          .read(analysisServiceProvider)
          .saveEntry(
            body: '오늘만의 특별한 기록',
            emotion: Emotion.joy,
            intensity: 1,
            createdAt: now,
          );
      container.read(dataRevisionProvider.notifier).bump();
      await tester.pumpAndSettle();

      await tester.tap(find.text('오늘 기록 보기'));
      await tester.pumpAndSettle();

      expect(find.text('오늘만의 특별한 기록'), findsOneWidget);
    });

    testWidgets('관계 신호 카드를 누르면 인사이트 상세로 이동한다', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('최근 부정적인 기록이 늘었어요').first);
      await tester.pumpAndSettle();

      expect(find.text('이렇게 해 보면 어떨까요?'), findsOneWidget);
    });

    testWidgets('제안 카드의 원을 누르면 체크리스트에 담기고 원이 채워진다 (T-26)', (tester) async {
      final container = await pumpApp(tester);
      // 샘플에는 첫 제안이 이미 체크리스트에 담겨 있다 → 두 번째 제안을 담는다.
      final cards = find.byType(ActionSuggestionCard);
      await tester.tap(
        find.descendant(
          of: cards.at(1),
          matching: find.byKey(const Key('suggestion-add')),
        ),
      );
      await tester.pumpAndSettle();

      final todos = await container.read(todosRepositoryProvider).list();
      expect(todos.where((t) => t.title.contains('거리를 두고')).length, 1);
      expect(find.text('체크리스트에 담았어요'), findsWidgets);
    });

    testWidgets('기록을 모두 지우면 홈은 안내 문구를 보여 준다', (tester) async {
      final container = await pumpApp(tester);
      await container.read(entriesRepositoryProvider).deleteAll();
      await container.read(insightsRepositoryProvider).deleteAll();
      container.read(dataRevisionProvider.notifier).bump();
      await tester.pumpAndSettle();

      expect(find.textContaining('아직 감지된 관계 변화가 없어요'), findsOneWidget);
      expect(find.textContaining('해 볼 만한 일을 제안해 드려요'), findsOneWidget);
      expect(find.textContaining('이번 주 기록이 쌓이면'), findsOneWidget);
      expect(tester.takeException(), isNull);
      // 탭 바는 그대로
      expect(find.byType(AppBottomNavBar), findsOneWidget);
    });
  });
}
