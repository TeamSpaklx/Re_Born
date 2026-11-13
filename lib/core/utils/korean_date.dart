/// "9월 13일 목요일" 형태의 날짜 글자.
String formatKoreanDate(DateTime date) {
  const weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
  return '${date.month}월 ${date.day}일 ${weekdays[date.weekday - 1]}';
}

/// "오후 9:05" 형태의 시각 글자.
String formatKoreanTime(DateTime time) {
  final period = time.hour < 12 ? '오전' : '오후';
  final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  return '$period $hour:${time.minute.toString().padLeft(2, '0')}';
}
