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
}
