import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 현재 시각을 돌려주는 함수. 테스트에서 고정 시각으로 바꾼다.
typedef Clock = DateTime Function();

final clockProvider = Provider<Clock>((ref) => DateTime.now);
