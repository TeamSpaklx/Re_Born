import 'package:shared_preferences/shared_preferences.dart';

/// 시연용 로그인 상태를 기기에 남기는 곳(Supabase 연결 전 임시).
/// 앱을 다시 켜도 로그인 화면을 또 거치지 않게, 로그인한 **이메일만** 저장한다(비밀번호는 저장하지 않는다).
/// Supabase Auth를 붙이면 세션은 SDK가 직접 저장하므로 이 파일은 지운다.
abstract interface class AuthSessionStore {
  /// 지금 로그인한 이메일. 로그아웃 상태면 null. 첫 화면을 정해야 해서 동기로 읽는다.
  String? get sessionEmail;

  Future<void> save(String? sessionEmail);
}

/// 테스트·기본값용. 앱을 다시 켜면 로그아웃 상태로 돌아간다.
class InMemoryAuthSessionStore implements AuthSessionStore {
  InMemoryAuthSessionStore({this.sessionEmail});

  @override
  String? sessionEmail;

  @override
  Future<void> save(String? sessionEmail) async {
    this.sessionEmail = sessionEmail;
  }
}

/// `shared_preferences`에 저장하는 구현. [create]로 만들어 `main.dart`에서 끼운다.
class PrefsAuthSessionStore implements AuthSessionStore {
  PrefsAuthSessionStore._(this._prefs);

  static const _sessionKey = 'auth_session_email';

  final SharedPreferencesWithCache _prefs;

  static Future<PrefsAuthSessionStore> create() async {
    final prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: {_sessionKey},
      ),
    );
    return PrefsAuthSessionStore._(prefs);
  }

  @override
  String? get sessionEmail => _prefs.getString(_sessionKey);

  @override
  Future<void> save(String? sessionEmail) async {
    if (sessionEmail == null) {
      await _prefs.remove(_sessionKey);
    } else {
      await _prefs.setString(_sessionKey, sessionEmail);
    }
  }
}
