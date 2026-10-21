/// 연속 기록 (출석 체크). 기록 작성 날짜로 앱에서 계산한다(docs/FRONTEND.md).
/// 계산 함수는 홈 After 작업에서 만든다.
class RecordStreak {
  const RecordStreak({required this.current, required this.longest});

  /// 현재 연속 기록 일수.
  final int current;

  /// 지금까지 가장 긴 연속 기록 일수.
  final int longest;
}
