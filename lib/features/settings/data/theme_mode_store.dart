import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 다크 모드를 켰는지 기억하는 곳. 앱을 다시 켜도 남아야 하고, 첫 프레임부터 알아야 해서 동기로 읽는다.
abstract interface class ThemeModeStore {
  bool get dark;

  Future<void> setDark(bool value);
}

/// 테스트·기본값용. 앱을 다시 켜면 라이트로 돌아온다.
class InMemoryThemeModeStore implements ThemeModeStore {
  InMemoryThemeModeStore([this._dark = false]);

  bool _dark;

  @override
  bool get dark => _dark;

  @override
  Future<void> setDark(bool value) async => _dark = value;
}

/// `shared_preferences`에 저장하는 실제 구현. [create]로 만들어 `main.dart`에서 끼운다.
class PrefsThemeModeStore implements ThemeModeStore {
  PrefsThemeModeStore._(this._prefs);

  static const _key = 'dark_mode';

  final SharedPreferencesWithCache _prefs;

  static Future<PrefsThemeModeStore> create() async {
    final prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(allowList: {_key}),
    );
    return PrefsThemeModeStore._(prefs);
  }

  @override
  bool get dark => _prefs.getBool(_key) ?? false;

  @override
  Future<void> setDark(bool value) => _prefs.setBool(_key, value);
}

/// 다크 모드 저장소. `main.dart`에서 [PrefsThemeModeStore]로 바꿔 끼운다.
final themeModeStoreProvider = Provider<ThemeModeStore>(
  (ref) => InMemoryThemeModeStore(),
);
