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

  // 제안: 인물마다 최신 인사이트의 첫 제안. 하나뿐이면 같은 인사이트의 다음 제안을 이어 붙여 두 장.
  final suggestions = <ActionSuggestion>[];
  bool isAdded(String title, String insightId) =>
      todos.any((t) => t.insightId == insightId && t.title == title);
  for (final insight in picked) {
    final person = personOf(insight.personId);
    if (person == null) continue;
    final pool = SuggestionPool.forInsight(insight.type, person.name);
    suggestions.add(
      ActionSuggestion(
        id: '${insight.id}:0',
        insightId: insight.id,
        personId: person.id,
        title: pool.first,
        reason: insight.message,
        added: isAdded(pool.first, insight.id),
      ),
    );
  }
  if (suggestions.length == 1 && picked.isNotEmpty) {
    final insight = picked.first;
    final person = personOf(insight.personId);
    final pool = SuggestionPool.forInsight(insight.type, person?.name ?? '');
    if (pool.length > 1) {
      suggestions.add(
        ActionSuggestion(
          id: '${insight.id}:1',
          insightId: insight.id,
          personId: insight.personId,
          title: pool[1],
          reason: insight.message,
          added: isAdded(pool[1], insight.id),
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
