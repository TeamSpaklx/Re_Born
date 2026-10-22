/// 인물과의 관계 유형 (SPEC F-02). 칩 글자로 쓴다.
enum RelationType {
  friend('친구'),
  family('가족'),
  teacher('선생님'),
  coworker('동료'),
  other('기타');

  const RelationType(this.label);

  final String label;
}
