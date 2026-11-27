import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/data_providers.dart';
import '../../../app/data_revision.dart';
import '../../ai_comment/models/ai_feedback.dart';
import '../models/emotion.dart';
import '../models/entry.dart';

/// 일기 목록(최근 것이 먼저). 데이터가 바뀌면 다시 불러온다.
final entriesProvider = FutureProvider<List<Entry>>((ref) {
  ref.watch(dataRevisionProvider);
  return ref.watch(entriesRepositoryProvider).list();
});

/// 일기 한 건. 없으면 null.
final entryProvider = FutureProvider.family<Entry?, String>((ref, id) {
  ref.watch(dataRevisionProvider);
  return ref.watch(entriesRepositoryProvider).get(id);
});

/// 일기 저장·수정·삭제·재분석. 끝나면 목록들이 다시 불러오도록 알린다.
///
/// 저장·수정은 규칙 분석까지 마치고 바로 돌아오고, AI 코멘트는 뒤에서 받아 온다.
/// 코멘트가 도착하면 다시 알려서 결과 화면·상세·홈이 코멘트를 그린다.
class RecordActions {
  RecordActions(this._ref);

  final Ref _ref;

  Future<Entry> save({
    required String body,
    required Emotion emotion,
    required int intensity,
  }) async {
    final result = await _ref
        .read(analysisServiceProvider)
        .saveEntry(body: body.trim(), emotion: emotion, intensity: intensity);
    _bump();
    unawaited(_requestFeedback(result.id));
    return result;
  }

  Future<Entry> update(Entry edited) async {
    final result = await _ref.read(analysisServiceProvider).updateEntry(edited);
    _bump();
    unawaited(_requestFeedback(result.id));
    return result;
  }

  Future<void> delete(String id) async {
    await _ref.read(analysisServiceProvider).deleteEntry(id);
    _bump();
  }

  Future<void> retryAnalysis(String id) async {
    final tone = await _tone();
    await _ref.read(analysisServiceProvider).retryAnalysis(id, tone: tone);
    _bump();
  }

  Future<void> _requestFeedback(String id) async {
    final tone = await _tone();
    await _ref.read(analysisServiceProvider).requestFeedback(id, tone: tone);
    _bump();
  }

  Future<CommentTone> _tone() async {
    try {
      return (await _ref.read(settingsRepositoryProvider).get()).commentTone;
    } catch (_) {
      return CommentTone.warm;
    }
  }

  void _bump() => _ref.read(dataRevisionProvider.notifier).bump();
}

final recordActionsProvider = Provider<RecordActions>(RecordActions.new);
