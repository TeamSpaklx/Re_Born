import '../../../core/utils/dates.dart';
import '../../entries/models/emotion.dart';
import '../../entries/models/entry.dart';
import '../../insights/models/index_point.dart';
import '../../insights/models/insight.dart';
import '../../people/models/person.dart';
import '../../people/models/relation_type.dart';
import '../../settings/models/app_settings.dart';
import '../../todos/models/todo.dart';
import '../emotion_analyzer.dart';
import '../insight_detector.dart';
import '../relation_index.dart';

/// 백엔드가 붙기 전에 앱을 켜면 들어 있는 샘플 데이터 (Figma 홈 샘플과 같은 모양).
/// 오늘은 아직 기록이 없어 홈이 "기록 전" 상태이고, 최근 5일 연속 기록(최장 20일),
/// 지민과의 부정 추세 인사이트가 들어 있다.
class SampleData {
  const SampleData({
    required this.settings,
    required this.people,
    required this.entries,
    required this.indexPoints,
    required this.insights,
    required this.todos,
  });

  final AppSettings settings;
  final List<Person> people;
  final List<Entry> entries;
  final List<IndexPoint> indexPoints;
  final List<Insight> insights;
  final List<Todo> todos;
}

SampleData buildSampleData(DateTime now) {
  final today = dateOnly(now);
  DateTime day(int daysAgo, [int hour = 21]) =>
      DateTime(today.year, today.month, today.day - daysAgo, hour);

  final jimin = Person(
    id: 'p1',
    name: '지민',
    relationType: RelationType.friend,
    createdAt: day(40),
  );
  final seunghyun = Person(
    id: 'p2',
    name: '승현',
    relationType: RelationType.friend,
    createdAt: day(40),
  );

  var entryCount = 0;
  Entry entry(
    int daysAgo,
    String? personId,
    Emotion emotion,
    int intensity,
    String body,
  ) {
    entryCount++;
    final createdAt = day(daysAgo);
    final analyzed = EmotionAnalyzer.analyze(
      body: body,
      emotion: emotion,
      intensity: intensity,
      now: createdAt,
    );
    return Entry(
      id: 'e$entryCount',
      body: body,
      personId: personId,
      emotion: emotion,
      intensity: intensity,
      score: analyzed.score,
      createdAt: createdAt,
      analysisStatus: AnalysisStatus.done,
      analysis: analyzed.analysis,
    );
  }

  final entries = <Entry>[
    // 오래전(11~30일 전) 20일 연속: 지민과 좋은 기록.
    for (var d = 30; d >= 11; d--)
      entry(
        d,
        jimin.id,
        d.isEven ? Emotion.joy : Emotion.love,
        2,
        '지민이와 즐거운 하루였다. 고마운 마음이 들었다.',
      ),
    // 최근 5일 연속: 지민에게 서운한 기록.
    for (var d = 5; d >= 1; d--)
      entry(d, jimin.id, Emotion.sadness, 2, '지민이가 답장을 늦게 해서 서운했다.'),
    // 승현과의 기록 3건.
    entry(9, seunghyun.id, Emotion.love, 2, '승현이가 도와줘서 고마웠다.'),
    entry(4, seunghyun.id, Emotion.joy, 2, '승현이와 점심을 먹어서 기뻤다.'),
    entry(2, seunghyun.id, Emotion.excited, 1, '승현이와 주말 약속이 설렌다.'),
    // 인물 없는 기록.
    entry(3, null, Emotion.neutral, 1, '조용히 산책을 하며 마음이 평온했다.'),
  ];

  // 일별 관계 지수 이력(최근 30일, 계산할 수 있는 날만).
  final points = <IndexPoint>[];
  for (final person in [jimin, seunghyun]) {
    final own = entries.where((e) => e.personId == person.id).toList();
    for (var d = 30; d >= 0; d--) {
      final result = RelationIndex.compute(own, day(d, 12));
      if (result != null) {
        points.add(
          IndexPoint(
            personId: person.id,
            date: day(d, 0),
            index: result.index,
            entryCount: result.entryCount,
          ),
        );
      }
    }
  }

  // 인사이트: 지금 시각에 감지기를 돌린 결과(지민 부정 추세).
  final insights = <Insight>[];
  for (final person in [jimin, seunghyun]) {
    final found = InsightDetector.detect(
      person: person,
      entries: entries.where((e) => e.personId == person.id).toList(),
      existing: insights,
      now: now,
      newId: 'i${insights.length + 1}',
    );
    if (found != null) insights.add(found);
  }

  return SampleData(
    settings: const AppSettings(nickname: '규리'),
    people: [jimin, seunghyun],
    entries: entries,
    indexPoints: points,
    insights: insights,
    todos: [
      Todo(
        id: 't1',
        title: '지민님에게 가볍게 안부 묻기',
        personId: jimin.id,
        source: TodoSource.suggestion,
        insightId: insights.isEmpty ? null : insights.first.id,
        createdAt: day(1),
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
