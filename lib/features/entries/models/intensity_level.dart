/// 감정 강도 기준표(1~5단계). 기록할 때 이 기준으로 고르고, 이 값이 감정 수치 그래프의 데이터가 된다.
/// 단계 이름과 기준 문구는 팀 회의(2026-11-28)에서 정한 그대로이며, 다른 곳은 이 표만 읽는다.
enum IntensityLevel {
  detected(1, '감지됨', '감정을 느꼈지만 일상에 영향이 거의 없음'),
  aware(2, '의식됨', '감정이 신경 쓰이지만 평소 활동 가능'),
  affecting(3, '영향 있음', '집중력이나 행동에 영향을 줌'),
  strong(4, '크게 영향', '일상 활동을 수행하기 어려움'),
  overwhelming(5, '압도됨', '감정에 대응하기 어려울 정도로 강하게 느껴짐');

  const IntensityLevel(this.value, this.label, this.description);

  /// 저장 값 1~5.
  final int value;
  final String label;
  final String description;

  static const min = 1;
  static const max = 5;

  /// 1~5가 아니면 null.
  static IntensityLevel? of(int? value) =>
      values.where((l) => l.value == value).firstOrNull;
}
