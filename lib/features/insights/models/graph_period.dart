import '../../../core/utils/dates.dart';
import 'index_point.dart';

/// 관계 히스토리 그래프의 기간 선택 (SPEC F-09: 1주·1개월·3개월·전체).
enum GraphPeriod {
  week('1주', 7),
  month('1개월', 30),
  threeMonths('3개월', 90),
  all('전체', null);

  const GraphPeriod(this.label, this.days);

  final String label;

  /// 오늘 포함 며칠. null이면 전체.
  final int? days;

  /// [points](날짜 오름차순)에서 이 기간 안의 것만 남긴다.
  List<IndexPoint> filter(List<IndexPoint> points, DateTime now) {
    final d = days;
    if (d == null) return points;
    return [
      for (final p in points)
        if (daysBetween(p.date, now) < d && daysBetween(p.date, now) >= 0) p,
    ];
  }
}

/// 기간 안에서 시작 대비 현재 지수 변화량. 점이 2개 미만이면 null.
int? indexChange(List<IndexPoint> points) {
  if (points.length < 2) return null;
  return points.last.index - points.first.index;
}
