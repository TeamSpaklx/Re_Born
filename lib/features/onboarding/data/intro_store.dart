import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 인트로 온보딩을 이미 봤는지 기억하는 곳. 설치 후 최초 1회만 보여 주므로 기기에 저장한다.
/// 로그아웃·탈퇴를 해도 지우지 않는다(앱을 다시 설치하면 다시 보인다).
abstract interface class IntroStore {
  /// 스플래시가 어디로 갈지 바로 정해야 해서 동기로 읽는다.
  bool get seen;

  Future<void> markSeen();
}

/// 테스트·기본값용. 앱을 다시 켜면 처음 상태로 돌아간다.
class InMemoryIntroStore implements IntroStore {
  InMemoryIntroStore([this._seen = false]);

  bool _seen;

  @override
  bool get seen => _seen;

  @override
  Future<void> markSeen() async => _seen = true;
}

/// `shared_preferences`에 저장하는 실제 구현. [create]로 만들어 `main.dart`에서 끼운다.
class PrefsIntroStore implements IntroStore {
  PrefsIntroStore._(this._prefs);

  static const _key = 'intro_seen';

  final SharedPreferencesWithCache _prefs;

  static Future<PrefsIntroStore> create() async {
    final prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(allowList: {_key}),
    );
    return PrefsIntroStore._(prefs);
  }

  @override
  bool get seen => _prefs.getBool(_key) ?? false;

  @override
  Future<void> markSeen() => _prefs.setBool(_key, true);
}

/// 인트로 저장소. `main.dart`에서 [PrefsIntroStore]로 바꿔 끼운다.
final introStoreProvider = Provider<IntroStore>((ref) => InMemoryIntroStore());
