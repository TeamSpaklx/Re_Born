import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/features/ai_comment/data/fake_ai_comment_service.dart';
import 'package:reborn_app/features/ai_comment/models/ai_feedback.dart';
import 'package:reborn_app/features/entries/models/emotion.dart';
import 'package:reborn_app/features/entries/models/entry.dart';

void main() {
  final now = DateTime(2026, 11, 28, 21);
  Entry entry(Emotion emotion, int intensity, [String body = '오늘 있었던 일']) =>
      Entry(
        id: 'e1',
        body: body,
        emotion: emotion,
        intensity: intensity,
        score: emotion.scoreFor(intensity),
        createdAt: now,
      );

  test('같은 일기에는 항상 같은 코멘트와 제안 3개', () {
    final a = FakeAiCommentService.compose(
      entry(Emotion.sadness, 3),
      tone: CommentTone.warm,
      now: now,
    );
    final b = FakeAiCommentService.compose(
      entry(Emotion.sadness, 3),
      tone: CommentTone.warm,
      now: now,
    );
    expect(a.comment, b.comment);
    expect(a.suggestions, b.suggestions);
    expect(a.suggestions, hasLength(3));
    expect(a.suggestions.toSet(), hasLength(3), reason: '제안이 겹치지 않는다');
  });

  test('감정 방향·강도·말투에 따라 다른 문장 풀에서 고른다', () {
    String comment(Emotion e, int i, CommentTone t) =>
        FakeAiCommentService.compose(entry(e, i), tone: t, now: now).comment;
    final results = {
      for (final e in [Emotion.joy, Emotion.neutral, Emotion.sadness])
        for (final i in [1, 3, 5])
          for (final t in CommentTone.values) comment(e, i, t),
    };
    expect(results.length, greaterThan(10));
    expect(
      comment(Emotion.sadness, 3, CommentTone.warm),
      isNot(comment(Emotion.joy, 3, CommentTone.warm)),
    );
  });

  test('analyze는 기다린 뒤 지금 시각으로 코멘트를 만든다', () async {
    final service = FakeAiCommentService(
      delay: Duration.zero,
      clock: () => now,
    );
    final feedback = await service.analyze(
      entry(Emotion.joy, 2),
      tone: CommentTone.plain,
    );
    expect(feedback.createdAt, now);
    expect(feedback.comment, isNotEmpty);
  });
}
