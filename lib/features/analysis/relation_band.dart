/// 관계 지수(0~100)를 사람이 읽는 세 구간으로 나눈다 (SPEC F-06 표시용). 순수 함수.
///
/// 지수 50은 기록 점수 평균 0(좋지도 나쁘지도 않음)이다. 구간 경계는 SPEC에 없어
/// 프론트에서 정한 **추정값**이다(docs/FRONTEND.md). 바꿀 때는 [distantMax]·[closeMin]만 고친다.
enum RelationBand {
  /// 0~39: 최근 기록이 대체로 부정적이다.
  distant('조금 멀어졌어요'),

  /// 40~64: 좋고 나쁨이 섞여 있다.
  steady('무난해요'),

  /// 65~100: 최근 기록이 대체로 긍정적이다.
  close('가까워요');

  const RelationBand(this.label);

  /// 화면에 보이는 한 줄 설명.
  final String label;

  /// 이 값 이하면 [distant].
  static const distantMax = 39;

  /// 이 값 이상이면 [close].
  static const closeMin = 65;

  static RelationBand of(int index) {
    if (index <= distantMax) return RelationBand.distant;
    if (index >= closeMin) return RelationBand.close;
    return RelationBand.steady;
  }
}
