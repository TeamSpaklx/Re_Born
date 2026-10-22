/// 인물의 하루 관계 지수 (SPEC F-06, 테이블 `index_history`).
class IndexPoint {
  const IndexPoint({
    required this.personId,
    required this.date,
    required this.index,
    required this.entryCount,
  });

  final String personId;

  /// 그날(자정).
  final DateTime date;

  /// 0~100.
  final int index;

  /// 계산에 쓴 기록 수.
  final int entryCount;
}
