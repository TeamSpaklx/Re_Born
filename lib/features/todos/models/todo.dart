/// 체크리스트 항목의 출처: 직접 입력 / AI 행동 제안(F-08)에서 담음.
enum TodoSource { manual, suggestion }

/// 체크리스트 항목 (SPEC F-04, 테이블 `todos`).
class Todo {
  const Todo({
    required this.id,
    required this.title,
    required this.createdAt,
    this.done = false,
    this.doneAt,
    this.source = TodoSource.manual,
    this.entryId,
  });

  final String id;

  /// 제목 1~100자.
  final String title;
  final bool done;
  final DateTime? doneAt;
  final TodoSource source;

  /// AI 제안을 담았다면 그 제안이 나온 일기.
  final String? entryId;
  final DateTime createdAt;

  Todo copyWith({String? title, bool? done, DateTime? doneAt}) {
    return Todo(
      id: id,
      title: title ?? this.title,
      done: done ?? this.done,
      doneAt: (done ?? this.done) ? (doneAt ?? this.doneAt) : null,
      source: source,
      entryId: entryId,
      createdAt: createdAt,
    );
  }
}

abstract final class TodoValidator {
  static const maxTitleLength = 100;

  static String? validateTitle(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return '제목을 입력해 주세요.';
    if (trimmed.length > maxTitleLength) {
      return '제목은 $maxTitleLength자 이내로 입력해 주세요.';
    }
    return null;
  }
}
