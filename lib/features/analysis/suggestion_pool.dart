import '../insights/models/insight.dart';

/// 인사이트 유형별 행동 제안 문구 풀 (SPEC F-08). 앱 안 고정 문구이며 권유 표현만 쓴다.
abstract final class SuggestionPool {
  /// 해당 유형에 문구가 없을 때 쓰는 기본 문구.
  static const fallback = '잠시 감정을 정리하고 천천히 대화해 보세요.';

  static List<String> suggestionsFor(InsightType type, String personName) {
    switch (type) {
      case InsightType.negativeTrend:
        return [
          '$personName님에게 가볍게 안부 묻기',
          '오늘은 거리를 두고, 내일 가벼운 간식과 함께 말을 건네 보세요.',
          '$personName님과의 일을 잠시 적어 보며 마음을 정리해 보세요.',
          '$personName님이 좋아하는 이야기로 먼저 말을 걸어 보세요.',
          '서운했던 마음을 한 문장으로 적어 두고, 편할 때 전해 보세요.',
          '$personName님과 함께했던 좋았던 순간을 하나 떠올려 보세요.',
        ];
      case InsightType.recovery:
        return [
          '$personName님에게 고마운 마음을 전해 보세요.',
          '$personName님과 함께한 좋은 순간을 기록해 보세요.',
          '$personName님에게 짧은 안부 메시지를 보내 보세요.',
          '요즘 편해진 이유를 한 줄로 적어 보세요.',
          '$personName님과 함께할 작은 약속을 하나 잡아 보세요.',
        ];
    }
  }

  /// 제안이 1개 이상 있도록 보장한다.
  static List<String> forInsight(InsightType type, String personName) {
    final list = suggestionsFor(type, personName);
    return list.isEmpty ? [fallback] : list;
  }
}
