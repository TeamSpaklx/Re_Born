import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/features/ai_comment/data/ai_comment_service.dart';
import 'package:reborn_app/features/ai_comment/data/fake_ai_comment_service.dart';
import 'package:reborn_app/features/ai_comment/models/ai_feedback.dart';
import 'package:reborn_app/features/analysis/analysis_service.dart';
import 'package:reborn_app/features/analysis/data/sample_data.dart';
import 'package:reborn_app/features/analysis/record_streak_calculator.dart';
import 'package:reborn_app/features/entries/data/in_memory_entries_repository.dart';
import 'package:reborn_app/features/entries/models/emotion.dart';
import 'package:reborn_app/features/entries/models/entry.dart';

/// 항상 실패하는 AI (T-20: AI가 실패해도 기록은 남고 failed).
class _FailingAi implements AiCommentService {
  @override
  Future<AiFeedback> analyze(Entry entry, {required CommentTone tone}) async =>
      throw StateError('네트워크 오류');
}

void main() {
  final now = DateTime(2026, 10, 22, 12);

  AnalysisService build({
    InMemoryEntriesRepository? entries,
    AiCommentService? ai,
  }) => AnalysisService(
    entries: entries ?? InMemoryEntriesRepository(),
    aiComment:
        ai ?? FakeAiCommentService(delay: Duration.zero, clock: () => now),
    clock: () => now,
  );

  test('T-10: 저장하면 규칙 분석까지 끝나 점수 −2·키워드가 붙고, 코멘트는 pending', () async {
    final entries = InMemoryEntriesRepository();
    final service = build(entries: entries);

    final saved = await service.saveEntry(
      body: '친구가 고맙다는 말이 없어 서운했다',
      emotion: Emotion.sadness,
      intensity: 2,
    );

    expect(saved.analysisStatus, AnalysisStatus.pending);
    expect(saved.score, -2);
    expect(saved.analysis!.keywords, contains('서운'));
    expect(saved.feedback, isNull);
    expect((await entries.get(saved.id))!.score, -2);
  });

  test('강도 5단계: 점수는 극성 × 강도라 −5~+5', () async {
    final service = build();
    final sad = await service.saveEntry(
      body: '너무 힘들었다',
      emotion: Emotion.sadness,
      intensity: 5,
    );
    final joy = await service.saveEntry(
      body: '정말 기뻤다',
      emotion: Emotion.joy,
      intensity: 5,
    );
    expect(sad.score, -5);
    expect(joy.score, 5);
  });

  test('AI 코멘트를 받으면 done이 되고 코멘트·제안이 저장된다', () async {
    final entries = InMemoryEntriesRepository();
    final service = build(entries: entries);
    final saved = await service.saveEntry(
      body: '과제가 많아 지쳤다',
      emotion: Emotion.sadness,
      intensity: 3,
    );

    final done = await service.requestFeedback(
      saved.id,
      tone: CommentTone.warm,
    );

    expect(done.analysisStatus, AnalysisStatus.done);
    expect(done.feedback!.comment, isNotEmpty);
    expect(done.feedback!.suggestions, hasLength(3));
    expect(done.analysis!.keywords, isNotNull, reason: '규칙 분석 결과는 그대로 남는다');
    expect((await entries.get(saved.id))!.feedback, isNotNull);
  });

  test('T-20: AI가 실패해도 기록은 남고 failed로 표시된다', () async {
    final entries = InMemoryEntriesRepository();
    final service = build(entries: entries, ai: _FailingAi());
    final saved = await service.saveEntry(
      body: '오늘은 조금 힘들었다',
      emotion: Emotion.sadness,
      intensity: 2,
    );

    final result = await service.requestFeedback(
      saved.id,
      tone: CommentTone.warm,
    );

    expect(result.analysisStatus, AnalysisStatus.failed);
    final stored = await entries.get(saved.id);
    expect(stored, isNotNull);
    expect(stored!.analysisStatus, AnalysisStatus.failed);
  });

  test('다시 분석하면 실패한 기록도 코멘트를 받는다', () async {
    final entries = InMemoryEntriesRepository();
    final failing = build(entries: entries, ai: _FailingAi());
    final saved = await failing.saveEntry(
      body: '오늘은 조금 힘들었다',
      emotion: Emotion.sadness,
      intensity: 2,
    );
    await failing.requestFeedback(saved.id, tone: CommentTone.warm);

    final retried = await build(
      entries: entries,
    ).retryAnalysis(saved.id, tone: CommentTone.warm);
    expect(retried.analysisStatus, AnalysisStatus.done);
    expect(retried.feedback, isNotNull);
  });

  test('수정하면 다시 규칙 분석하고 이전 코멘트는 지운다(새로 받는다)', () async {
    final entries = InMemoryEntriesRepository();
    final service = build(entries: entries);
    final saved = await service.saveEntry(
      body: '기뻤다',
      emotion: Emotion.joy,
      intensity: 2,
    );
    final done = await service.requestFeedback(
      saved.id,
      tone: CommentTone.warm,
    );

    final edited = await service.updateEntry(
      done.copyWith(emotion: Emotion.anger, intensity: 4),
    );
    expect(edited.score, -4);
    expect(edited.analysisStatus, AnalysisStatus.pending);
    expect(edited.feedback, isNull);
  });

  group('샘플 데이터', () {
    final data = buildSampleData(now);

    test('오늘은 기록이 없고, 최근 5일 연속·최장 20일', () {
      final streak = calculateRecordStreak(
        data.entries.map((e) => e.createdAt),
        now,
      );
      expect(
        data.entries.any(
          (e) => e.createdAt.day == now.day && e.createdAt.month == now.month,
        ),
        isFalse,
      );
      expect(streak.current, 5);
      expect(streak.longest, 20);
    });

    test('모든 일기는 분석이 끝났고 AI 코멘트가 붙어 있으며 강도는 1~5', () {
      for (final e in data.entries) {
        expect(e.analysisStatus, AnalysisStatus.done);
        expect(e.feedback, isNotNull);
        expect(e.intensity, inInclusiveRange(1, 5));
      }
    });
  });
}
