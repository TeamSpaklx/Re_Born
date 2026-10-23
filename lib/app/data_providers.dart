import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/errors/app_error_log.dart';
import '../core/platform/image_picker_service.dart';
import '../core/providers/clock_provider.dart';
import '../features/analysis/analysis_service.dart';
import '../features/analysis/data/sample_data.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/data/in_memory_auth_repository.dart';
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

/// **저장소 교체 지점.** 백엔드가 Supabase 구현을 만들면 아래 provider 7개의 한 줄씩만 바꾼다
/// (예: `InMemoryPeopleRepository(...)` → `SupabasePeopleRepository(...)`). 화면과 분석 코드는 그대로다.
/// 지금은 메모리 저장소 + 샘플 데이터이고, 앱을 다시 켜면 샘플로 돌아간다.
final sampleDataProvider = Provider<SampleData>(
  (ref) => buildSampleData(ref.watch(clockProvider)()),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => InMemoryAuthRepository(),
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

/// 프로필 사진을 가져오는 서비스(갤러리·카메라). 테스트에서 가짜로 바꾼다.
final imagePickerServiceProvider = Provider<ImagePickerService>(
  (ref) => DeviceImagePickerService(),
);
