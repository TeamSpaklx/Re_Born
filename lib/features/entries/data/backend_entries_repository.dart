import '../../../core/network/backend_api_client.dart';
import '../models/emotion.dart';
import '../models/entry.dart';
import 'entries_repository.dart';

class BackendEntriesRepository implements EntriesRepository {
  BackendEntriesRepository(this._api);
  final BackendApiClient _api;

  @override
  Future<List<Entry>> list({String? personId}) async {
    final data = await _api.get(
      '/api/entries',
      query: personId == null ? const {} : {'personId': personId},
    );
    return _rows(data).map(_entry).toList(growable: false);
  }

  @override
  Future<Entry?> get(String id) async {
    try {
      return _entry(await _api.get('/api/entries/$id'));
    } on BackendApiException catch (error) {
      if (error.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<Entry> create({
    required String body,
    required Emotion emotion,
    required int intensity,
    required int score,
    required DateTime createdAt,
    String? personId,
  }) async => _entry(
    await _api.post('/api/entries', {
      'body': body,
      'person_id': personId,
      'emotion': emotion.name,
      'intensity': intensity,
      'score': score,
      'created_at': createdAt.toUtc().toIso8601String(),
      'analysis_status': 'pending',
      'analysis_keywords': <String>[],
      'analyzed_at': null,
    }),
  );

  @override
  Future<void> update(Entry entry) async {
    await _api.put('/api/entries/${entry.id}', _entryJson(entry));
  }

  @override
  Future<void> delete(String id) async {
    await _api.delete('/api/entries/$id');
  }

  @override
  Future<void> deleteAll() async {
    await _api.delete('/api/entries');
  }
}

Entry _entry(Object? value) {
  final row = _object(value);
  final createdAt = DateTime.parse(row['created_at'] as String);
  final analyzedAt = row['analyzed_at'] == null
      ? null
      : DateTime.parse(row['analyzed_at'] as String);
  final keywords = (row['analysis_keywords'] as List<Object?>? ?? const [])
      .cast<String>();
  final status = AnalysisStatus.values.byName(row['analysis_status'] as String);
  return Entry(
    id: row['id'] as String,
    body: row['body'] as String,
    personId: row['person_id'] as String?,
    emotion: Emotion.values.byName(row['emotion'] as String),
    intensity: row['intensity'] as int,
    score: row['score'] as int,
    createdAt: createdAt,
    analysisStatus: status,
    analysis:
        status == AnalysisStatus.pending &&
            analyzedAt == null &&
            keywords.isEmpty
        ? null
        : EntryAnalysis(
            keywords: keywords,
            analyzedAt: analyzedAt ?? createdAt,
          ),
  );
}

Map<String, Object?> _entryJson(Entry entry) => {
  'body': entry.body,
  'person_id': entry.personId,
  'emotion': entry.emotion.name,
  'intensity': entry.intensity,
  'score': entry.score,
  'created_at': entry.createdAt.toUtc().toIso8601String(),
  'analysis_status': entry.analysisStatus.name,
  'analysis_keywords': entry.analysis?.keywords ?? <String>[],
  'analyzed_at': entry.analysis?.analyzedAt.toUtc().toIso8601String(),
};

List<Object?> _rows(Object? value) => value as List<Object?>;
Map<String, dynamic> _object(Object? value) =>
    Map<String, dynamic>.from(value! as Map);
