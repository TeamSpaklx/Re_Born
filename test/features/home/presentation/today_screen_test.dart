import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/app/app.dart';
import 'package:reborn_app/app/data_providers.dart';
import 'package:reborn_app/app/main_shell.dart';
import 'package:reborn_app/app/theme/app_assets.dart';
import 'package:reborn_app/app/theme/app_colors.dart';
import 'package:reborn_app/app/theme/app_motion.dart';
import 'package:reborn_app/core/errors/app_error_log.dart';
import 'package:reborn_app/app/theme/app_radii.dart';
import 'package:reborn_app/app/theme/app_spacing.dart';
import 'package:reborn_app/app/theme/app_theme.dart';
import 'package:reborn_app/core/providers/clock_provider.dart';
import 'package:reborn_app/features/entries/data/in_memory_entries_repository.dart';
import 'package:reborn_app/app/data_revision.dart';
import 'package:reborn_app/features/entries/models/emotion.dart';
import 'package:reborn_app/features/entries/models/entry.dart';
import 'package:reborn_app/features/entries/presentation/entries_providers.dart';
import 'package:reborn_app/features/analysis/data/sample_data.dart';
import 'package:reborn_app/features/notifications/presentation/notifications_providers.dart';
import 'package:reborn_app/features/home/models/greeting_pool.dart';
import 'package:reborn_app/features/home/presentation/today_screen.dart';
import 'package:reborn_app/features/todos/models/todo.dart';
import 'package:reborn_app/features/home/presentation/widgets/action_suggestion_card.dart';
import 'package:reborn_app/features/home/models/home_summary.dart';
import 'package:reborn_app/features/home/presentation/home_providers.dart';
import 'package:reborn_app/features/home/presentation/widgets/home_header.dart';
import 'package:reborn_app/features/home/presentation/widgets/home_skeleton.dart';
import 'package:reborn_app/shared/widgets/skeleton.dart';
import 'package:reborn_app/features/home/presentation/widgets/home_top_bar.dart';
import 'package:reborn_app/features/home/presentation/widgets/record_card_after.dart';
import 'package:reborn_app/features/home/presentation/widgets/record_card_before.dart';
import 'package:reborn_app/features/home/presentation/widgets/weekly_emotion_card.dart';
import 'package:reborn_app/shared/widgets/app_bottom_nav_bar.dart';
import 'package:reborn_app/shared/widgets/centered_line.dart';

import '../../../helpers/load_fonts.dart';

/// 처음에는 실패하고 다시 부르면 성공하는 기록 저장소 (홈 오류·재시도 확인).
class _FlakyEntries extends InMemoryEntriesRepository {
  _FlakyEntries(this.calls);

  final List<int> calls;

  @override
  Future<List<Entry>> list() async {
    calls.add(1);
    if (calls.length == 1) throw StateError('network');
    return super.list();
  }
}

/// 기록 목록 호출 수를 세고, [failFrom]번째 호출부터 실패하는 저장소 (새로고침 확인).
class _CountingEntries extends InMemoryEntriesRepository {
  _CountingEntries({this.failFrom});

  final int? failFrom;
  int calls = 0;

  @override
  Future<List<Entry>> list() async {
    calls++;
    if (failFrom != null && calls >= failFrom!) throw StateError('network');
    return super.list();
  }
}

/// 불러오는 데 1초 걸리는 기록 저장소 (로딩 상태 확인).
class _SlowEntries extends InMemoryEntriesRepository {
  @override
  Future<List<Entry>> list() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return super.list();
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
        overrides: [
          clockProvider.overrideWithValue(() => now),
          greetingIndexProvider.overrideWithValue(0),
          ...overrides,
        ],
        child: MaterialApp(theme: AppTheme.light, home: const TodayScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// 샘플에서 가장 최근 일기(홈 제안의 출처)와 그 AI 제안.
  Entry latestEntry() => (buildSampleData(
    now,
  ).entries.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt))).first;
  List<String> latestSuggestions() => latestEntry().feedback!.suggestions;

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
      '이번 주 감정 흐름',
      '✦ 10월',
      '오늘 해볼까요?',
      latestSuggestions()[0],
      latestSuggestions()[1],
    ]) {
      expect(find.text(text), findsWidgets, reason: text);
    }
    expect(find.text('최근 관계 신호'), findsNothing, reason: '인물 기능은 없앴다');
    expect(find.byType(RecordCardAfter), findsNothing);
    expect(find.textContaining('긍정적인 감정이', findRichText: true), findsOneWidget);
  });

  testWidgets('402×874에서 위쪽은 Figma 좌표와 같고, 아래는 정한 간격으로 이어진다', (tester) async {
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
    // 관계 신호 섹션을 빼서(2026-11-28) 그래프부터는 Figma보다 위로 당겨졌다.
    const graphY =
        HomeLayout.recordCardY +
        HomeLayout.recordCardHeightBefore +
        HomeLayout.recordCardToGraph;
    expectY('그래프 카드', find.byType(WeeklyEmotionCard), graphY);
    const shift = HomeLayout.graphCardY - graphY;
    expectY(
      '오늘 해볼까요 제목',
      find.text('오늘 해볼까요?'),
      HomeLayout.actionTitleY - shift,
    );
    final actions = find.byType(ActionSuggestionCard);
    expect(actions, findsNWidgets(2));
    expectY('액션 카드 1', actions.at(0), HomeLayout.actionCardY1 - shift);
    expectY('액션 카드 2', actions.at(1), HomeLayout.actionCardY2 - shift);
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
          d.color == AppColors.light.barStrong &&
          d.borderRadius == AppRadii.graphBarBorderRadius;
    });
    // (평균+5)/10: 월(무표정 강도1 → 0 → 0.5), 화(불안 강도4 → −4 → 0.1), 수(슬픔 강도3 → −3 → 0.2)
    expect(bars, findsNWidgets(3));
    const expected = [0.5, 0.1, 0.2];
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
    // 최신 안에는 그래프 위 이모지가 없다(데이터의 peakEmoji는 있지만 화면에 그리지 않는다).
    expect(find.text('🙂'), findsNothing);
    expect(find.text('😁'), findsNothing);
    // 격자선은 막대가 서는 바닥선 하나만 보인다(위쪽 3개는 Figma에서 숨김).
    final lines = find.descendant(
      of: find.byType(WeeklyEmotionCard),
      matching: find.byWidgetPredicate(
        (w) => w is ColoredBox && w.color == AppColors.light.gridLine,
      ),
    );
    expect(lines, findsOneWidget);
    final card = tester.getTopLeft(find.byType(WeeklyEmotionCard));
    expect(
      tester.getTopLeft(lines).dy - card.dy,
      closeTo(GraphLayout.baselineY + 2, 0.5), // 투명 테두리 2px 안쪽 기준 → 바깥 기준 126
    );
  });

  test('막대 색은 값이 낮을수록 진하고 높을수록 연하다 (Figma 수정안 샘플 막대 기준)', () {
    const c = AppColors.light;
    // 샘플 막대 높이/최대(75.806): 월 9 → 0.12, 화 21 → 0.28, 목 36 → 0.47 (진함)
    for (final v in [0.12, 0.28, 0.47, 0.5]) {
      expect(WeeklyEmotionCard.barColor(v, c), c.barStrong, reason: '$v');
    }
    // 수 48 → 0.63, 토 66 → 0.87 (중간)
    for (final v in [0.63, 0.87, 0.9]) {
      expect(WeeklyEmotionCard.barColor(v, c), c.barMid, reason: '$v');
    }
    // 금 75.8 → 1.0 (연함)
    expect(WeeklyEmotionCard.barColor(1.0, c), c.barLight);
  });

  testWidgets('화면 배경은 #F2F2F4이고 상단에 핑크 그라디언트가 없다', (tester) async {
    useDesignScreen(tester);
    await pumpHome(tester);

    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      const Color(0xFFF2F2F4),
    );
    expect(
      find.descendant(
        of: find.byType(HomeTopBar),
        matching: find.byWidgetPredicate(
          (w) =>
              w is DecoratedBox &&
              w.decoration is BoxDecoration &&
              (w.decoration as BoxDecoration).gradient != null,
        ),
      ),
      findsNothing,
    );
  });

  testWidgets('기록 카드(Before)는 흰색 + 테두리 1px, 글자는 왼쪽 정렬, 버튼은 연한 핑크 + 검정 글자', (
    tester,
  ) async {
    useDesignScreen(tester);
    await pumpHome(tester);

    final card = find.descendant(
      of: find.byType(RecordCardBefore),
      matching: find.byType(Container),
    );
    final container = tester.widget<Container>(card.first);
    final fill = container.decoration! as BoxDecoration;
    expect(fill.color, AppColors.light.cardWhite);
    final outline = container.foregroundDecoration! as BoxDecoration;
    expect(
      outline.border,
      Border.all(color: AppColors.light.cardBorder, width: 1),
    );

    // 제목·부제는 테두리 1px 안쪽 왼쪽(20) → 바깥 기준 21에서 시작한다.
    final cardLeft = tester.getTopLeft(find.byType(RecordCardBefore)).dx;
    expect(
      tester.getTopLeft(find.text('아직 오늘의 마음을 기록하지 않았어요')).dx - cardLeft,
      closeTo(21, 0.5),
    );
    expect(
      tester.getTopLeft(find.text('1분만 천천히 돌아볼까요?')).dx - cardLeft,
      closeTo(21, 0.5),
    );

    final button = find.ancestor(
      of: find.text('감정 기록하기'),
      matching: find.byType(Container),
    );
    final buttonFill =
        tester.widget<Container>(button.first).decoration! as BoxDecoration;
    expect(buttonFill.color, AppColors.light.ctaSoft);
    final label = tester.widget<Text>(find.text('감정 기록하기'));
    expect(label.style!.color, AppColors.light.onCtaSoft);
    expect(label.style!.fontSize, 16);
  });

  testWidgets('기록 카드(Before)에는 버튼 뒤로 얼굴만 내민 여우원숭이가 있다 (151×98, 위쪽만 보임)', (
    tester,
  ) async {
    useDesignScreen(tester);
    await pumpHome(tester);

    final card = tester.getRect(find.byType(RecordCardBefore));
    final mascot = find.byWidgetPredicate(
      (w) =>
          w is Image &&
          w.image is AssetImage &&
          (w.image as AssetImage).assetName == AppAssets.mascotLemur,
    );
    expect(mascot, findsOneWidget);
    // 보이는 영역은 151×98, 이미지 자체는 정사각(높이 ≈151)이라 아래가 잘린다.
    final visible = tester.getRect(
      find.ancestor(of: mascot, matching: find.byType(ClipRect)).first,
    );
    expect(visible.size, const Size(151, 98));
    expect(
      tester.getSize(mascot),
      const Size(HomeLayout.mascotWidth, HomeLayout.mascotImageHeight),
    );
    // 카드 위에서 96, 가로 가운데, 버튼은 그 바로 아래(194)에서 시작한다.
    expect(visible.top - card.top, closeTo(96, 0.5));
    expect(visible.center.dx, closeTo(card.center.dx, 0.5));
    final button = tester.getRect(
      find
          .ancestor(of: find.text('감정 기록하기'), matching: find.byType(Container))
          .first,
    );
    expect(button.top - card.top, closeTo(194, 0.5));
    expect(button.height, 52);
    expect(button.left - card.left, closeTo(21, 0.5));
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
    // 내용 높이 1288(Figma 최신 프레임) − 화면 874에서, 없앤 관계 신호 묶음 170
    // (제목 32 + 간격 12 + 카드 104 + 간격 22)만큼 짧아졌다.
    const removedSignalSection = 32 + 12 + 104 + 22;
    expect(
      scrollable.position.maxScrollExtent,
      closeTo(1288 - 874 - removedSignalSection, 1),
    );
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

    // 글자 위(눌리는 위젯이 없는 곳)에서 끈다. 버튼 위에서 끌면 탭 인식기 때문에 시작 거리가 달라진다.
    // 투데이는 튀는 스크롤이라 끌기 시작 문턱(touch slop) 없이 정확히 200만큼 끈다.
    await tester.dragFrom(
      const Offset(300, 180),
      const Offset(0, -200),
      touchSlopY: 0,
    );
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.byType(HomeHeader)).dy, headerY);
    expect(tester.getTopLeft(bar).dy, 0);
    expect(
      tester.getTopLeft(find.byType(RecordCardBefore)).dy,
      closeTo(recordCardY - 200, 1),
    );
  });

  testWidgets('로고를 누르면 맨 위로 부드럽게 올라간다', (tester) async {
    useDesignScreen(tester);
    await pumpHome(tester);

    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
    await tester.dragFrom(
      const Offset(300, 180),
      const Offset(0, -200),
      touchSlopY: 0,
    );
    await tester.pumpAndSettle();
    expect(scrollable.position.pixels, closeTo(200, 1));

    await tester.tap(find.bySemanticsLabel('맨 위로 이동'));
    await tester.pump(); // 애니메이션 시작 프레임
    // 애니메이션 도중에는 아직 위로 올라가는 중이다.
    await tester.pump(HomeLayout.scrollToTopDuration ~/ 2);
    expect(scrollable.position.pixels, inExclusiveRange(0, 200));

    await tester.pumpAndSettle();
    expect(scrollable.position.pixels, 0);
  });

  group('당겨서 새로고침', () {
    /// 화면을 아래로 당겼다 놓는다(트리거 거리 100보다 충분히).
    Future<void> pullDown(WidgetTester tester) async {
      await tester.dragFrom(
        const Offset(300, 300),
        const Offset(0, 250),
        touchSlopY: 0,
      );
      await tester.pump();
    }

    testWidgets('당기면 상단 바 아래에 스피너가 돌고 홈 데이터를 다시 불러온다', (tester) async {
      useDesignScreen(tester);
      final entries = _CountingEntries();
      await pumpHome(
        tester,
        overrides: [entriesRepositoryProvider.overrideWithValue(entries)],
      );
      final before = entries.calls;

      await pullDown(tester);
      await tester.pump(const Duration(milliseconds: 50));

      final spinner = find.byType(CupertinoActivityIndicator);
      expect(spinner, findsOneWidget);
      final barBottom = tester.getBottomLeft(find.byType(HomeTopBar)).dy;
      expect(tester.getTopLeft(spinner).dy, greaterThan(barBottom));
      expect(entries.calls, before + 1);
      // 새로고침 중에도 내용은 그대로 보인다.
      expect(find.byType(RecordCardBefore), findsOneWidget);
      expect(find.byType(HomeSkeleton), findsNothing);

      // 데이터는 즉시 오지만 스피너는 최소 시간만큼 보인다.
      await tester.pump(AppMotion.refreshMinDuration ~/ 2);
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoActivityIndicator), findsNothing);
      expect(
        tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels,
        0,
      );
    });

    testWidgets('새로고침이 실패하면 내용을 유지하고 토스트로 알리며 오류를 기록한다', (tester) async {
      useDesignScreen(tester);
      final errorLog = AppErrorLog();
      await pumpHome(
        tester,
        overrides: [
          entriesRepositoryProvider.overrideWithValue(
            _CountingEntries(failFrom: 2),
          ),
          appErrorLogProvider.overrideWithValue(errorLog),
        ],
      );

      await pullDown(tester);
      await tester.pump(AppMotion.refreshMinDuration);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('새로고침하지 못했어요'), findsOneWidget);
      expect(find.byType(RecordCardBefore), findsOneWidget);
      expect(find.text('다시 시도'), findsNothing);
      expect(errorLog.entries.single.where, 'home-refresh');
      await tester.pumpAndSettle(const Duration(seconds: 4));
    });
  });

  testWidgets('이미 맨 위일 때 로고를 눌러도 오류가 없다', (tester) async {
    useDesignScreen(tester);
    await pumpHome(tester);

    await tester.tap(find.bySemanticsLabel('맨 위로 이동'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels,
      0,
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

  testWidgets('불러오는 동안 Figma 스켈레톤(834:2351)을 깜빡이며 보여 준다', (tester) async {
    useDesignScreen(tester);
    final gate = Completer<HomeSummary>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clockProvider.overrideWithValue(() => now),
          greetingIndexProvider.overrideWithValue(0),
          homeSummaryProvider.overrideWith((ref) => gate.future),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const TodayScreen()),
      ),
    );
    await tester.pump();
    expect(find.byType(HomeSkeleton), findsOneWidget);
    expect(find.byType(HomeTopBar), findsOneWidget, reason: '로고·알림은 그대로');
    expect(find.byType(SkeletonBox), findsWidgets);
    // 기록 카드 자리는 Figma와 같은 y(237)에서 시작한다.
    final card = find.byType(SkeletonCard).first;
    expect(tester.getTopLeft(card).dy, closeTo(HomeLayout.recordCardY, 0.5));

    // 깜빡임은 계속 반복된다(불투명도가 바뀐다).
    Color barColor() =>
        ((tester.widget<DecoratedBox>(
                  find
                      .descendant(
                        of: find.byType(SkeletonBox).first,
                        matching: find.byType(DecoratedBox),
                      )
                      .first,
                )).decoration
                as BoxDecoration)
            .color!;
    final first = barColor();
    await tester.pump(ComponentLayout.skeletonPulse);
    expect(barColor(), isNot(first));

    // 끝나지 않은 로딩을 정리한다(내용으로 바뀌는 흐름은 위 테스트들이 확인).
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('실패하면 오류 문구와 "다시 시도"가 나오고, 누르면 다시 불러온다', (tester) async {
    useDesignScreen(tester);
    final calls = <int>[];
    await pumpHome(
      tester,
      overrides: [
        entriesRepositoryProvider.overrideWith((ref) => _FlakyEntries(calls)),
        // 벨 뱃지도 일기를 읽으므로, 홈 데이터 호출만 세도록 알림은 비워 둔다.
        notificationsProvider.overrideWith((ref) async => const []),
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
          overrides: [
            clockProvider.overrideWithValue(() => now),
            greetingIndexProvider.overrideWithValue(0),
          ],
          child: const RebornApp(),
        ),
      );
      await tester.pumpAndSettle();
      return ProviderScope.containerOf(tester.element(find.byType(MainShell)));
    }

    testWidgets('Android 첫 프레임처럼 화면 너비가 0이면 탭 바를 그리지 않는다', (tester) async {
      await pumpApp(tester);
      tester.view.physicalSize = const Size(0, 1400);
      await tester.pump();

      expect(find.byType(AppBottomNavBar), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('오늘 기록을 저장하면 홈이 After로 바뀌고 출석 체크가 계산된다', (tester) async {
      final container = await pumpApp(tester);
      expect(find.byType(RecordCardBefore), findsOneWidget);

      await container
          .read(analysisServiceProvider)
          .saveEntry(
            body: '오늘은 기분이 좋았다',
            emotion: Emotion.joy,
            intensity: 2,
            createdAt: now,
          );
      container.read(dataRevisionProvider.notifier).bump();
      await tester.pumpAndSettle();

      expect(find.byType(RecordCardBefore), findsNothing);
      expect(find.byType(RecordCardAfter), findsOneWidget);
      if (HomeLayout.showAttendance) {
        expect(
          tester.getSize(find.byType(RecordCardAfter)).height,
          HomeLayout.recordCardHeightAfter,
        );
      }
      expect(
        find.text('오늘도 기록 완료!', findRichText: true, skipOffstage: false),
        findsNothing,
      );
      expect(
        find.textContaining('일 연속 마음을 기록하고 있어요', findRichText: true),
        findsOneWidget,
      );
      // 샘플은 최근 5일 연속 → 오늘 기록하면 6일(문구). 출석 패널은 지금 숨겨져 있다.
      expect(find.textContaining('6'), findsWidgets);
      expect(
        find.text('출석 체크'),
        HomeLayout.showAttendance ? findsOneWidget : findsNothing,
      );
      expect(
        find.textContaining('최장 기록'),
        HomeLayout.showAttendance ? findsOneWidget : findsNothing,
      );
      expect(find.text('오늘 기록 보기'), findsOneWidget);
    });

    testWidgets('"오늘 기록 보기"를 누르면 오늘 쓴 기록 상세가 열린다', (tester) async {
      final container = await pumpApp(tester);
      await container
          .read(recordActionsProvider)
          .save(body: '오늘만의 특별한 기록', emotion: Emotion.joy, intensity: 1);
      await tester.pump(const Duration(seconds: 1)); // AI 코멘트 도착
      await tester.pumpAndSettle();

      await tester.tap(find.text('오늘 기록 보기'));
      await tester.pumpAndSettle();

      expect(find.text('오늘만의 특별한 기록'), findsOneWidget);
    });

    testWidgets('오늘 기록의 AI 코멘트가 도착하면 기록 완료 카드에 보인다', (tester) async {
      final container = await pumpApp(tester);
      final saved = await container
          .read(recordActionsProvider)
          .save(body: '과제가 많아 지쳤다', emotion: Emotion.sadness, intensity: 3);
      await tester.pumpAndSettle();
      expect(find.textContaining('코멘트를 쓰고 있어요'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1)); // AI 코멘트 도착
      await tester.pumpAndSettle();

      final stored = await container
          .read(entriesRepositoryProvider)
          .get(saved.id);
      expect(stored!.feedback, isNotNull);
      final bubble = find.byKey(const Key('home-ai-comment'));
      expect(bubble, findsOneWidget);
      expect(
        find.descendant(
          of: bubble,
          matching: find.text(stored.feedback!.comment),
        ),
        findsOneWidget,
      );
      // 오늘 일기의 제안이 "오늘 해볼까요?"에 나온다.
      expect(find.text(stored.feedback!.suggestions.first), findsOneWidget);
    });

    testWidgets('제안 카드를 누르면 그 제안이 나온 일기 상세가 열린다', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text(latestSuggestions()[0]));
      await tester.pumpAndSettle();
      expect(find.text('AI 코멘트'), findsOneWidget);
      expect(find.text(latestEntry().body), findsOneWidget);
    });

    testWidgets('제안 카드의 원을 누르면 담기고, 채워진 뒤 다음 제안이 그 자리로 온다 (T-26)', (
      tester,
    ) async {
      final container = await pumpApp(tester);
      final pool = latestSuggestions();
      expect(find.text(pool[0]), findsOneWidget);
      expect(find.text(pool[1]), findsOneWidget);
      expect(find.text(pool[2]), findsNothing);

      await tester.tap(
        find.descendant(
          of: find.byType(ActionSuggestionCard).first,
          matching: find.byKey(const Key('suggestion-add')),
        ),
      );
      await tester.pump();
      await tester.pump(ComponentLayout.toastFade);

      final todos = await container.read(todosRepositoryProvider).list();
      final added = todos.where((t) => t.title == pool[0]).toList();
      expect(added, hasLength(1));
      expect(added.single.entryId, latestEntry().id);
      expect(find.text('체크리스트에 담았어요'), findsWidgets);
      // 채워진 원이 잠깐 보인다.
      expect(find.bySemanticsLabel('체크리스트에 담았어요'), findsWidgets);

      await tester.pump(HomeLayout.suggestionSwapDelay);
      await tester.pump(const Duration(seconds: 4)); // 토스트가 사라질 때까지
      await tester.pumpAndSettle();
      expect(find.text(pool[0]), findsNothing, reason: '담은 제안은 빠진다');
      expect(find.text(pool[1]), findsOneWidget);
      expect(find.text(pool[2]), findsOneWidget, reason: '다음 제안이 채워진다');
    });

    testWidgets('제안을 모두 담으면 안내와 체크리스트 버튼이 나온다', (tester) async {
      final container = await pumpApp(tester);
      for (final title in latestSuggestions()) {
        await container
            .read(todosRepositoryProvider)
            .create(
              title: title,
              createdAt: now,
              source: TodoSource.suggestion,
              entryId: latestEntry().id,
            );
      }
      container.read(dataRevisionProvider.notifier).bump();
      await tester.pumpAndSettle();

      expect(find.byType(ActionSuggestionCard), findsNothing);
      expect(find.text('오늘 제안을 모두 담았어요'), findsOneWidget);

      await tester.tap(find.text('체크리스트 보기'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('todo-title')), findsOneWidget);
    });

    testWidgets('"오늘 해볼까요? >"는 기록 탭 체크리스트로, "이번 주 감정 흐름 >"는 기록 탭 달력으로 간다', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.tap(find.bySemanticsLabel('오늘 해볼까요?'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('todo-title')), findsOneWidget);
      expect(find.text('2026년 10월'), findsNothing);
    });

    testWidgets('기록을 모두 지우면 홈은 안내 문구를 보여 준다', (tester) async {
      final container = await pumpApp(tester);
      await container.read(entriesRepositoryProvider).deleteAll();
      container.read(dataRevisionProvider.notifier).bump();
      await tester.pumpAndSettle();

      expect(find.textContaining('해 볼 만한 일을 제안해 드려요'), findsOneWidget);
      expect(find.textContaining('이번 주 기록이 쌓이면'), findsOneWidget);
      expect(tester.takeException(), isNull);
      // 탭 바는 그대로
      expect(find.byType(AppBottomNavBar), findsOneWidget);
    });
  });
}
