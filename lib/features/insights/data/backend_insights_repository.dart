import '../../../core/network/backend_api_client.dart';
import '../models/index_point.dart';
import '../models/insight.dart';
import 'insights_repository.dart';

class BackendInsightsRepository implements InsightsRepository {
  BackendInsightsRepository(this._api);
  final BackendApiClient _api;

  @override
  Future<List<Insight>> list({String? personId}) async {
    final data = await _api.get(
      '/api/insights',
      query: personId == null ? const {} : {'personId': personId},
    );
    return _rows(data).map(_insight).toList(growable: false);
  }

  @override
  Future<Insight?> get(String id) async {
    try {
      return _insight(await _api.get('/api/insights/$id'));
    } on BackendApiException catch (error) {
      if (error.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<void> save(Insight insight) async {
    await _api.put('/api/insights/${insight.id}', _insightJson(insight));
  }

  @override
  Future<void> markRead(String id) async {
    await _api.patch('/api/insights/$id/read', const {});
  }

  @override
  Future<void> deleteForPerson(String personId) async {
    await _api.delete('/api/insights', query: {'personId': personId});
  }

  @override
  Future<void> deleteAll() async {
    await _api.delete('/api/insights');
  }
}

class BackendIndexHistoryRepository implements IndexHistoryRepository {
  BackendIndexHistoryRepository(this._api);
  final BackendApiClient _api;

  @override
  Future<List<IndexPoint>> list(String personId, {DateTime? from}) async {
    final data = await _api.get(
      '/api/index-history',
      query: {'personId': personId, if (from != null) 'from': _date(from)},
    );
    return _rows(data).map(_indexPoint).toList(growable: false);
  }

  @override
  Future<void> upsert(IndexPoint point) async {
    await _api.put('/api/index-history', {
      'person_id': point.personId,
      'date': _date(point.date),
      'index': point.index,
      'entry_count': point.entryCount,
    });
  }

  @override
  Future<void> delete(String personId, DateTime date) async {
    await _api.delete('/api/index-history/$personId/${_date(date)}');
  }

  @override
  Future<void> deleteForPerson(String personId) async {
    await _api.delete('/api/index-history', query: {'personId': personId});
  }

  @override
  Future<void> deleteAll() async {
    await _api.delete('/api/index-history');
  }
}

Insight _insight(Object? value) {
  final row = _object(value);
  final type = switch (row['type'] as String) {
    'negative_trend' => InsightType.negativeTrend,
    'recovery' => InsightType.recovery,
    final other => throw FormatException('Unknown insight type: $other'),
  };
  return Insight(
    id: row['id'] as String,
    type: type,
    personId: row['person_id'] as String,
    message: row['message'] as String,
    evidence: InsightEvidence(
      indexFrom: row['evidence_index_from'] as int,
      indexTo: row['evidence_index_to'] as int,
      negCount: row['evidence_neg_count'] as int?,
    ),
    createdAt: DateTime.parse(row['created_at'] as String),
    read: row['read'] as bool,
  );
}

Map<String, Object?> _insightJson(Insight insight) => {
  'type': insight.type == InsightType.negativeTrend
      ? 'negative_trend'
      : 'recovery',
  'person_id': insight.personId,
  'message': insight.message,
  'evidence_index_from': insight.evidence.indexFrom,
  'evidence_index_to': insight.evidence.indexTo,
  'evidence_neg_count': insight.evidence.negCount,
  'created_at': insight.createdAt.toUtc().toIso8601String(),
  'read': insight.read,
};

IndexPoint _indexPoint(Object? value) {
  final row = _object(value);
  return IndexPoint(
    personId: row['person_id'] as String,
    date: DateTime.parse(row['date'] as String),
    index: row['index'] as int,
    entryCount: row['entry_count'] as int,
  );
}

String _date(DateTime date) => date.toIso8601String().substring(0, 10);
List<Object?> _rows(Object? value) => value as List<Object?>;
Map<String, dynamic> _object(Object? value) =>
    Map<String, dynamic>.from(value! as Map);
