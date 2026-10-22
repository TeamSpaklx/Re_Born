import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/features/insights/models/graph_period.dart';
import 'package:reborn_app/features/insights/models/index_point.dart';

void main() {
  final now = DateTime(2026, 10, 22, 12);
  IndexPoint point(int daysAgo, int index) => IndexPoint(
    personId: 'p1',
    date: DateTime(2026, 10, 22 - daysAgo),
    index: index,
    entryCount: 3,
  );
  final all = [
    point(100, 80),
    point(40, 70),
    point(10, 60),
    point(3, 50),
    point(0, 40),
  ];

  test('기간별로 점을 걸러 낸다 (1주·1개월·3개월·전체)', () {
    expect(GraphPeriod.week.filter(all, now).map((p) => p.index), [50, 40]);
    expect(GraphPeriod.month.filter(all, now).map((p) => p.index), [
      60,
      50,
      40,
    ]);
    expect(GraphPeriod.threeMonths.filter(all, now).map((p) => p.index), [
      70,
      60,
      50,
      40,
    ]);
    expect(GraphPeriod.all.filter(all, now), hasLength(5));
  });

  test('T-27: 시작 대비 변화량은 마지막 지수 − 첫 지수, 점이 2개 미만이면 null', () {
    expect(indexChange([point(10, 60), point(0, 40)]), -20);
    expect(indexChange([point(0, 40)]), isNull);
    expect(indexChange(const []), isNull);
  });
}
