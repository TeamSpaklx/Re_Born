import '../models/app_settings.dart';

/// 닉네임·동의 저장소 (테이블 `profiles`). 본인 행만 접근(RLS).
abstract interface class SettingsRepository {
  Future<AppSettings> get();

  Future<void> save(AppSettings settings);
}
