import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/core/utils/korean_date.dart';

void main() {
  test('월 일 요일 형태로 만든다', () {
    expect(formatKoreanDate(DateTime(2018, 9, 13)), '9월 13일 목요일');
    expect(formatKoreanDate(DateTime(2026, 10, 19)), '10월 19일 월요일');
    expect(formatKoreanDate(DateTime(2026, 1, 4)), '1월 4일 일요일');
  });
}
