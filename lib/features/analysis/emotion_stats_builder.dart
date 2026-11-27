import '../../core/utils/dates.dart';
import '../entries/models/emotion.dart';
import '../entries/models/entry.dart';
import '../entries/models/intensity_level.dart';

/// 분석 탭 그래프의 기간.
enum StatsPeriod {
  week('1주', 7),
  month('1달', 30);

  const StatsPeriod(this.label, this.days);

  final String label;

  /// 오늘 포함 며칠.
  final int days;
}

/// 하루의 감정 수치: 그날 일기 점수(−5~+5)의 평균.
class DailyScore {
  const DailyScore(this.date, this.average);

  final DateTime date;
  final double average;
}

/// 분석 탭 한 화면의 데이터. 순수 함수 [buildEmotionStats]가 만든다.
class EmotionStats {
  const EmotionStats({
    required this.period,
    required this.entryCount,
    required this.daily,
    required this.emotionCounts,
    required this.levelCounts,
    required this.recentFeedback,
  });

  final StatsPeriod period;

  /// 기간 안 일기 수.
  final int entryCount;

  /// 일기가 있는 날만, 날짜 오름차순.
  final List<DailyScore> daily;
  final Map<Emotion, int> emotionCounts;

  /// 강도 단계별 일기 수(1~5 모두 들어 있다, 없으면 0).
  final Map<IntensityLevel, int> levelCounts;

  /// AI 코멘트가 있는 기간 안 일기, 최근 것부터 최대 5개.
  final List<Entry> recentFeedback;

  /// 기간 평균 점수. 일기가 없으면 null.
  double? get averageScore => daily.isEmpty
      ? null
      : daily.map((d) => d.average).reduce((a, b) => a + b) / daily.length;
}

/// [entries]에서 [now]까지 [period] 안의 일기로 감정 수치 통계를 만든다.
EmotionStats buildEmotionStats(
  List<Entry> entries,
  DateTime now,
  StatsPeriod period,
) {
  final inPeriod = [
    for (final e in entries)
      if (daysBetween(e.createdAt, now) >= 0 &&
          daysBetween(e.createdAt, now) < period.days)
        e,
  ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  final byDay = <DateTime, List<int>>{};
  final emotions = <Emotion, int>{};
  final levels = {for (final l in IntensityLevel.values) l: 0};
  for (final e in inPeriod) {
    byDay.putIfAbsent(dateOnly(e.createdAt), () => []).add(e.score);
    emotions[e.emotion] = (emotions[e.emotion] ?? 0) + 1;
    final level = IntensityLevel.of(e.intensity);
    if (level != null) levels[level] = levels[level]! + 1;
  }
  final days = byDay.keys.toList()..sort();

  return EmotionStats(
    period: period,
    entryCount: inPeriod.length,
    daily: [
      for (final d in days)
        DailyScore(d, byDay[d]!.reduce((a, b) => a + b) / byDay[d]!.length),
    ],
    emotionCounts: emotions,
    levelCounts: levels,
    recentFeedback: inPeriod.where((e) => e.feedback != null).take(5).toList(),
  );
}
