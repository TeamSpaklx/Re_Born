import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 홈 인사말 문구 풀. `{n}`은 닉네임으로 바뀐다. 줄바꿈 위치는 디자인(두 줄)에 맞춘다.
/// 문구는 Figma에 없어 정한 임시값이다(팀 확인 필요).
abstract final class GreetingPool {
  static const messages = [
    '{n}님, 오늘도 즐거운\n하루 보내세요!',
    '{n}님, 오늘 마음은\n어떤가요?',
    '{n}님, 반가워요!\n오늘도 천천히 기록해 봐요.',
    '{n}님, 오늘 하루도\n수고 많았어요.',
    '{n}님, 작은 마음도\n소중하게 남겨 봐요.',
    '{n}님, 오늘은 누구와\n마음을 나눴나요?',
    '{n}님, 오늘의 마음을\n한 줄로 남겨 볼까요?',
    '{n}님, 오늘도 잘 왔어요.\n편하게 시작해 봐요.',
  ];

  static String format(int index, String nickname) =>
      messages[index % messages.length].replaceAll('{n}', nickname);
}

/// 앱을 켤 때 한 번 뽑는 인사말 번호. 같은 실행 동안은 바뀌지 않아 화면이 다시 그려져도 깜빡이지 않는다.
final greetingIndexProvider = Provider<int>(
  (ref) => Random().nextInt(GreetingPool.messages.length),
);
