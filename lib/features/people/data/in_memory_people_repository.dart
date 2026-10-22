import '../models/person.dart';
import '../models/relation_type.dart';
import 'people_repository.dart';

/// 메모리에만 두는 인물 저장소. 앱을 다시 켜면 샘플로 돌아간다.
class InMemoryPeopleRepository implements PeopleRepository {
  InMemoryPeopleRepository({List<Person> initial = const []})
    : _items = [...initial];

  final List<Person> _items;
  var _nextId = 100;

  @override
  Future<List<Person>> list() async => List.unmodifiable(_items);

  @override
  Future<Person> create({
    required String name,
    required RelationType relationType,
    String? memo,
  }) async {
    final person = Person(
      id: 'p${_nextId++}',
      name: name,
      relationType: relationType,
      memo: memo,
      createdAt: DateTime.now(),
    );
    _items.add(person);
    return person;
  }

  @override
  Future<void> update(Person person) async {
    final i = _items.indexWhere((p) => p.id == person.id);
    if (i >= 0) _items[i] = person;
  }

  @override
  Future<void> delete(String id) async => _items.removeWhere((p) => p.id == id);

  @override
  Future<void> deleteAll() async => _items.clear();
}
