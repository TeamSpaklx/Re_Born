/// 인물과의 관계 유형. 칩 글자로 쓴다.
enum RelationType {
  friend('친구'),
  family('가족'),
  teacher('선생님'),
  coworker('직장 동료'),
  other('기타');

  const RelationType(this.label);

  final String label;
}

/// "최근 관계 신호" 카드 하나.
class RelationSignal {
  const RelationSignal({
    required this.personId,
    required this.personName,
    required this.relationType,
    required this.message,
    required this.daysSinceLastRecord,
  });

  final String personId;
  final String personName;
  final RelationType relationType;

  /// 계산 가능한 사실만 담은 문장 (예: "최근 대화가 조금 줄었어요").
  final String message;

  /// "마지막 기록 N일 전"의 N.
  final int daysSinceLastRecord;
}
