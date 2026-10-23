import '../../core/providers/clock_provider.dart';
import '../../core/utils/dates.dart';
import '../entries/data/entries_repository.dart';
import '../entries/models/emotion.dart';
import '../entries/models/entry.dart';
import '../insights/data/insights_repository.dart';
import '../insights/models/index_point.dart';
import '../people/data/people_repository.dart';
import 'emotion_analyzer.dart';
import 'insight_detector.dart';
import 'relation_index.dart';

/// 기록 저장 → 감정 분석 → 관계 지수 → 인사이트로 이어지는 체인 (SPEC 5.2, 6.5).
/// 계산은 순수 함수가 하고, 이 서비스는 저장소에 읽고 쓰는 순서만 맡는다.
/// 백엔드는 저장소 구현만 바꾸면 되고 이 서비스는 그대로 쓴다.
class AnalysisService {
  AnalysisService({
    required this.entries,
    required this.people,
    required this.indexHistory,
    required this.insights,
    required this.clock,
    this.onError,
  });

  final EntriesRepository entries;
  final PeopleRepository people;
  final IndexHistoryRepository indexHistory;
  final InsightsRepository insights;
  final Clock clock;

  /// 분석 중 오류를 알리는 곳(앱 안 오류 기록). 없어도 동작한다.
  final void Function(Object error, StackTrace stack)? onError;

  /// 새 기록을 저장하고 분석한다. 분석이 실패해도 기록은 남고 `failed`로 표시된다.
  Future<Entry> saveEntry({
    required String body,
    required Emotion emotion,
    required int intensity,
    String? personId,
    DateTime? createdAt,
  }) async {
    final now = clock();
    final created = await entries.create(
      body: body,
      emotion: emotion,
      intensity: intensity,
      score: emotion.scoreFor(intensity),
      createdAt: createdAt ?? now,
      personId: personId,
    );
    return _analyze(created);
  }

  /// 기록을 고친다. 본문·감정·강도가 바뀌면 다시 분석하고, 옮겨 간 인물의 지수도 다시 계산한다.
  Future<Entry> updateEntry(Entry edited) async {
    final before = await entries.get(edited.id);
    final pending = edited.copyWith(
      score: edited.emotion.scoreFor(edited.intensity),
      analysisStatus: AnalysisStatus.pending,
    );
    await entries.update(pending);
    final result = await _analyze(pending);
    if (before?.personId != null && before!.personId != edited.personId) {
      await recomputePerson(before.personId!);
    }
    return result;
  }

  /// 기록을 지우고 그 인물의 지수를 다시 계산한다(T-14).
  Future<void> deleteEntry(String id) async {
    final target = await entries.get(id);
    await entries.delete(id);
    if (target?.personId != null) await recomputePerson(target!.personId!);
  }

  /// 인물을 지운다. [deleteEntries]가 true면 그 인물의 기록도 함께 지우고,
  /// false면 기록은 남기고 "인물 없음"으로 바꾼다(SPEC 11장 8번: 사용자가 선택).
  /// 그 인물의 지수 이력과 인사이트는 함께 지운다.
  Future<void> deletePerson(
    String personId, {
    required bool deleteEntries,
  }) async {
    final own = await entries.list(personId: personId);
    for (final e in own) {
      if (deleteEntries) {
        await entries.delete(e.id);
      } else {
        await entries.update(e.copyWith(personId: null));
      }
    }
    await indexHistory.deleteForPerson(personId);
    await insights.deleteForPerson(personId);
    await people.delete(personId);
  }

  /// 분석에 실패한 기록을 처음부터 다시 분석한다.
  Future<Entry> retryAnalysis(String id) async {
    final target = await entries.get(id);
    if (target == null) throw StateError('기록을 찾을 수 없어요.');
    return _analyze(target);
  }

  Future<Entry> _analyze(Entry entry) async {
    try {
      final now = clock();
      final result = EmotionAnalyzer.analyze(
        body: entry.body,
        emotion: entry.emotion,
        intensity: entry.intensity,
        now: now,
      );
      var analyzed = entry.copyWith(
        score: result.score,
        analysis: result.analysis,
        analysisStatus: AnalysisStatus.pending,
      );
      await entries.update(analyzed);
      if (entry.personId != null) await recomputePerson(entry.personId!);
      // done은 지수·인사이트 저장까지 끝난 뒤에 기록한다(SPEC 8장).
      analyzed = analyzed.copyWith(analysisStatus: AnalysisStatus.done);
      await entries.update(analyzed);
      return analyzed;
    } catch (error, stack) {
      onError?.call(error, stack);
      final failed = entry.copyWith(analysisStatus: AnalysisStatus.failed);
      await entries.update(failed);
      return failed;
    }
  }

  /// 인물의 오늘 지수와 인사이트를 다시 계산해 저장한다(기록 추가·수정·삭제 뒤).
  Future<void> recomputePerson(String personId) async {
    final now = clock();
    final all = (await people.list()).where((p) => p.id == personId);
    if (all.isEmpty) return;
    final person = all.first;
    final own = await entries.list(personId: personId);

    final result = RelationIndex.compute(own, now);
    if (result == null) {
      // 데이터 부족: 오늘 지수는 저장하지 않는다.
      await indexHistory.delete(personId, now);
      return;
    }
    await indexHistory.upsert(
      IndexPoint(
        personId: personId,
        date: dateOnly(now),
        index: result.index,
        entryCount: result.entryCount,
      ),
    );

    final existing = await insights.list(personId: personId);
    final found = InsightDetector.detect(
      person: person,
      entries: own,
      existing: existing,
      now: now,
      newId: 'i${now.microsecondsSinceEpoch}',
    );
    if (found != null) await insights.save(found);
  }
}
