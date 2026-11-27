/// "오늘 해볼까요?" 카드 하나. 일기 AI 코멘트의 행동 제안(F-08)에서 만든다.
class ActionSuggestion {
  const ActionSuggestion({
    required this.id,
    required this.entryId,
    required this.title,
    required this.reason,
    this.added = false,
  });

  final String id;

  /// 이 제안이 나온 일기. 카드를 누르면 그 일기 상세로 간다.
  final String entryId;
  final String title;

  /// 제안 이유(그 일기의 AI 코멘트).
  final String reason;

  /// 방금 체크리스트에 담았는지. 홈이 잠깐 채워진 원을 보여 줄 때만 true다(담은 제안은 곧 목록에서 빠진다).
  final bool added;

  ActionSuggestion asAdded() => ActionSuggestion(
    id: id,
    entryId: entryId,
    title: title,
    reason: reason,
    added: true,
  );
}
