import '../../core/utils/dates.dart';
import '../entries/models/entry.dart';

/// 인물별 관계 지수 계산 (SPEC F-06). 순수 함수.
abstract final class RelationIndex {
  /// 지수 계산에 쓰는 기간(일)과 최소 기록 수. 3건 미만이면 "데이터 부족".
  static const windowDays = 14;
  static const recentDays = 7;
  static const minEntries = 3;

  /// 최근 7일 기록의 가중치 2, 그 이전 7일은 1.
  static const recentWeight = 2;
  static const olderWeight = 1;

  /// [entries]는 한 인물의 기록들. [asOf] 날짜 기준 최근 14일(그날 포함)로 계산한다.
  /// 기록이 3건 미만이면 null(데이터 부족).
  static ({int index, int entryCount})? compute(
    List<Entry> entries,
    DateTime asOf,
  ) {
    var weightedSum = 0.0;
    var weightTotal = 0;
    var count = 0;
    for (final e in entries) {
      final diff = daysBetween(e.createdAt, asOf);
      if (diff < 0 || diff >= windowDays) continue;
      final weight = diff < recentDays ? recentWeight : olderWeight;
      weightedSum += e.score * weight;
      weightTotal += weight;
      count++;
    }
    if (count < minEntries) return null;
    final average = weightedSum / weightTotal; // −3 ~ +3
    final index = ((average + 3) / 6 * 100).round().clamp(0, 100);
    return (index: index, entryCount: count);
  }
}
