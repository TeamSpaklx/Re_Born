import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/features/analysis/relation_band.dart';
import 'package:reborn_app/features/analysis/relation_index.dart';
import 'package:reborn_app/features/entries/models/emotion.dart';
import 'package:reborn_app/features/entries/models/entry.dart';

Entry entry(DateTime day, int score) => Entry(
  id: '$day$score',
  body: '본문',
  emotion: score < 0 ? Emotion.sadness : Emotion.joy,
  intensity: score.abs().clamp(1, 3),
  score: score,
  createdAt: day,
  personId: 'p1',
);

void main() {
  group('관계 지수 구간', () {
    test('경계값: 39까지 멀어짐, 40~64 무난, 65부터 가까움', () {
      expect(RelationBand.of(0), RelationBand.distant);
      expect(RelationBand.of(39), RelationBand.distant);
      expect(RelationBand.of(40), RelationBand.steady);
      expect(RelationBand.of(64), RelationBand.steady);
      expect(RelationBand.of(65), RelationBand.close);
      expect(RelationBand.of(100), RelationBand.close);
    });

    test('구간마다 화면 설명이 있다', () {
      expect(RelationBand.distant.label, '조금 멀어졌어요');
      expect(RelationBand.steady.label, '무난해요');
      expect(RelationBand.close.label, '가까워요');
    });
  });

  group('지난주 대비 지수 변화', () {
    final now = DateTime(2026, 10, 22, 12);
    DateTime ago(int d) => DateTime(2026, 10, 22 - d, 9);

    test('지난주엔 좋았다가 이번 주 나빠지면 음수로 내려간 만큼', () {
      final entries = [
        entry(ago(1), -3),
        entry(ago(2), -2),
        entry(ago(3), -2),
        entry(ago(8), 2),
        entry(ago(9), 3),
        entry(ago(10), 2),
      ];
      final current = RelationIndex.compute(entries, now)!.index;
      final before = RelationIndex.compute(
        entries,
        now.subtract(const Duration(days: 7)),
      )!.index;
      final change = RelationIndex.weeklyChange(entries, now);
      expect(change, current - before);
      expect(change, isNegative);
    });

    test('7일 전에 기록이 3건 미만이면 비교할 수 없어 null', () {
      final entries = [entry(ago(1), 2), entry(ago(2), 1), entry(ago(3), 3)];
      expect(RelationIndex.compute(entries, now), isNotNull);
      expect(RelationIndex.weeklyChange(entries, now), isNull);
    });

    test('지금 데이터가 부족해도 null', () {
      expect(RelationIndex.weeklyChange([entry(ago(1), 2)], now), isNull);
    });
  });
}
