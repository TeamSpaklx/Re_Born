import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/errors/app_error_log.dart';
import '../core/providers/clock_provider.dart';
import '../features/analysis/analysis_service.dart';
import '../features/analysis/data/sample_data.dart';
import '../features/entries/data/entries_repository.dart';
import '../features/entries/data/in_memory_entries_repository.dart';
import '../features/insights/data/in_memory_insights_repository.dart';
import '../features/insights/data/insights_repository.dart';
import '../features/people/data/in_memory_people_repository.dart';
import '../features/people/data/people_repository.dart';
import '../features/settings/data/in_memory_settings_repository.dart';
import '../features/settings/data/settings_repository.dart';
import '../features/todos/data/in_memory_todos_repository.dart';
import '../features/todos/data/todos_repository.dart';

/// 프론트 전용 브랜치는 샘플 데이터를 메모리 저장소에 보관한다.
final sampleDataProvider = Provider<SampleData>(
  (ref) => buildSampleData(ref.watch(clockProvider)()),
);

final peopleRepositoryProvider = Provider<PeopleRepository>(
  (ref) =>
      InMemoryPeopleRepository(initial: ref.watch(sampleDataProvider).people),
);

final entriesRepositoryProvider = Provider<EntriesRepository>(
  (ref) =>
      InMemoryEntriesRepository(initial: ref.watch(sampleDataProvider).entries),
);

final todosRepositoryProvider = Provider<TodosRepository>(
  (ref) =>
      InMemoryTodosRepository(initial: ref.watch(sampleDataProvider).todos),
);

final insightsRepositoryProvider = Provider<InsightsRepository>(
  (ref) => InMemoryInsightsRepository(
    initial: ref.watch(sampleDataProvider).insights,
  ),
);

final indexHistoryRepositoryProvider = Provider<IndexHistoryRepository>(
  (ref) => InMemoryIndexHistoryRepository(
    initial: ref.watch(sampleDataProvider).indexPoints,
  ),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => InMemorySettingsRepository(ref.watch(sampleDataProvider).settings),
);

/// 기록 저장 → 분석 → 지수 → 인사이트 체인. 저장소만 바뀌면 그대로 쓴다.
final analysisServiceProvider = Provider<AnalysisService>(
  (ref) => AnalysisService(
    entries: ref.watch(entriesRepositoryProvider),
    people: ref.watch(peopleRepositoryProvider),
    indexHistory: ref.watch(indexHistoryRepositoryProvider),
    insights: ref.watch(insightsRepositoryProvider),
    clock: ref.watch(clockProvider),
    onError: (error, stack) =>
        ref.read(appErrorLogProvider).record(error, stack, where: 'analysis'),
  ),
);
