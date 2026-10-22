/// "오늘 해볼까요?" 카드 하나. 인사이트의 행동 제안(F-08)에서 만든다.
class ActionSuggestion {
  const ActionSuggestion({
    required this.id,
    required this.insightId,
    required this.personId,
    required this.title,
    required this.reason,
    this.added = false,
  });

  final String id;

  /// 이 제안이 나온 인사이트. 카드를 누르면 그 인사이트 상세로 간다.
  final String insightId;
  final String personId;
  final String title;
  final String reason;

  /// 이미 체크리스트에 담았는지(F-04). 오른쪽 원이 채워진다.
  final bool added;
}
