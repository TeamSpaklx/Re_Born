import '../../core/utils/dates.dart';
import '../entries/models/entry.dart';
import '../home/models/weekly_emotion_flow.dart';

/// 홈의 "이번 주 감정 흐름"을 만든다. 순수 함수.
/// 이번 주(월~일)의 요일별 기록 점수 평균을 `(평균 + 3) / 6`(0~1)으로 바꿔 막대 값으로 쓴다.
/// 이 값의 정의는 **임시(팀 확인 필요)**이다(docs/DESIGN_SPEC_CHECK.md 질문 1·3).
WeeklyEmotionFlow buildWeeklyEmotion(List<Entry> entries, DateTime today) {
  final base = dateOnly(today);
  final monday = base.subtract(Duration(days: base.weekday - 1));

  final days = <double?>[];
  for (var i = 0; i < 7; i++) {
    final day = DateTime(monday.year, monday.month, monday.day + i);
    final scores = [
      for (final e in entries)
        if (dateOnly(e.createdAt) == day) e.score,
    ];
    days.add(
      scores.isEmpty
          ? null
          : (scores.reduce((a, b) => a + b) / scores.length + 3) / 6,
    );
  }

  final recorded = [
    for (var i = 0; i < 7; i++)
      if (days[i] != null) i,
  ];
  if (recorded.isEmpty) {
    return WeeklyEmotionFlow(
      month: today.month,
      days: days,
      summary: '이번 주 기록이 쌓이면 흐름을 보여 드려요.',
    );
  }

  var peak = recorded.first;
  for (final i in recorded) {
    if (days[i]! > days[peak]!) peak = i;
  }
  final peakValue = days[peak]!;
  final emoji = peakValue >= 0.67
      ? '😁'
      : peakValue >= 0.4
      ? '🙂'
      : '😢';

  var summary = '이번 주 기록이 쌓이면 흐름을 보여 드려요.';
  String? emphasis;
  if (recorded.length >= 2) {
    final half = recorded.length ~/ 2;
    double avg(Iterable<int> idx) =>
        idx.map((i) => days[i]!).reduce((a, b) => a + b) / idx.length;
    final early = avg(recorded.take(half));
    final late = avg(recorded.skip(recorded.length - half));
    final diff = late - early;
    if (diff >= 0.05) {
      summary = '긍정적인 감정이 조금씩 증가하고 있어요.';
      emphasis = '조금씩 증가';
    } else if (diff <= -0.05) {
      summary = '긍정적인 감정이 조금씩 줄고 있어요.';
      emphasis = '조금씩 줄고';
    } else {
      summary = '감정이 비슷하게 이어지고 있어요.';
      emphasis = '비슷하게';
    }
  }

  return WeeklyEmotionFlow(
    month: today.month,
    days: days,
    peakIndex: peak,
    peakEmoji: emoji,
    summary: summary,
    summaryEmphasis: emphasis,
  );
}
