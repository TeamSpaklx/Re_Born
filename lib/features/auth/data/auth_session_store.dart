import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_user.dart';

/// 시연용 로그인 상태를 기기에 남기는 곳(Supabase 연결 전 임시).
/// 앱을 다시 켜도 로그인 화면을 또 거치지 않게, 어떤 소셜 계정으로 들어왔는지와
/// 가입을 마친 소셜 종류만 저장한다. 기록 데이터는 여전히 메모리에만 있다.
/// Supabase Auth를 붙이면 세션은 SDK가 직접 저장하므로 이 파일은 지운다.
abstract interface class AuthSessionStore {
  /// 지금 로그인한 소셜 종류. 로그아웃 상태면 null. 첫 화면을 정해야 해서 동기로 읽는다.
  SocialProvider? get session;

  /// 첫 설정까지 마친 소셜 종류(다음에 들어오면 "기존 회원"으로 본다).
  Set<SocialProvider> get members;

  Future<void> save({
    required SocialProvider? session,
    required Set<SocialProvider> members,
  });
}

/// 테스트·기본값용. 앱을 다시 켜면 로그아웃 상태로 돌아간다.
class InMemoryAuthSessionStore implements AuthSessionStore {
  InMemoryAuthSessionStore({this.session, Set<SocialProvider>? members})
    : members = {...?members};

  @override
  SocialProvider? session;

  @override
  Set<SocialProvider> members;

  @override
  Future<void> save({
    required SocialProvider? session,
    required Set<SocialProvider> members,
  }) async {
    this.session = session;
    this.members = {...members};
  }
}

/// `shared_preferences`에 저장하는 구현. [create]로 만들어 `main.dart`에서 끼운다.
class PrefsAuthSessionStore implements AuthSessionStore {
  PrefsAuthSessionStore._(this._prefs);

  static const _sessionKey = 'auth_session_provider';
  static const _membersKey = 'auth_social_members';

  final SharedPreferencesWithCache _prefs;

  static Future<PrefsAuthSessionStore> create() async {
    final prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: {_sessionKey, _membersKey},
      ),
    );
    return PrefsAuthSessionStore._(prefs);
  }

  static SocialProvider? _parse(String? name) =>
      SocialProvider.values.where((p) => p.name == name).firstOrNull;

  @override
  SocialProvider? get session => _parse(_prefs.getString(_sessionKey));

  @override
  Set<SocialProvider> get members => {
    for (final name in _prefs.getStringList(_membersKey) ?? const <String>[])
      ?_parse(name),
  };

  @override
  Future<void> save({
    required SocialProvider? session,
    required Set<SocialProvider> members,
  }) async {
    if (session == null) {
      await _prefs.remove(_sessionKey);
    } else {
      await _prefs.setString(_sessionKey, session.name);
    }
    await _prefs.setStringList(_membersKey, [for (final m in members) m.name]);
  }
}
