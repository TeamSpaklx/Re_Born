import '../../../app/theme/app_spacing.dart';
import '../models/action_suggestion.dart';
import '../models/home_summary.dart';
import '../models/record_streak.dart';
import '../models/relation_signal.dart';
import '../models/weekly_emotion_flow.dart';
import 'home_repository.dart';

/// Figma 샘플 값으로 홈을 채우는 메모리 구현. 백엔드 연결 전에 화면을 만들 때 쓴다.
class FakeHomeRepository implements HomeRepository {
  const FakeHomeRepository({
    this.todayRecorded = false,
    this.latency = Duration.zero,
    this.error,
  });

  final bool todayRecorded;

  /// 불러오는 시간을 흉내 낸다.
  final Duration latency;

  /// 지정하면 불러오기에 이 예외로 실패한다(오류 화면 확인용).
  final Object? error;

  @override
  Future<HomeSummary> fetchHome(DateTime today) async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    if (error != null) throw error!;

    // Figma 막대 높이(월~토 9, 21, 48, 36, 75.806, 66)를 최대 높이로 나눈 값. 일요일은 기록 없음.
    const heights = [9.0, 21.0, 48.0, 36.0, GraphLayout.maxBarHeight, 66.0];
    return HomeSummary(
      nickname: '규리',
      today: today,
      todayRecorded: todayRecorded,
      streak: const RecordStreak(current: 6, longest: 20),
      relationSignals: const [
        RelationSignal(
          personId: 'jimin',
          personName: '지민',
          relationType: RelationType.friend,
          message: '최근 대화가 조금 줄었어요',
          daysSinceLastRecord: 5,
        ),
      ],
      weeklyEmotion: WeeklyEmotionFlow(
        month: 9,
        days: [for (final h in heights) h / GraphLayout.maxBarHeight, null],
        peakIndex: 4,
        peakEmoji: '😁',
        summary: '긍정적인 감정이 조금씩 증가하고 있어요.',
        summaryEmphasis: '조금씩 증가',
      ),
      suggestions: const [
        ActionSuggestion(
          id: 'jimin-checkin',
          personId: 'jimin',
          title: '지민님에게 가볍게 안부 묻기',
          reason: '최근 대화가 조금 줄었어요',
        ),
        ActionSuggestion(
          id: 'seunghyun-checkin',
          personId: 'seunghyun',
          title: '승현님에게 가볍게 안부 묻기',
          reason: '최근 대화가 조금 줄었어요',
        ),
      ],
    );
  }
}
