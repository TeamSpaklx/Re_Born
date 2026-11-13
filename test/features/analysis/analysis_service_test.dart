import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/features/analysis/analysis_service.dart';
import 'package:reborn_app/features/analysis/data/sample_data.dart';
import 'package:reborn_app/features/analysis/record_streak_calculator.dart';
import 'package:reborn_app/features/entries/data/in_memory_entries_repository.dart';
import 'package:reborn_app/features/entries/models/emotion.dart';
import 'package:reborn_app/features/entries/models/entry.dart';
import 'package:reborn_app/features/insights/data/in_memory_insights_repository.dart';
import 'package:reborn_app/features/insights/models/insight.dart';
import 'package:reborn_app/features/people/data/in_memory_people_repository.dart';
import 'package:reborn_app/features/people/models/person.dart';
import 'package:reborn_app/features/people/models/relation_type.dart';

/// update에서 실패하는 기록 저장소 (T-20: 분석 실패 시 기록은 남고 failed).
class _FailingOnDoneEntries extends InMemoryEntriesRepository {
  @override
  Future<void> update(Entry entry) async {
    if (entry.analysisStatus == AnalysisStatus.pending &&
        entry.analysis != null) {
      throw StateError('저장 실패');
    }
    return super.update(entry);
  }
}

void main() {
  final now = DateTime(2026, 10, 22, 12);
  final person = Person(
    id: 'p1',
    name: '하은',
    relationType: RelationType.friend,
    createdAt: DateTime(2026, 9),
  );

  AnalysisService build({
    InMemoryEntriesRepository? entries,
    InMemoryInsightsRepository? insights,
    InMemoryIndexHistoryRepository? history,
  }) => AnalysisService(
    entries: entries ?? InMemoryEntriesRepository(),
    people: InMemoryPeopleRepository(initial: [person]),
    indexHistory: history ?? InMemoryIndexHistoryRepository(),
    insights: insights ?? InMemoryInsightsRepository(),
    clock: () => now,
  );

  test('T-10: 기록 저장 → 분석 done, 점수 −2, 키워드가 붙는다', () async {
    final entries = InMemoryEntriesRepository();
    final service = build(entries: entries);

    final saved = await service.saveEntry(
      body: '하은이가 고맙다는 말이 없어 서운했다',
      emotion: Emotion.sadness,
      intensity: 2,
      personId: person.id,
    );

    expect(saved.analysisStatus, AnalysisStatus.done);
    expect(saved.score, -2);
    expect(saved.analysis!.keywords, contains('서운'));
    expect((await entries.list()).single.id, saved.id);
  });

  test('T-23: 기록 3건 미만이면 지수를 저장하지 않는다(데이터 부족)', () async {
    final history = InMemoryIndexHistoryRepository();
    final service = build(history: history);
    for (var i = 0; i < 2; i++) {
      await service.saveEntry(
        body: '본문',
        emotion: Emotion.joy,
        intensity: 2,
        personId: person.id,
        createdAt: DateTime(2026, 10, 22 - i, 9),
      );
    }
    expect(await history.list(person.id), isEmpty);
  });

  test('T-14: 기록 3건 이상이면 오늘 지수가 저장되고, 삭제하면 다시 계산된다', () async {
    final history = InMemoryIndexHistoryRepository();
    final entries = InMemoryEntriesRepository();
    final service = build(entries: entries, history: history);
    final saved = <Entry>[];
    for (var i = 0; i < 4; i++) {
      saved.add(
        await service.saveEntry(
          body: '본문',
          emotion: i == 3 ? Emotion.anger : Emotion.joy,
          intensity: 3,
          personId: person.id,
          createdAt: DateTime(2026, 10, 22 - i, 9),
        ),
      );
    }
    final before = (await history.list(person.id)).single;

    await service.deleteEntry(saved[3].id); // 분노(−3) 기록 삭제

    final after = (await history.list(person.id)).single;
    expect(after.index, greaterThan(before.index));
    expect(after.entryCount, 3);
  });

  test('T-20: 분석 중 저장이 실패해도 기록은 남고 failed로 표시된다', () async {
    final entries = _FailingOnDoneEntries();
    final service = build(entries: entries);

    final result = await service.saveEntry(
      body: '본문',
      emotion: Emotion.joy,
      intensity: 1,
      personId: person.id,
    );

    expect(result.analysisStatus, AnalysisStatus.failed);
    expect((await entries.list()).single.analysisStatus, AnalysisStatus.failed);
  });

  test('수정: 인물을 옮기면 이전 인물의 지수도 다시 계산한다', () async {
    final entries = InMemoryEntriesRepository();
    final history = InMemoryIndexHistoryRepository();
    final service = AnalysisService(
      entries: entries,
      people: InMemoryPeopleRepository(
        initial: [
          person,
          Person(
            id: 'p2',
            name: '지민',
            relationType: RelationType.friend,
            createdAt: DateTime(2026, 9),
          ),
        ],
      ),
      indexHistory: history,
      insights: InMemoryInsightsRepository(),
      clock: () => now,
    );
    Entry? last;
    for (var i = 0; i < 3; i++) {
      last = await service.saveEntry(
        body: '본문',
        emotion: Emotion.joy,
        intensity: 2,
        personId: 'p1',
        createdAt: DateTime(2026, 10, 22 - i, 9),
      );
    }
    expect(await history.list('p1'), isNotEmpty);

    await service.updateEntry(last!.copyWith(personId: 'p2'));

    expect(await history.list('p1'), isEmpty, reason: '2건만 남아 데이터 부족');
  });

  group('샘플 데이터 (Figma 홈 샘플과 같은 모양)', () {
    final data = buildSampleData(now);

    test('오늘은 기록이 없고, 최근 5일 연속·최장 20일', () {
      final streak = calculateRecordStreak(
        data.entries.map((e) => e.createdAt),
        now,
      );
      expect(
        data.entries.any(
          (e) => e.createdAt.day == now.day && e.createdAt.month == now.month,
        ),
        isFalse,
      );
      expect(streak.current, 5);
      expect(streak.longest, 20);
    });

    test('지민과의 부정 추세 인사이트가 하나 있고 홈 문구가 계산값 기반이다', () {
      final insight = data.insights.single;
      expect(insight.personId, 'p1');
      expect(insight.type, InsightType.negativeTrend);
      expect(insight.evidence.negCount, greaterThanOrEqualTo(3));
    });

    test('모든 기록은 분석이 끝난 상태, 지수 이력은 날짜 오름차순으로 계산 가능한 날만', () {
      expect(
        data.entries.every((e) => e.analysisStatus == AnalysisStatus.done),
        isTrue,
      );
      expect(data.indexPoints, isNotEmpty);
    });
  });
}
