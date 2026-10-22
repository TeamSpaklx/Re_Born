import '../models/emotion.dart';
import '../models/entry.dart';
import 'entries_repository.dart';

/// 메모리에만 두는 기록 저장소.
class InMemoryEntriesRepository implements EntriesRepository {
  InMemoryEntriesRepository({List<Entry> initial = const []})
    : _items = [...initial];

  final List<Entry> _items;
  var _nextId = 1000;

  @override
  Future<List<Entry>> list({String? personId}) async {
    final result =
        _items.where((e) => personId == null || e.personId == personId).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(result);
  }

  @override
  Future<Entry?> get(String id) async {
    for (final e in _items) {
      if (e.id == id) return e;
    }
    return null;
  }

  @override
  Future<Entry> create({
    required String body,
    required Emotion emotion,
    required int intensity,
    required int score,
    required DateTime createdAt,
    String? personId,
  }) async {
    final entry = Entry(
      id: 'e${_nextId++}',
      body: body,
      personId: personId,
      emotion: emotion,
      intensity: intensity,
      score: score,
      createdAt: createdAt,
    );
    _items.add(entry);
    return entry;
  }

  @override
  Future<void> update(Entry entry) async {
    final i = _items.indexWhere((e) => e.id == entry.id);
    if (i >= 0) _items[i] = entry;
  }

  @override
  Future<void> delete(String id) async => _items.removeWhere((e) => e.id == id);

  @override
  Future<void> deleteAll() async => _items.clear();
}
