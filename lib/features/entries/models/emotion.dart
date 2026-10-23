/// 감정 종류와 극성 (SPEC F-03). 7종은 캐릭터 시안(RebornMood)에 맞췄고 극성은 **팀 확인 전까지 제안값**이다(SPEC 11장 4번).
/// 순서는 시안 순서(기쁨·슬픔·무표정·화남·불안함·사랑·신남)다.
enum Emotion {
  joy('기쁨', 1),
  sadness('슬픔', -1),
  neutral('무표정', 0),
  anger('화남', -1),
  anxiety('불안함', -1),
  love('사랑', 1),
  excited('신남', 1);

  const Emotion(this.label, this.polarity);

  final String label;

  /// 긍정 +1, 중립 0, 부정 −1.
  final int polarity;

  bool get isNegative => polarity < 0;

  /// 점수 = 극성 × 강도(1~3) → −3~+3.
  int scoreFor(int intensity) => polarity * intensity;
}
