import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/features/entries/models/intensity_level.dart';

void main() {
  test('기준표는 1~5단계이고 회의에서 정한 이름을 쓴다', () {
    expect(IntensityLevel.values.map((l) => l.value), [1, 2, 3, 4, 5]);
    expect(IntensityLevel.values.map((l) => l.label), [
      '감지됨',
      '의식됨',
      '영향 있음',
      '크게 영향',
      '압도됨',
    ]);
    for (final l in IntensityLevel.values) {
      expect(l.description, isNotEmpty);
    }
  });

  test('of: 1~5만 단계로 바꾸고 나머지는 null', () {
    expect(IntensityLevel.of(3), IntensityLevel.affecting);
    expect(IntensityLevel.of(0), isNull);
    expect(IntensityLevel.of(6), isNull);
    expect(IntensityLevel.of(null), isNull);
  });
}
