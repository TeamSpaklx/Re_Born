import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/app/app.dart';
import 'package:reborn_app/core/providers/clock_provider.dart';
import 'package:reborn_app/features/analysis/data/sample_data.dart';
import 'package:reborn_app/features/analysis/emotion_stats_builder.dart';
import 'package:reborn_app/features/entries/models/intensity_level.dart';
import 'package:reborn_app/shared/widgets/app_bottom_nav_bar.dart';

final fixedNow = DateTime(2026, 10, 22, 12);

void main() {
  final sample = buildSampleData(fixedNow).entries;

  group('감정 수치 통계 (순수 함수)', () {
    test('1주: 기간 안 일기만 세고, 날짜별 평균 점수를 오름차순으로', () {
      final stats = buildEmotionStats(sample, fixedNow, StatsPeriod.week);
      // 샘플 최근 일주일: 1·2·3·4·5일 전.
      expect(stats.entryCount, 5);
      expect(stats.daily.map((d) => d.date.day), [17, 18, 19, 20, 21]);
      expect(stats.daily.last.average, -3, reason: '어제: 슬픔 강도 3');
      expect(
        stats.levelCounts.keys,
        IntensityLevel.values,
        reason: '1~5단계가 모두 들어 있다',
      );
      expect(stats.levelCounts.values.reduce((a, b) => a + b), 5);
      expect(stats.recentFeedback, hasLength(5));
      expect(stats.recentFeedback.first.createdAt.day, 21, reason: '최근 것부터');
    });

    test('1달은 더 많은 일기를 포함한다', () {
      final week = buildEmotionStats(sample, fixedNow, StatsPeriod.week);
      final month = buildEmotionStats(sample, fixedNow, StatsPeriod.month);
      expect(month.entryCount, greaterThan(week.entryCount));
    });

    test('일기가 없으면 평균은 null', () {
      final stats = buildEmotionStats(const [], fixedNow, StatsPeriod.week);
      expect(stats.entryCount, 0);
      expect(stats.averageScore, isNull);
    });
  });

  testWidgets('분석 탭: 감정 수치 그래프·강도 분포·최근 AI 코멘트가 보이고 기간을 바꿀 수 있다', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(402, 2000);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [clockProvider.overrideWithValue(() => fixedNow)],
        child: const RebornApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AppBottomNavBar),
        matching: find.text('분석'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('emotion-score-chart')), findsOneWidget);
    expect(find.textContaining('일기 5개'), findsOneWidget);
    expect(find.byKey(const Key('intensity-distribution')), findsOneWidget);
    for (final l in IntensityLevel.values) {
      expect(find.text('${l.value} ${l.label}'), findsOneWidget);
    }
    expect(find.text('최근 AI 코멘트'), findsOneWidget);
    // 막대는 가장 많은 단계 대비 비율만큼 실제로 채워진다(높이 10).
    final bars = IntensityLevel.values
        .map((l) => find.byKey(Key('level-bar-${l.value}')))
        .where((f) => f.evaluate().isNotEmpty);
    expect(bars, isNotEmpty);
    for (final bar in bars) {
      expect(tester.getSize(bar).height, 10);
    }
    expect(bars.any((b) => tester.getSize(b).width > 0), isTrue);

    await tester.tap(find.text('1달'));
    await tester.pumpAndSettle();
    final month = buildEmotionStats(sample, fixedNow, StatsPeriod.month);
    expect(find.textContaining('일기 ${month.entryCount}개'), findsOneWidget);
  });
}
