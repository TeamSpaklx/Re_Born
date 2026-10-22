import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/data_providers.dart';
import '../../../app/data_revision.dart';
import '../models/emotion.dart';
import '../models/entry.dart';

/// 기록 목록(최근 것이 먼저). 데이터가 바뀌면 다시 불러온다.
final entriesProvider = FutureProvider<List<Entry>>((ref) {
  ref.watch(dataRevisionProvider);
  return ref.watch(entriesRepositoryProvider).list();
});

/// 한 인물의 기록(최근 것이 먼저).
final entriesForPersonProvider = FutureProvider.family<List<Entry>, String>((
  ref,
  personId,
) {
  ref.watch(dataRevisionProvider);
  return ref.watch(entriesRepositoryProvider).list(personId: personId);
});

/// 기록 한 건. 없으면 null.
final entryProvider = FutureProvider.family<Entry?, String>((ref, id) {
  ref.watch(dataRevisionProvider);
  return ref.watch(entriesRepositoryProvider).get(id);
});

/// 기록 저장·수정·삭제·재분석. 끝나면 목록들이 다시 불러오도록 알린다.
class RecordActions {
  RecordActions(this._ref);

  final Ref _ref;

  Future<Entry> save({
    required String body,
    required Emotion emotion,
    required int intensity,
    String? personId,
  }) async {
    final result = await _ref
        .read(analysisServiceProvider)
        .saveEntry(
          body: body.trim(),
          emotion: emotion,
          intensity: intensity,
          personId: personId,
        );
    _ref.read(dataRevisionProvider.notifier).bump();
    return result;
  }

  Future<Entry> update(Entry edited) async {
    final result = await _ref.read(analysisServiceProvider).updateEntry(edited);
    _ref.read(dataRevisionProvider.notifier).bump();
    return result;
  }

  Future<void> delete(String id) async {
    await _ref.read(analysisServiceProvider).deleteEntry(id);
    _ref.read(dataRevisionProvider.notifier).bump();
  }

  Future<void> retryAnalysis(String id) async {
    await _ref.read(analysisServiceProvider).retryAnalysis(id);
    _ref.read(dataRevisionProvider.notifier).bump();
  }
}

final recordActionsProvider = Provider<RecordActions>(RecordActions.new);
