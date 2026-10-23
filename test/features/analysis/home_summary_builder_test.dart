import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/features/analysis/data/sample_data.dart';
import 'package:reborn_app/features/analysis/home_summary_builder.dart';
import 'package:reborn_app/features/analysis/weekly_emotion_builder.dart';
import 'package:reborn_app/features/entries/models/emotion.dart';
import 'package:reborn_app/features/entries/models/entry.dart';

void main() {
  final now = DateTime(2026, 10, 22, 12); // 목요일
  Entry entry(DateTime at, int score, {String? personId}) => Entry(
    id: '$at$score',
    body: '본문',
    emotion: score < 0 ? Emotion.hurt : Emotion.joy,
    intensity: score.abs().clamp(1, 3),
    score: score,
    createdAt: at,
    personId: personId,
  );

  group('이번 주 감정 흐름', () {
    test('월~일 7칸, 요일별 평균 점수를 (평균+3)/6으로 바꾼다', () {
      final flow = buildWeeklyEmotion([
        entry(DateTime(2026, 10, 19, 9), 3), // 월 → 1.0
        entry(DateTime(2026, 10, 20, 9), -3), // 화 → 0.0
        entry(DateTime(2026, 10, 20, 20), 3), // 화 평균 0 → 0.5
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
    test('오늘 기록이 없으면 Before, 연속 5일·최장 20일, 관계 신호 1개, 제안 2개', () {
      final s = buildHomeSummary(
        nickname: '규리',
        now: now,
        entries: data.entries,
        people: data.people,
        insights: data.insights,
        todos: data.todos,
      );
      expect(s.todayRecorded, isFalse);
      expect(s.todayEntryId, isNull);
      expect(s.streak.current, 5);
      expect(s.streak.longest, 20);
      expect(s.relationSignals.single.personName, '지민');
      expect(s.relationSignals.single.daysSinceLastRecord, 1);
      expect(s.suggestions, hasLength(2));
      // 샘플 체크리스트에는 첫 제안이 이미 담겨 있다.
      expect(s.suggestions[0].added, isTrue);
      expect(s.suggestions[1].added, isFalse);
    });

    test('오늘 기록이 생기면 After, 연속 6일, 오늘 기록 id와 인물 수가 채워진다', () {
      final today = entry(now, 2, personId: 'p2');
      final s = buildHomeSummary(
        nickname: '규리',
        now: now,
        entries: [...data.entries, today],
        people: data.people,
        insights: data.insights,
        todos: data.todos,
      );
      expect(s.todayRecorded, isTrue);
      expect(s.todayEntryId, today.id);
      expect(s.todayPeopleCount, 1);
      expect(s.streak.current, 6);
    });

    test('기록·인사이트가 없으면 신호와 제안은 비어 있다', () {
      final s = buildHomeSummary(
        nickname: '규리',
        now: now,
        entries: const [],
        people: data.people,
        insights: const [],
        todos: const [],
      );
      expect(s.relationSignals, isEmpty);
      expect(s.suggestions, isEmpty);
      expect(s.streak.current, 0);
    });
  });
}
