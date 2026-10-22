import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/data_providers.dart';
import '../../../app/data_revision.dart';
import '../models/todo.dart';

/// 체크리스트(최근 것이 먼저). 데이터가 바뀌면 다시 불러온다.
final todosProvider = FutureProvider<List<Todo>>((ref) {
  ref.watch(dataRevisionProvider);
  return ref.watch(todosRepositoryProvider).list();
});

/// 체크리스트 추가·체크·삭제. 저장에 실패하면 예외가 그대로 나가고 화면 상태는 바뀌지 않는다(원래대로 유지).
class TodoActions {
  TodoActions(this._ref);

  final Ref _ref;

  Future<Todo> add({
    required String title,
    String? personId,
    TodoSource source = TodoSource.manual,
    String? insightId,
    required DateTime now,
  }) async {
    final todo = await _ref
        .read(todosRepositoryProvider)
        .create(
          title: title.trim(),
          createdAt: now,
          personId: personId,
          source: source,
          insightId: insightId,
        );
    _ref.read(dataRevisionProvider.notifier).bump();
    return todo;
  }

  Future<void> setDone(Todo todo, bool done, DateTime now) async {
    await _ref
        .read(todosRepositoryProvider)
        .update(todo.copyWith(done: done, doneAt: done ? now : null));
    _ref.read(dataRevisionProvider.notifier).bump();
  }

  Future<void> delete(String id) async {
    await _ref.read(todosRepositoryProvider).delete(id);
    _ref.read(dataRevisionProvider.notifier).bump();
  }
}

final todoActionsProvider = Provider<TodoActions>(TodoActions.new);
