import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/features/analysis/data/sample_data.dart';
import 'package:reborn_app/features/analysis/home_summary_builder.dart';
import 'package:reborn_app/features/analysis/weekly_emotion_builder.dart';
import 'package:reborn_app/features/home/models/home_summary.dart';
import 'package:reborn_app/features/entries/models/emotion.dart';
import 'package:reborn_app/features/entries/models/entry.dart';
import 'package:reborn_app/features/todos/models/todo.dart';

void main() {
  final now = DateTime(2026, 10, 22, 12); // 목요일
  Entry entry(DateTime at, int score) => Entry(
    id: '$at$score',
    body: '본문',
    emotion: score < 0 ? Emotion.sadness : Emotion.joy,
    intensity: score.abs().clamp(1, 5),
    score: score,
    createdAt: at,
  );

  group('이번 주 감정 흐름', () {
    test('월~일 7칸, 요일별 평균 점수를 (평균+5)/10으로 바꾼다', () {
      final flow = buildWeeklyEmotion([
        entry(DateTime(2026, 10, 19, 9), 5), // 월 → 1.0
        entry(DateTime(2026, 10, 20, 9), -5), // 화 → 0.0
        entry(DateTime(2026, 10, 20, 20), 5), // 화 평균 0 → 0.5
      ], now);

      expect(flow.days, hasLength(7));
      expect(flow.days[0], 1.0);
      expect(flow.days[1], 0.5);
      expect(flow.days.sublist(2), everyElement(isNull));
      expect(flow.month, 10);
      expect(flow.peakIndex, 0);
      expect(flow.peakEmoji, '😁');
    });

    test('지난주·다음주 기록은 이번 주에 넣지 않는다', () {
      final flow = buildWeeklyEmotion([
        entry(DateTime(2026, 10, 18, 9), 3), // 지난주 일요일
        entry(DateTime(2026, 10, 26, 9), 3), // 다음주 월요일
      ], now);
      expect(flow.days, everyElement(isNull));
      expect(flow.peakIndex, isNull);
      expect(flow.summary, contains('기록이 쌓이면'));
    });

    test('점점 좋아지면 "조금씩 증가", 내려가면 "조금씩 줄고", 비슷하면 "비슷하게"', () {
      String emphasis(List<int> scores) => buildWeeklyEmotion([
        for (var i = 0; i < scores.length; i++)
          entry(DateTime(2026, 10, 19 + i, 9), scores[i]),
      ], now).summaryEmphasis!;

      expect(emphasis([-2, 0, 2]), '조금씩 증가');
      expect(emphasis([2, 0, -2]), '조금씩 줄고');
      expect(emphasis([1, 1, 1]), '비슷하게');
    });
  });

  group('홈 요약 조립', () {
    final data = buildSampleData(now);
    HomeSummary summary({List<Entry>? entries, List<Todo>? todos}) =>
        buildHomeSummary(
          nickname: '규리',
          now: now,
          entries: entries ?? data.entries,
          todos: todos ?? data.todos,
        );

    test('오늘 기록이 없으면 Before, 연속 5일·최장 20일, 최근 일기의 AI 제안 중 안 담은 것', () {
      final s = summary();
      expect(s.todayRecorded, isFalse);
      expect(s.todayEntryId, isNull);
      expect(s.todayComment, isNull);
      expect(s.streak.current, 5);
      expect(s.streak.longest, 20);
      final latest =
          (data.entries.toList()
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt)))
              .first;
      final added = data.todos.where((t) => t.entryId == latest.id);
      expect(s.suggestions.every((e) => e.entryId == latest.id), isTrue);
      expect(
        s.suggestions.map((e) => e.title),
        isNot(contains(anyOf(added.map((t) => t.title).toList()))),
      );
      expect(
        s.suggestions.every((e) => e.reason == latest.feedback!.comment),
        isTrue,
      );
      expect(s.suggestionsDone, isFalse);
    });

    test('제안을 모두 담으면(완료한 것 포함) 제안은 비고 suggestionsDone이 켜진다', () {
      final latest =
          (data.entries.toList()
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt)))
              .first;
      final titles = latest.feedback!.suggestions;
      final todos = [
        for (var i = 0; i < titles.length; i++)
          Todo(
            id: 't$i',
            title: titles[i],
            createdAt: now,
            entryId: latest.id,
            source: TodoSource.suggestion,
            done: i.isEven,
          ),
      ];
      final s = summary(todos: todos);
      expect(s.suggestions, isEmpty);
      expect(s.suggestionsDone, isTrue);
    });

    test('오늘 기록이 생기면 After, 연속 6일, 오늘 기록 id·코멘트 받는 중', () {
      final today = entry(now, 2);
      final s = summary(entries: [...data.entries, today]);
      expect(s.todayRecorded, isTrue);
      expect(s.todayEntryId, today.id);
      expect(s.todayCommentPending, isTrue);
      expect(s.todayComment, isNull);
      expect(s.streak.current, 6);
    });

    test('기록이 없으면 제안은 비어 있다', () {
      final s = summary(entries: const [], todos: const []);
      expect(s.suggestions, isEmpty);
      expect(s.suggestionsDone, isFalse);
      expect(s.streak.current, 0);
    });
  });
}
