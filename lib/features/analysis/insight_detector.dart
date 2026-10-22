import '../../core/utils/dates.dart';
import '../entries/models/entry.dart';
import '../insights/models/insight.dart';
import '../people/models/person.dart';
import 'relation_index.dart';

/// 부정 패턴·회복 추세 감지 (SPEC F-07). 순수 함수이며 임계값은 **제안값**이라 팀 테스트로 조정한다.
abstract final class InsightDetector {
  /// 부정 추세: 최근 [negWindowDays]일 중 점수 [negScoreAtMost] 이하 기록이 [negMinCount]건 이상이고
  /// 지수가 [negWindowDays]일 전보다 [indexDelta]점 이상 낮을 때.
  static const negWindowDays = 10;
  static const negScoreAtMost = -1;
  static const negMinCount = 3;

  /// 회복 추세: 지수가 [recoveryWindowDays]일 전보다 [indexDelta]점 이상 높을 때.
  static const recoveryWindowDays = 14;
  static const indexDelta = 10;

  /// 같은 인물·같은 유형은 이 기간(일) 안에 이미 있으면 새로 만들지 않는다.
  static const dedupeDays = 7;

  /// [entries]는 [person]의 기록들, [existing]은 이미 저장된 인사이트들. 만들 게 없으면 null.
  /// [newId]는 새 인사이트의 id.
  static Insight? detect({
    required Person person,
    required List<Entry> entries,
    required List<Insight> existing,
    required DateTime now,
    required String newId,
  }) {
    final current = RelationIndex.compute(entries, now);
    if (current == null) return null;

    final negative = _negativeTrend(entries, current.index, now);
    if (negative != null &&
        !_isDuplicate(existing, person, InsightType.negativeTrend, now)) {
      return Insight(
        id: newId,
        type: InsightType.negativeTrend,
        personId: person.id,
        message: '최근 부정적인 기록이 늘었어요',
        evidence: negative,
        createdAt: now,
      );
    }

    final recovery = _recovery(entries, current.index, now);
    if (recovery != null &&
        !_isDuplicate(existing, person, InsightType.recovery, now)) {
      return Insight(
        id: newId,
        type: InsightType.recovery,
        personId: person.id,
        message: '관계가 조금씩 좋아지고 있어요',
        evidence: recovery,
        createdAt: now,
      );
    }
    return null;
  }

  static InsightEvidence? _negativeTrend(
    List<Entry> entries,
    int indexNow,
    DateTime now,
  ) {
    final negCount = entries.where((e) {
      final diff = daysBetween(e.createdAt, now);
      return diff >= 0 && diff < negWindowDays && e.score <= negScoreAtMost;
    }).length;
    if (negCount < negMinCount) return null;
    final before = RelationIndex.compute(
      entries,
      now.subtract(const Duration(days: negWindowDays)),
    );
    if (before == null || before.index - indexNow < indexDelta) return null;
    return InsightEvidence(
      indexFrom: before.index,
      indexTo: indexNow,
      negCount: negCount,
    );
  }

  static InsightEvidence? _recovery(
    List<Entry> entries,
    int indexNow,
    DateTime now,
  ) {
    final before = RelationIndex.compute(
      entries,
      now.subtract(const Duration(days: recoveryWindowDays)),
    );
    if (before == null || indexNow - before.index < indexDelta) return null;
    return InsightEvidence(indexFrom: before.index, indexTo: indexNow);
  }

  static bool _isDuplicate(
    List<Insight> existing,
    Person person,
    InsightType type,
    DateTime now,
  ) {
    return existing.any(
      (i) =>
          i.personId == person.id &&
          i.type == type &&
          daysBetween(i.createdAt, now) < dedupeDays,
    );
  }
}
