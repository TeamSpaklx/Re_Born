import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 앱 잠금 켜짐 여부를 기억하는 곳. 앱을 완전히 껐다 켜도 남아야 해서 기기에 저장한다.
/// (다른 설정은 아직 메모리 저장소라 다시 켜면 사라지지만, 잠금은 그러면 의미가 없다.)
abstract interface class AppLockStore {
  /// 첫 프레임부터 잠금 화면을 그려야 해서 동기로 읽는다.
  bool get enabled;

  Future<void> setEnabled(bool value);
}

/// 테스트·기본값용. 앱을 다시 켜면 꺼진 상태로 돌아간다.
class InMemoryAppLockStore implements AppLockStore {
  InMemoryAppLockStore([this._enabled = false]);

  bool _enabled;

  @override
  bool get enabled => _enabled;

  @override
  Future<void> setEnabled(bool value) async => _enabled = value;
}

/// `shared_preferences`에 저장하는 실제 구현. [create]로 만들어 `main.dart`에서 끼운다.
class PrefsAppLockStore implements AppLockStore {
  PrefsAppLockStore._(this._prefs);

  static const _key = 'app_lock_enabled';

  final SharedPreferencesWithCache _prefs;

  static Future<PrefsAppLockStore> create() async {
    final prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(allowList: {_key}),
    );
    return PrefsAppLockStore._(prefs);
  }

  @override
  bool get enabled => _prefs.getBool(_key) ?? false;

  @override
  Future<void> setEnabled(bool value) => _prefs.setBool(_key, value);
}

/// 앱 잠금 저장소. `main.dart`에서 [PrefsAppLockStore]로 바꿔 끼운다.
final appLockStoreProvider = Provider<AppLockStore>(
  (ref) => InMemoryAppLockStore(),
);
