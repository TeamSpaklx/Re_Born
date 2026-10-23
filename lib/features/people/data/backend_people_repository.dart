import '../../../core/network/backend_api_client.dart';
import '../models/person.dart';
import '../models/relation_type.dart';
import 'people_repository.dart';

class BackendPeopleRepository implements PeopleRepository {
  BackendPeopleRepository(this._api);
  final BackendApiClient _api;

  @override
  Future<List<Person>> list() async =>
      _rows(await _api.get('/api/people')).map(_person).toList(growable: false);

  @override
  Future<Person> create({
    required String name,
    required RelationType relationType,
    String? memo,
  }) async => _person(
    await _api.post('/api/people', {
      'name': name,
      'relation_type': relationType.name,
      'memo': memo,
    }),
  );

  @override
  Future<void> update(Person person) async {
    await _api.patch('/api/people/${person.id}', {
      'name': person.name,
      'relation_type': person.relationType.name,
      'memo': person.memo,
    });
  }

  @override
  Future<void> delete(String id) async => _api.delete('/api/people/$id');

  @override
  Future<void> deleteAll() async => _api.delete('/api/people');
}

Person _person(Object? value) {
  final row = _object(value);
  return Person(
    id: row['id'] as String,
    name: row['name'] as String,
    relationType: RelationType.values.byName(row['relation_type'] as String),
    memo: row['memo'] as String?,
    createdAt: DateTime.parse(row['created_at'] as String),
  );
}

List<Object?> _rows(Object? value) => (value as List<Object?>);
Map<String, dynamic> _object(Object? value) =>
    Map<String, dynamic>.from(value! as Map);
