/// "이번 주 감정 흐름" 그래프 데이터.
class WeeklyEmotionFlow {
  const WeeklyEmotionFlow({
    required this.month,
    required this.days,
    required this.summary,
    this.peakIndex,
    this.peakEmoji,
    this.summaryEmphasis,
  }) : assert(days.length == 7, '월~일 7개');

  /// "✦ 9월"의 9.
  final int month;

  /// 월~일 7개. 0.0~1.0이고 null이면 막대를 그리지 않는다.
  /// (값이 무엇의 수치인지는 백엔드와 정해야 한다: docs/FRONTEND.md)
  final List<double?> days;

  /// 이모지가 얹히는 요일 index (0=월). null이면 이모지 없음.
  final int? peakIndex;
  final String? peakEmoji;

  /// 설명 문장 전체와, 그 안에서 밑줄로 강조할 부분.
  final String summary;
  final String? summaryEmphasis;
}
