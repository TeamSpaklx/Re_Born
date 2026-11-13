import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/features/analysis/insight_detector.dart';
import 'package:reborn_app/features/entries/models/emotion.dart';
import 'package:reborn_app/features/entries/models/entry.dart';
import 'package:reborn_app/features/insights/models/insight.dart';
import 'package:reborn_app/features/people/models/person.dart';
import 'package:reborn_app/features/people/models/relation_type.dart';

void main() {
  final now = DateTime(2026, 10, 22, 12);
  DateTime ago(int d) => DateTime(2026, 10, 22 - d, 20);
  final person = Person(
    id: 'p1',
    name: '하은',
    relationType: RelationType.friend,
    createdAt: ago(40),
  );
  var n = 0;
  Entry e(int daysAgo, int score) => Entry(
    id: 'e${n++}',
    body: '본문',
    emotion: score < 0 ? Emotion.sadness : Emotion.joy,
    intensity: score.abs().clamp(1, 3),
    score: score,
    createdAt: ago(daysAgo),
    personId: person.id,
  );

  // 10일 전에는 좋았고(지수 높음) 최근 10일 안에 부정 기록이 3건 이상.
  List<Entry> negativeScenario() => [
    e(12, 2),
    e(13, 2),
    e(11, 2),
    e(1, -2),
    e(2, -2),
    e(3, -2),
  ];

  test('T-24: 부정 추세 인사이트가 1개 만들어지고 근거가 계산값이다', () {
    final insight = InsightDetector.detect(
      person: person,
      entries: negativeScenario(),
      existing: const [],
      now: now,
      newId: 'i1',
    );
    expect(insight, isNotNull);
    expect(insight!.type, InsightType.negativeTrend);
    expect(insight.evidence.negCount, 3);
    expect(
      insight.evidence.indexFrom - insight.evidence.indexTo,
      greaterThanOrEqualTo(10),
    );
  });

  test('T-24: 같은 인물·유형이 7일 안에 이미 있으면 중복 생성하지 않는다', () {
    final first = InsightDetector.detect(
      person: person,
      entries: negativeScenario(),
      existing: const [],
      now: now,
      newId: 'i1',
    )!;
    final second = InsightDetector.detect(
      person: person,
      entries: negativeScenario(),
      existing: [first],
      now: now,
      newId: 'i2',
    );
    expect(second, isNull);
  });

  test('T-25: 부정 기록이 2건뿐이면 생성하지 않는다', () {
    final insight = InsightDetector.detect(
      person: person,
      entries: [e(12, 2), e(13, 2), e(11, 2), e(1, -2), e(2, -2), e(3, 1)],
      existing: const [],
      now: now,
      newId: 'i1',
    );
    expect(insight, isNull);
  });

  test('회복 추세: 지수가 14일 전보다 10점 이상 높으면 만든다', () {
    final insight = InsightDetector.detect(
      person: person,
      entries: [
        e(17, -2), e(18, -2), e(16, -2), // 14일 전 지수 낮음
        e(1, 2), e(2, 2), e(3, 2),
      ],
      existing: const [],
      now: now,
      newId: 'i1',
    );
    expect(insight, isNotNull);
    expect(insight!.type, InsightType.recovery);
  });
}
