import 'action_suggestion.dart';
import 'record_streak.dart';
import 'relation_signal.dart';
import 'weekly_emotion_flow.dart';

/// 홈 화면 하나가 그리는 데이터 (docs/FRONTEND.md 3장).
class HomeSummary {
  const HomeSummary({
    required this.nickname,
    required this.today,
    required this.todayRecorded,
    required this.streak,
    required this.relationSignals,
    required this.weeklyEmotion,
    required this.suggestions,
    this.suggestionsDone = false,
    this.todayEntryId,
    this.todayPeopleCount = 0,
  });

  /// 인사말 "규리님, …"의 규리.
  final String nickname;
  final DateTime today;

  /// true면 기록 완료 카드(After), false면 기록 유도 카드(Before).
  final bool todayRecorded;
  final RecordStreak streak;
  final List<RelationSignal> relationSignals;
  final WeeklyEmotionFlow weeklyEmotion;
  final List<ActionSuggestion> suggestions;

  /// 제안할 인사이트는 있는데 문구를 모두 체크리스트에 담은 경우("오늘 제안을 모두 담았어요").
  final bool suggestionsDone;

  /// 오늘 가장 최근에 쓴 기록("오늘 기록 보기"로 연다). 오늘 기록이 없으면 null.
  final String? todayEntryId;

  /// 오늘 기록에 나온 서로 다른 인물 수(After 카드의 동그란 아바타 개수, 최대 3개를 그린다).
  final int todayPeopleCount;
}
