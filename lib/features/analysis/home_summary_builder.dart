import '../../core/utils/dates.dart';
import '../entries/models/entry.dart';
import '../home/models/action_suggestion.dart';
import '../home/models/home_summary.dart';
import '../todos/models/todo.dart';
import 'record_streak_calculator.dart';
import 'weekly_emotion_builder.dart';

/// 홈 화면 요약을 저장소 데이터에서 앱이 조립한다. 순수 함수라 백엔드는 저장소만 구현하면 된다.
HomeSummary buildHomeSummary({
  required String nickname,
  required DateTime now,
  required List<Entry> entries,
  required List<Todo> todos,
}) {
  final today = dateOnly(now);
  final sorted = [...entries]
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  final todayEntries = sorted
      .where((e) => dateOnly(e.createdAt) == today)
      .toList();
  final latestToday = todayEntries.isEmpty ? null : todayEntries.first;

  // 제안: AI 코멘트가 있는 가장 최근 일기의 행동 제안. 이미 체크리스트에 담은 것(완료 포함)은 뺀다.
  Entry? source;
  for (final e in sorted) {
    if (e.feedback != null && e.feedback!.suggestions.isNotEmpty) {
      source = e;
      break;
    }
  }
  final suggestions = <ActionSuggestion>[];
  if (source != null) {
    final feedback = source.feedback!;
    for (final (k, title) in feedback.suggestions.indexed) {
      final added = todos.any(
        (t) => t.entryId == source!.id && t.title == title,
      );
      if (added) continue;
      suggestions.add(
        ActionSuggestion(
          id: '${source.id}:$k',
          entryId: source.id,
          title: title,
          reason: feedback.comment,
        ),
      );
    }
  }

  return HomeSummary(
    nickname: nickname,
    today: now,
    todayRecorded: latestToday != null,
    streak: calculateRecordStreak(entries.map((e) => e.createdAt), now),
    weeklyEmotion: buildWeeklyEmotion(entries, now),
    suggestions: suggestions.take(2).toList(),
    suggestionsDone: source != null && suggestions.isEmpty,
    todayEntryId: latestToday?.id,
    todayComment: latestToday?.feedback?.comment,
    todayCommentPending:
        latestToday != null &&
        latestToday.analysisStatus == AnalysisStatus.pending,
  );
}
