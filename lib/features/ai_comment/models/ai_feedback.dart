/// 일기 한 건에 대한 AI 코멘트와 행동 제안 (백엔드 저장: `ai_feedback`).
class AiFeedback {
  const AiFeedback({
    required this.comment,
    required this.suggestions,
    required this.createdAt,
  });

  /// 사용자에게 건네는 짧은 코멘트(1~3문장).
  final String comment;

  /// 체크리스트에 담을 수 있는 행동 제안(0~3개).
  final List<String> suggestions;
  final DateTime createdAt;
}

/// AI 코멘트 말투. 마이 탭에서 고르고, 백엔드 API에 그대로 넘긴다.
enum CommentTone {
  warm('다정하게', '공감하고 다독이는 말투'),
  plain('담백하게', '짧고 차분한 말투');

  const CommentTone(this.label, this.description);

  final String label;
  final String description;
}
