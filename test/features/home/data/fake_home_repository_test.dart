import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/app/theme/app_spacing.dart';
import 'package:reborn_app/features/home/data/fake_home_repository.dart';

void main() {
  final today = DateTime(2018, 9, 13);

  test('Figma 샘플 값으로 채운다', () async {
    final home = await const FakeHomeRepository().fetchHome(today);

    expect(home.nickname, '규리');
    expect(home.today, today);
    expect(home.todayRecorded, isFalse);
    expect(home.relationSignals.single.personName, '지민');
    expect(home.relationSignals.single.daysSinceLastRecord, 5);
    expect(home.suggestions.map((s) => s.title), [
      '지민님에게 가볍게 안부 묻기',
      '승현님에게 가볍게 안부 묻기',
    ]);
  });

  test('주간 그래프: 7일, 일요일은 값 없음, 값은 0~1, 금요일이 가장 높다', () async {
    final flow = (await const FakeHomeRepository().fetchHome(
      today,
    )).weeklyEmotion;

    expect(flow.days, hasLength(7));
    expect(flow.days.last, isNull);
    for (final v in flow.days.whereType<double>()) {
      expect(v, inInclusiveRange(0, 1));
    }
    expect(flow.days[4], 1.0);
    expect(flow.peakIndex, 4);
    expect(flow.days[0]! * GraphLayout.maxBarHeight, closeTo(9, 0.001));
    expect(flow.days[5]! * GraphLayout.maxBarHeight, closeTo(66, 0.001));
  });

  test('todayRecorded를 주입할 수 있다', () async {
    final home = await const FakeHomeRepository(
      todayRecorded: true,
    ).fetchHome(today);
    expect(home.todayRecorded, isTrue);
  });

  test('error를 지정하면 실패한다', () {
    expect(
      const FakeHomeRepository(error: 'boom').fetchHome(today),
      throwsA('boom'),
    );
  });
}
