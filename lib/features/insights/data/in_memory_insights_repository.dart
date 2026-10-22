import '../../../core/utils/dates.dart';
import '../models/index_point.dart';
import '../models/insight.dart';
import 'insights_repository.dart';

/// 메모리에만 두는 인사이트 저장소.
class InMemoryInsightsRepository implements InsightsRepository {
  InMemoryInsightsRepository({List<Insight> initial = const []})
    : _items = [...initial];

  final List<Insight> _items;

  @override
  Future<List<Insight>> list({String? personId}) async {
    final result =
        _items.where((i) => personId == null || i.personId == personId).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(result);
  }

  @override
  Future<Insight?> get(String id) async {
    for (final i in _items) {
      if (i.id == id) return i;
    }
    return null;
  }

  @override
  Future<void> save(Insight insight) async {
    final i = _items.indexWhere((x) => x.id == insight.id);
    if (i >= 0) {
      _items[i] = insight;
    } else {
      _items.add(insight);
    }
  }

  @override
  Future<void> markRead(String id) async {
    final i = _items.indexWhere((x) => x.id == id);
    if (i >= 0) _items[i] = _items[i].copyWith(read: true);
  }

  @override
  Future<void> deleteForPerson(String personId) async =>
      _items.removeWhere((i) => i.personId == personId);

  @override
  Future<void> deleteAll() async => _items.clear();
}

/// 메모리에만 두는 관계 지수 이력 저장소.
class InMemoryIndexHistoryRepository implements IndexHistoryRepository {
  InMemoryIndexHistoryRepository({List<IndexPoint> initial = const []})
    : _items = [...initial];

  final List<IndexPoint> _items;

  @override
  Future<List<IndexPoint>> list(String personId, {DateTime? from}) async {
    final result =
        _items
            .where(
              (p) =>
                  p.personId == personId &&
                  (from == null || !p.date.isBefore(dateOnly(from))),
            )
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
    return List.unmodifiable(result);
  }

  @override
  Future<void> upsert(IndexPoint point) async {
    final date = dateOnly(point.date);
    _items.removeWhere(
      (p) => p.personId == point.personId && dateOnly(p.date) == date,
    );
    _items.add(
      IndexPoint(
        personId: point.personId,
        date: date,
        index: point.index,
        entryCount: point.entryCount,
      ),
    );
  }

  @override
  Future<void> delete(String personId, DateTime date) async {
    final day = dateOnly(date);
    _items.removeWhere(
      (p) => p.personId == personId && dateOnly(p.date) == day,
    );
  }

  @override
  Future<void> deleteForPerson(String personId) async =>
      _items.removeWhere((p) => p.personId == personId);

  @override
  Future<void> deleteAll() async => _items.clear();
}
