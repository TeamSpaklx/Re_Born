import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/features/analysis/relation_index.dart';
import 'package:reborn_app/features/entries/models/emotion.dart';
import 'package:reborn_app/features/entries/models/entry.dart';

Entry entry(DateTime day, int score) => Entry(
  id: '$day$score',
  body: '본문',
  emotion: score < 0 ? Emotion.hurt : Emotion.joy,
  intensity: score.abs().clamp(1, 3),
  score: score,
  createdAt: day,
  personId: 'p1',
);

void main() {
  final now = DateTime(2026, 10, 22, 12);
  DateTime ago(int d) => DateTime(2026, 10, 22 - d, 20);

  test('T-22: 최근 7일 −2·−3, 그 이전 7일 +1 → 가중 평균 −1.8, 지수 20', () {
    final result = RelationIndex.compute([
      entry(ago(1), -2),
      entry(ago(3), -3),
      entry(ago(9), 1),
    ], now);
    expect(result, isNotNull);
    expect(result!.index, 20);
    expect(result.entryCount, 3);
  });

  test('T-23: 14일 안 기록이 3건 미만이면 데이터 부족(null)', () {
    expect(
      RelationIndex.compute([entry(ago(1), -2), entry(ago(3), 1)], now),
      isNull,
    );
  });

  test('14일보다 오래된 기록과 미래 기록은 계산에 쓰지 않는다', () {
    final result = RelationIndex.compute([
      entry(ago(1), 3),
      entry(ago(2), 3),
      entry(ago(3), 3),
      entry(ago(20), -3),
      entry(DateTime(2026, 10, 25), -3),
    ], now);
    expect(result!.index, 100);
    expect(result.entryCount, 3);
  });

  test('같은 입력이면 항상 같은 지수', () {
    final entries = [entry(ago(1), -1), entry(ago(2), 2), entry(ago(8), 0)];
    expect(
      RelationIndex.compute(entries, now)!.index,
      RelationIndex.compute(entries, now)!.index,
    );
  });
}
