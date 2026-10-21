/// "오늘 해볼까요?" 카드 하나.
class ActionSuggestion {
  const ActionSuggestion({
    required this.id,
    required this.personId,
    required this.title,
    required this.reason,
    this.done = false,
  });

  final String id;
  final String personId;
  final String title;
  final String reason;

  /// 오른쪽 원 체크 여부 (F-04 체크리스트와 연결).
  final bool done;
}
