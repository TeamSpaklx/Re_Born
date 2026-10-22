import '../models/app_settings.dart';
import 'settings_repository.dart';

/// 메모리에만 두는 설정 저장소.
class InMemorySettingsRepository implements SettingsRepository {
  InMemorySettingsRepository(this._settings);

  AppSettings _settings;

  @override
  Future<AppSettings> get() async => _settings;

  @override
  Future<void> save(AppSettings settings) async => _settings = settings;
}
