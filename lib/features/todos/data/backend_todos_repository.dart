import '../../../core/network/backend_api_client.dart';
import '../models/todo.dart';
import 'todos_repository.dart';

class BackendTodosRepository implements TodosRepository {
  BackendTodosRepository(this._api);
  final BackendApiClient _api;

  @override
  Future<List<Todo>> list() async =>
      _rows(await _api.get('/api/todos')).map(_todo).toList(growable: false);

  @override
  Future<Todo> create({
    required String title,
    required DateTime createdAt,
    String? personId,
    TodoSource source = TodoSource.manual,
    String? insightId,
  }) async => _todo(
    await _api.post('/api/todos', {
      'title': title,
      'person_id': personId,
      'done': false,
      'done_at': null,
      'source': source.name,
      'insight_id': insightId,
      'created_at': createdAt.toUtc().toIso8601String(),
    }),
  );

  @override
  Future<void> update(Todo todo) async {
    await _api.put('/api/todos/${todo.id}', _todoJson(todo));
  }

  @override
  Future<void> delete(String id) async {
    await _api.delete('/api/todos/$id');
  }

  @override
  Future<void> deleteAll() async {
    await _api.delete('/api/todos');
  }
}

Todo _todo(Object? value) {
  final row = Map<String, dynamic>.from(value! as Map);
  return Todo(
    id: row['id'] as String,
    title: row['title'] as String,
    personId: row['person_id'] as String?,
    done: row['done'] as bool,
    doneAt: row['done_at'] == null
        ? null
        : DateTime.parse(row['done_at'] as String),
    source: TodoSource.values.byName(row['source'] as String),
    insightId: row['insight_id'] as String?,
    createdAt: DateTime.parse(row['created_at'] as String),
  );
}

Map<String, Object?> _todoJson(Todo todo) => {
  'title': todo.title,
  'person_id': todo.personId,
  'done': todo.done,
  'done_at': todo.doneAt?.toUtc().toIso8601String(),
  'source': todo.source.name,
  'insight_id': todo.insightId,
  'created_at': todo.createdAt.toUtc().toIso8601String(),
};

List<Object?> _rows(Object? value) => value as List<Object?>;
