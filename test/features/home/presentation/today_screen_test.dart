import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/app/theme/app_colors.dart';
import 'package:reborn_app/app/theme/app_radii.dart';
import 'package:reborn_app/app/theme/app_spacing.dart';
import 'package:reborn_app/app/theme/app_theme.dart';
import 'package:reborn_app/features/home/data/fake_home_repository.dart';
import 'package:reborn_app/shared/widgets/centered_line.dart';
import 'package:reborn_app/features/home/data/home_repository.dart';
import 'package:reborn_app/features/home/models/home_summary.dart';
import 'package:reborn_app/features/home/presentation/home_providers.dart';
import 'package:reborn_app/features/home/presentation/today_screen.dart';
import 'package:reborn_app/features/home/presentation/widgets/action_suggestion_card.dart';
import 'package:reborn_app/features/home/presentation/widgets/home_header.dart';
import 'package:reborn_app/features/home/presentation/widgets/home_top_bar.dart';
import 'package:reborn_app/features/home/presentation/widgets/record_card_before.dart';
import 'package:reborn_app/features/home/presentation/widgets/relation_signal_card.dart';
import 'package:reborn_app/features/home/presentation/widgets/weekly_emotion_card.dart';

/// 처음에는 실패하고 다시 부르면 성공하는 저장소.
class _FlakyRepository implements HomeRepository {
  int calls = 0;

  @override
  Future<HomeSummary> fetchHome(DateTime today) async {
    calls++;
    if (calls == 1) throw StateError('network');
    return const FakeHomeRepository().fetchHome(today);
  }
}

void main() {
  final today = DateTime(2018, 9, 13); // 목요일

  /// 디자인 기준 화면(402×874, 상태바 영역 62)으로 맞춘다.
  void useDesignScreen(WidgetTester tester, {double width = 402}) {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, 874);
    tester.view.padding = const FakeViewPadding(top: 62);
    addTearDown(tester.view.reset);
  }

  Future<void> pumpHome(
    WidgetTester tester, {
    HomeRepository repository = const FakeHomeRepository(),
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeRepositoryProvider.overrideWithValue(repository),
          todayProvider.overrideWithValue(today),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const TodayScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  double top(WidgetTester tester, Finder finder) =>
      tester.getTopLeft(finder).dy;

  testWidgets('Figma 샘플 글자가 보인다', (tester) async {
    useDesignScreen(tester);
    await pumpHome(tester);

    for (final text in [
      '9월 13일 목요일',
      '규리님, 오늘도 즐거운\n하루 보내세요!',
      '아직 오늘의 마음을 기록하지 않았어요',
      '1분만 천천히 돌아볼까요?',
      '감정 기록하기',
      '최근 관계 신호',
      '전체 보기',
      '지민',
      '친구',
      '최근 대화가 조금 줄었어요',
      '마지막 기록 5일 전',
      '이번 주 감정 흐름',
      '✦ 9월',
      '😁',
      '오늘 해볼까요?',
      '지민님에게 가볍게 안부 묻기',
      '승현님에게 가볍게 안부 묻기',
    ]) {
      expect(find.text(text), findsWidgets, reason: text);
    }
    expect(find.textContaining('조금씩 증가', findRichText: true), findsOneWidget);
  });

  testWidgets('402×874에서 각 요소의 y가 Figma 좌표와 ±1px 안에서 같다', (tester) async {
    useDesignScreen(tester);
    await pumpHome(tester);

    void expectY(String name, Finder finder, double y) =>
        expect(top(tester, finder), closeTo(y, 1), reason: name);

    expectY(
      '날짜',
      find.ancestor(
        of: find.text('9월 13일 목요일'),
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

  testWidgets('막대 6개: 높이 = 값 × 75.806, 일요일은 막대 없음', (tester) async {
    useDesignScreen(tester);
    await pumpHome(tester);

    final bars = find.byWidgetPredicate((w) {
      if (w is! DecoratedBox) return false;
      final d = w.decoration;
      return d is BoxDecoration &&
          d.color == AppColors.light.brand &&
          d.borderRadius == AppRadii.graphBarBorderRadius;
    });
    expect(bars, findsNWidgets(6));

    const expected = [9.0, 21.0, 48.0, 36.0, 75.806, 66.0];
    for (var i = 0; i < 6; i++) {
      expect(
        tester.getSize(bars.at(i)).height,
        closeTo(expected[i], 0.01),
        reason: 'bar $i',
      );
      expect(tester.getSize(bars.at(i)).width, closeTo(27.437, 0.01));
    }
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
      reason: '내용은 스크롤된다',
    );
  });

  testWidgets('불러오는 동안은 배경만 보인다', (tester) async {
    useDesignScreen(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeRepositoryProvider.overrideWithValue(
            const FakeHomeRepository(latency: Duration(seconds: 1)),
          ),
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
    final repository = _FlakyRepository();
    await pumpHome(tester, repository: repository);

    expect(find.text('불러오지 못했어요'), findsOneWidget);
    expect(repository.calls, 1, reason: '자동 재시도 없음');

    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();

    expect(repository.calls, 2);
    expect(find.byType(RecordCardBefore), findsOneWidget);
  });
}
