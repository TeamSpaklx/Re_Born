import '../entries/models/emotion.dart';
import '../entries/models/entry.dart';

/// 기록 1건의 규칙 기반 감정 분석 (SPEC F-05). 같은 입력에는 항상 같은 결과가 나온다.
/// 외부 AI·서버를 쓰지 않고 앱 안에서만 계산한다.
abstract final class EmotionAnalyzer {
  /// 본문에서 찾을 감정 단어 목록 (제안값, 팀이 늘려 갈 수 있다). 앞에 있을수록 먼저 센다.
  static const keywordList = [
    '서운',
    '섭섭',
    '고마',
    '감사',
    '기쁘',
    '행복',
    '설레',
    '불안',
    '걱정',
    '화가',
    '짜증',
    '슬프',
    '외롭',
    '미안',
    '편안',
    '평온',
    '사과',
    '무시',
    '응원',
    '칭찬',
  ];

  static const maxKeywords = 5;

  /// 점수와 키워드. 점수는 사용자가 고른 감정과 강도에서만 나온다.
  static ({int score, EntryAnalysis analysis}) analyze({
    required String body,
    required Emotion emotion,
    required int intensity,
    required DateTime now,
  }) {
    final found = <String>[];
    for (final word in keywordList) {
      if (body.contains(word) && !found.contains(word)) found.add(word);
    }
    return (
      score: emotion.scoreFor(intensity),
      analysis: EntryAnalysis(
        keywords: found.take(maxKeywords).toList(),
        analyzedAt: now,
      ),
    );
  }
}
