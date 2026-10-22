import 'dart:io';

import 'package:flutter/services.dart';

/// 테스트에서도 실제 Pretendard로 글자를 그리게 한다(기본은 모든 글자가 같은 폭의 테스트용 글꼴).
/// 글자 폭에 따라 줄이 바뀌는 화면(예: 기록 완료 문구)을 실제와 같게 확인할 때 `setUpAll`에서 부른다.
Future<void> loadPretendard() async {
  final loader = FontLoader('Pretendard');
  for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold']) {
    final bytes = File('assets/fonts/Pretendard-$weight.otf').readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}
