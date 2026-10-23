/// 감정 종류와 극성 (SPEC F-03). 8종과 극성은 **팀 확인 전까지 제안값**이다(SPEC 11장 4번).
enum Emotion {
  joy('기쁨', 1),
  gratitude('감사', 1),
  excitement('설렘', 1),
  calm('평온', 0),
  hurt('서운함', -1),
  anxiety('불안', -1),
  anger('분노', -1),
  sadness('슬픔', -1);

  const Emotion(this.label, this.polarity);

  final String label;

  /// 긍정 +1, 중립 0, 부정 −1.
  final int polarity;

  bool get isNegative => polarity < 0;

  /// 점수 = 극성 × 강도(1~3) → −3~+3.
  int scoreFor(int intensity) => polarity * intensity;
}
