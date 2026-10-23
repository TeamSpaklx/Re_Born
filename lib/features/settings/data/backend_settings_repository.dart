import '../../../core/network/backend_api_client.dart';
import '../models/app_settings.dart';
import 'settings_repository.dart';

class BackendSettingsRepository implements SettingsRepository {
  BackendSettingsRepository(this._api);
  final BackendApiClient _api;

  @override
  Future<AppSettings> get() async {
    final row = _object(await _api.get('/api/me'));
    return AppSettings(
      nickname: row['nickname'] as String? ?? '',
      consents: Consents(
        privacy: row['consent_privacy'] as bool,
        aiAnalysis: row['consent_ai_analysis'] as bool,
        analytics: row['consent_analytics'] as bool,
      ),
    );
  }

  @override
  Future<void> save(AppSettings settings) async {
    await _api.put('/api/me', {
      'nickname': settings.nickname,
      'consentPrivacy': settings.consents.privacy,
      'consentAiAnalysis': settings.consents.aiAnalysis,
      'consentAnalytics': settings.consents.analytics,
    });
  }
}

Map<String, dynamic> _object(Object? value) =>
    Map<String, dynamic>.from(value! as Map);
