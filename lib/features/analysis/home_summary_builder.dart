import '../../core/utils/dates.dart';
import '../entries/models/entry.dart';
import '../home/models/action_suggestion.dart';
import '../home/models/home_summary.dart';
import '../home/models/relation_signal.dart';
import '../insights/models/insight.dart';
import '../people/models/person.dart';
import '../todos/models/todo.dart';
import 'record_streak_calculator.dart';
import 'suggestion_pool.dart';
import 'weekly_emotion_builder.dart';

/// 홈 화면 요약을 저장소 데이터에서 앱이 조립한다. 순수 함수라 백엔드는 저장소만 구현하면 된다.
HomeSummary buildHomeSummary({
  required String nickname,
  required DateTime now,
  required List<Entry> entries,
  required List<Person> people,
  required List<Insight> insights,
  required List<Todo> todos,
}) {
  final today = dateOnly(now);
  final todayEntries = entries
      .where((e) => dateOnly(e.createdAt) == today)
      .toList();

  // 인물마다 가장 최근 인사이트 하나씩, 최근 것부터 최대 2개.
  final latestPerPerson = <String, Insight>{};
  for (final i in [
    ...insights,
  ]..sort((a, b) => b.createdAt.compareTo(a.createdAt))) {
    latestPerPerson.putIfAbsent(i.personId, () => i);
  }
  final picked = latestPerPerson.values.take(2).toList();
  Person? personOf(String id) {
    for (final p in people) {
      if (p.id == id) return p;
    }
    return null;
  }

  final signals = <RelationSignal>[];
  for (final insight in picked) {
    final person = personOf(insight.personId);
    if (person == null) continue;
    final own = entries.where((e) => e.personId == person.id);
    final last = own.isEmpty
        ? null
        : own.map((e) => e.createdAt).reduce((a, b) => a.isAfter(b) ? a : b);
    signals.add(
      RelationSignal(
        insightId: insight.id,
        personId: person.id,
        personName: person.name,
        relationType: person.relationType,
        message: insight.message,
        daysSinceLastRecord: last == null ? 0 : daysBetween(last, now),
      ),
    );
  }

  // 제안: 인물마다 최신 인사이트의 제안 문구를 번갈아 훑어, 이미 체크리스트에 있는 것(완료 포함)은 빼고 처음 두 개를 보여 준다.
  bool isAdded(String title, String insightId) =>
      todos.any((t) => t.insightId == insightId && t.title == title);
  final pools = <(Insight, Person, List<String>)>[];
  for (final insight in picked) {
    final person = personOf(insight.personId);
    if (person == null) continue;
    pools.add((
      insight,
      person,
      SuggestionPool.forInsight(insight.type, person.name),
    ));
  }
  final suggestions = <ActionSuggestion>[];
  final longest = pools.isEmpty
      ? 0
      : pools.map((e) => e.$3.length).reduce((a, b) => a > b ? a : b);
  for (var k = 0; k < longest && suggestions.length < 2; k++) {
    for (final (insight, person, pool) in pools) {
      if (k >= pool.length || suggestions.length >= 2) continue;
      if (isAdded(pool[k], insight.id)) continue;
      suggestions.add(
        ActionSuggestion(
          id: '${insight.id}:$k',
          insightId: insight.id,
          personId: person.id,
          title: pool[k],
          reason: insight.message,
        ),
      );
    }
  }

  return HomeSummary(
    nickname: nickname,
    today: now,
    todayRecorded: todayEntries.isNotEmpty,
    streak: calculateRecordStreak(entries.map((e) => e.createdAt), now),
    relationSignals: signals,
    weeklyEmotion: buildWeeklyEmotion(entries, now),
    suggestions: suggestions,
    suggestionsDone: pools.isNotEmpty && suggestions.isEmpty,
    todayEntryId: todayEntries.isEmpty
        ? null
        : (todayEntries..sort((a, b) => b.createdAt.compareTo(a.createdAt)))
              .first
              .id,
    todayPeopleCount: todayEntries
        .map((e) => e.personId)
        .whereType<String>()
        .toSet()
        .length,
  );
}
