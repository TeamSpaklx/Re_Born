import '../../core/utils/dates.dart';
import '../home/models/record_streak.dart';

/// 연속 기록(출석 체크)을 기록 작성 날짜로 계산한다. DB에 따로 저장하지 않는다.
/// 하루에 1건 이상 기록하면 그날은 "기록한 날"이고, 오늘 또는 어제부터 거꾸로 이어진 날 수가 [RecordStreak.current]이다.
RecordStreak calculateRecordStreak(
  Iterable<DateTime> entryDates,
  DateTime today,
) {
  final days = {for (final d in entryDates) dateOnly(d)};
  if (days.isEmpty) return const RecordStreak(current: 0, longest: 0);

  final base = dateOnly(today);
  final yesterday = base.subtract(const Duration(days: 1));
  var cursor = days.contains(base)
      ? base
      : days.contains(yesterday)
      ? yesterday
      : null;
  var current = 0;
  while (cursor != null && days.contains(cursor)) {
    current++;
    cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
  }

  final sorted = days.toList()..sort();
  var longest = 1;
  var run = 1;
  for (var i = 1; i < sorted.length; i++) {
    run = daysBetween(sorted[i - 1], sorted[i]) == 1 ? run + 1 : 1;
    if (run > longest) longest = run;
  }
  return RecordStreak(current: current, longest: longest);
}
