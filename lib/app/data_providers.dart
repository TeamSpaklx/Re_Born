import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/errors/app_error_log.dart';
import '../core/platform/device_auth_service.dart';
import '../core/platform/image_picker_service.dart';
import '../core/platform/notification_service.dart';
import '../core/providers/clock_provider.dart';
import '../features/ai_comment/data/ai_comment_service.dart';
import '../features/ai_comment/data/fake_ai_comment_service.dart';
import '../features/analysis/analysis_service.dart';
import '../features/analysis/data/sample_data.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/data/in_memory_auth_repository.dart';
import '../features/entries/data/entries_repository.dart';
import '../features/entries/data/in_memory_entries_repository.dart';
import '../features/settings/data/in_memory_settings_repository.dart';
import '../features/settings/data/settings_repository.dart';
import '../features/todos/data/in_memory_todos_repository.dart';
import '../features/todos/data/todos_repository.dart';

/// **저장소 교체 지점.** 백엔드가 Supabase 구현을 만들면 아래 저장소 provider와 [aiCommentServiceProvider]의
/// 한 줄씩만 바꾼다(예: `InMemoryEntriesRepository(...)` → `SupabaseEntriesRepository(...)`). 화면과 분석 코드는 그대로다.
/// 지금은 메모리 저장소 + 샘플 데이터이고, 앱을 다시 켜면 샘플로 돌아간다.
final sampleDataProvider = Provider<SampleData>(
  (ref) => buildSampleData(ref.watch(clockProvider)()),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => InMemoryAuthRepository(),
);

final entriesRepositoryProvider = Provider<EntriesRepository>(
  (ref) =>
      InMemoryEntriesRepository(initial: ref.watch(sampleDataProvider).entries),
);

final todosRepositoryProvider = Provider<TodosRepository>(
  (ref) =>
      InMemoryTodosRepository(initial: ref.watch(sampleDataProvider).todos),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => InMemorySettingsRepository(ref.watch(sampleDataProvider).settings),
);

/// 일기 AI 코멘트. 지금은 앱 안 가짜 구현이고, 백엔드 API가 나오면 그 구현으로 바꾼다.
/// 외부 AI API 키는 서버에만 둔다(앱 코드·커밋에 넣지 않는다).
final aiCommentServiceProvider = Provider<AiCommentService>(
  (ref) => FakeAiCommentService(clock: ref.watch(clockProvider)),
);

/// 일기 저장 → 규칙 분석 → AI 코멘트 체인. 저장소·AI 구현만 바뀌면 그대로 쓴다.
final analysisServiceProvider = Provider<AnalysisService>(
  (ref) => AnalysisService(
    entries: ref.watch(entriesRepositoryProvider),
    aiComment: ref.watch(aiCommentServiceProvider),
    clock: ref.watch(clockProvider),
    onError: (error, stack) =>
        ref.read(appErrorLogProvider).record(error, stack, where: 'analysis'),
  ),
);

/// 프로필 사진을 가져오는 서비스(갤러리·카메라). 테스트에서 가짜로 바꾼다.
final imagePickerServiceProvider = Provider<ImagePickerService>(
  (ref) => DeviceImagePickerService(),
);

/// OS 알림 권한과 기록 리마인드 예약. 테스트에서 가짜로 바꾼다.
final notificationServiceProvider = Provider<NotificationService>(
  (ref) => LocalNotificationService(),
);

/// 앱 잠금에 쓰는 기기 인증(Face ID·지문·기기 암호). 테스트에서 가짜로 바꾼다.
final deviceAuthServiceProvider = Provider<DeviceAuthService>(
  (ref) => LocalAuthDeviceAuthService(),
);
