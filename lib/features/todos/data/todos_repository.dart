import '../models/todo.dart';

/// 체크리스트 저장소 (테이블 `todos`). 본인 행만 접근(RLS).
abstract interface class TodosRepository {
  Future<List<Todo>> list();

  Future<Todo> create({
    required String title,
    required DateTime createdAt,
    String? personId,
    TodoSource source = TodoSource.manual,
    String? insightId,
  });

  /// 제목·완료 여부·완료 시각을 갱신한다.
  Future<void> update(Todo todo);

  Future<void> delete(String id);

  Future<void> deleteAll();
}
