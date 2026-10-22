// 날짜 계산 도우미. 시간대는 기기 기준이고 "하루"는 자정에서 자정까지다.

/// 시각을 뺀 그날(자정).
DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

/// [from]에서 [to]까지 달력 날짜로 며칠 차이인지(to가 나중이면 양수).
int daysBetween(DateTime from, DateTime to) {
  final a = DateTime.utc(from.year, from.month, from.day);
  final b = DateTime.utc(to.year, to.month, to.day);
  return b.difference(a).inDays;
}
