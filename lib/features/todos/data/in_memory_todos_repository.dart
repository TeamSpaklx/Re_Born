import '../models/todo.dart';
import 'todos_repository.dart';

/// 메모리에만 두는 체크리스트 저장소.
class InMemoryTodosRepository implements TodosRepository {
  InMemoryTodosRepository({List<Todo> initial = const []})
    : _items = [...initial];

  final List<Todo> _items;
  var _nextId = 100;

  @override
  Future<List<Todo>> list() async {
    final result = [..._items]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(result);
  }

  @override
  Future<Todo> create({
    required String title,
    required DateTime createdAt,
    String? personId,
    TodoSource source = TodoSource.manual,
    String? insightId,
  }) async {
    final todo = Todo(
      id: 't${_nextId++}',
      title: title,
      createdAt: createdAt,
      personId: personId,
      source: source,
      insightId: insightId,
    );
    _items.add(todo);
    return todo;
  }

  @override
  Future<void> update(Todo todo) async {
    final i = _items.indexWhere((t) => t.id == todo.id);
    if (i >= 0) _items[i] = todo;
  }

  @override
  Future<void> delete(String id) async => _items.removeWhere((t) => t.id == id);

  @override
  Future<void> deleteAll() async => _items.clear();
}
