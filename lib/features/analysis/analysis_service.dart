import '../../core/providers/clock_provider.dart';
import '../ai_comment/data/ai_comment_service.dart';
import '../ai_comment/models/ai_feedback.dart';
import '../entries/data/entries_repository.dart';
import '../entries/models/emotion.dart';
import '../entries/models/entry.dart';
import 'emotion_analyzer.dart';

/// 일기 저장 → 앱 안 규칙 분석(점수·키워드) → AI 코멘트로 이어지는 체인 (SPEC 5.2, 6.5).
/// 계산은 순수 함수와 [AiCommentService]가 하고, 이 서비스는 저장소에 읽고 쓰는 순서만 맡는다.
///
/// 저장([saveEntry])은 규칙 분석까지만 하고 `pending`으로 바로 돌아온다.
/// AI 코멘트는 [requestFeedback]이 따로 받아 오고, 끝나면 `done`(실패하면 `failed`)이 된다.
/// 그래서 저장 직후 화면이 "코멘트를 쓰는 중" 상태를 보여 줄 수 있다.
class AnalysisService {
  AnalysisService({
    required this.entries,
    required this.aiComment,
    required this.clock,
    this.onError,
  });

  final EntriesRepository entries;
  final AiCommentService aiComment;
  final Clock clock;

  /// 분석 중 오류를 알리는 곳(앱 안 오류 기록). 없어도 동작한다.
  final void Function(Object error, StackTrace stack)? onError;

  /// 새 일기를 저장하고 규칙 분석을 한다. AI 코멘트는 [requestFeedback]으로 받는다.
  Future<Entry> saveEntry({
    required String body,
    required Emotion emotion,
    required int intensity,
    DateTime? createdAt,
  }) async {
    final now = clock();
    final created = await entries.create(
      body: body,
      emotion: emotion,
      intensity: intensity,
      score: emotion.scoreFor(intensity),
      createdAt: createdAt ?? now,
    );
    return _ruleAnalyze(created);
  }

  /// 일기를 고친다. 다시 규칙 분석하고 `pending`이 된다(코멘트는 [requestFeedback]으로 다시 받는다).
  Future<Entry> updateEntry(Entry edited) => _ruleAnalyze(edited);

  Future<void> deleteEntry(String id) => entries.delete(id);

  /// AI 코멘트를 받아 저장한다. 실패해도 일기는 남고 `failed`로 표시된다.
  Future<Entry> requestFeedback(String id, {required CommentTone tone}) async {
    final target = await entries.get(id);
    if (target == null) throw StateError('기록을 찾을 수 없어요.');
    try {
      final feedback = await aiComment.analyze(target, tone: tone);
      // 기다리는 동안 지워졌거나 고쳐졌을 수 있으니 최신 것을 다시 읽는다.
      final latest = await entries.get(id);
      if (latest == null) return target;
      final base =
          latest.analysis ??
          EntryAnalysis(keywords: const [], analyzedAt: clock());
      final done = latest.copyWith(
        analysis: base.withFeedback(feedback),
        analysisStatus: AnalysisStatus.done,
      );
      await entries.update(done);
      return done;
    } catch (error, stack) {
      onError?.call(error, stack);
      final latest = await entries.get(id) ?? target;
      final failed = latest.copyWith(analysisStatus: AnalysisStatus.failed);
      await entries.update(failed);
      return failed;
    }
  }

  /// 분석에 실패한 일기를 처음부터 다시 분석한다.
  Future<Entry> retryAnalysis(String id, {required CommentTone tone}) async {
    final target = await entries.get(id);
    if (target == null) throw StateError('기록을 찾을 수 없어요.');
    await _ruleAnalyze(target);
    return requestFeedback(id, tone: tone);
  }

  Future<Entry> _ruleAnalyze(Entry entry) async {
    final result = EmotionAnalyzer.analyze(
      body: entry.body,
      emotion: entry.emotion,
      intensity: entry.intensity,
      now: clock(),
    );
    final analyzed = Entry(
      id: entry.id,
      body: entry.body,
      emotion: entry.emotion,
      intensity: entry.intensity,
      score: result.score,
      createdAt: entry.createdAt,
      analysisStatus: AnalysisStatus.pending,
      analysis: result.analysis,
    );
    await entries.update(analyzed);
    return analyzed;
  }
}
