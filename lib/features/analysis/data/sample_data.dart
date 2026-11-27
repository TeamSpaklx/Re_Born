import '../../../core/utils/dates.dart';
import '../../ai_comment/data/fake_ai_comment_service.dart';
import '../../entries/models/emotion.dart';
import '../../entries/models/entry.dart';
import '../../settings/models/app_settings.dart';
import '../../todos/models/todo.dart';
import '../emotion_analyzer.dart';

/// 백엔드가 붙기 전에 앱을 켜면 들어 있는 샘플 데이터.
/// 오늘은 아직 기록이 없어 홈이 "기록 전" 상태이고, 최근 5일 연속 기록(최장 20일)이 있다.
/// 모든 일기에는 가짜 AI 코멘트가 붙어 있다.
class SampleData {
  const SampleData({
    required this.settings,
    required this.entries,
    required this.todos,
  });

  final AppSettings settings;
  final List<Entry> entries;
  final List<Todo> todos;
}

SampleData buildSampleData(DateTime now) {
  final today = dateOnly(now);
  DateTime day(int daysAgo, [int hour = 21]) =>
      DateTime(today.year, today.month, today.day - daysAgo, hour);

  const settings = AppSettings(nickname: '규리');
  var entryCount = 0;
  Entry entry(int daysAgo, Emotion emotion, int intensity, String body) {
    entryCount++;
    final createdAt = day(daysAgo);
    final analyzed = EmotionAnalyzer.analyze(
      body: body,
      emotion: emotion,
      intensity: intensity,
      now: createdAt,
    );
    final draft = Entry(
      id: 'e$entryCount',
      body: body,
      emotion: emotion,
      intensity: intensity,
      score: analyzed.score,
      createdAt: createdAt,
    );
    final feedback = FakeAiCommentService.compose(
      draft,
      tone: settings.commentTone,
      now: createdAt,
    );
    return draft.copyWith(
      analysisStatus: AnalysisStatus.done,
      analysis: analyzed.analysis.withFeedback(feedback),
    );
  }

  const older = [
    (Emotion.joy, 2, '친구들과 저녁을 먹으며 많이 웃었다. 행복한 하루였다.'),
    (Emotion.love, 3, '가족이 응원해 줘서 고마운 마음이 들었다.'),
    (Emotion.neutral, 1, '평소와 비슷한 하루. 조용히 할 일을 했다.'),
    (Emotion.excited, 3, '주말 여행 계획을 세우니 설레었다.'),
    (Emotion.anxiety, 2, '발표 준비가 덜 돼서 조금 걱정됐다.'),
  ];

  final entries = <Entry>[
    // 오래전(11~30일 전) 20일 연속.
    for (var d = 30; d >= 11; d--)
      entry(
        d,
        older[d % older.length].$1,
        older[d % older.length].$2,
        older[d % older.length].$3,
      ),
    entry(9, Emotion.love, 2, '도와준 친구에게 고마웠다.'),
    // 최근 5일 연속: 지치고 서운한 날이 이어진다.
    entry(5, Emotion.sadness, 3, '답장을 늦게 받아서 서운했다. 하루 종일 신경이 쓰였다.'),
    entry(4, Emotion.joy, 2, '점심을 맛있게 먹어서 기뻤다.'),
    entry(3, Emotion.neutral, 1, '조용히 산책을 하며 마음이 평온했다.'),
    entry(2, Emotion.anxiety, 4, '시험이 다가와서 불안하다. 집중이 잘 안 된다.'),
    entry(1, Emotion.sadness, 3, '과제가 많아 지쳤다. 아무것도 하기 싫었다.'),
  ];

  return SampleData(
    settings: settings,
    entries: entries,
    todos: [
      // 이틀 전 일기의 AI 제안 하나를 담아 둔 상태.
      Todo(
        id: 't1',
        title: entries[entries.length - 2].feedback!.suggestions.first,
        source: TodoSource.suggestion,
        entryId: entries[entries.length - 2].id,
        createdAt: day(2),
      ),
      Todo(
        id: 't2',
        title: '이번 주 일기 3번 쓰기',
        done: true,
        doneAt: day(1),
        createdAt: day(3),
      ),
    ],
  );
}
