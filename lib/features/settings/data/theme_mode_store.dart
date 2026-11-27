import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 화면 모드(기기 설정 따르기 / 라이트 / 다크)를 기억하는 곳.
/// 앱을 다시 켜도 남아야 하고, 첫 프레임부터 알아야 해서 동기로 읽는다.
abstract interface class ThemeModeStore {
  ThemeMode get mode;

  Future<void> setMode(ThemeMode value);
}

/// 테스트·기본값용. 앱을 다시 켜면 기기 설정 따르기로 돌아온다.
class InMemoryThemeModeStore implements ThemeModeStore {
  InMemoryThemeModeStore([this._mode = ThemeMode.system]);

  ThemeMode _mode;

  @override
  ThemeMode get mode => _mode;

  @override
  Future<void> setMode(ThemeMode value) async => _mode = value;
}

/// `shared_preferences`에 저장하는 실제 구현. [create]로 만들어 `main.dart`에서 끼운다.
///
/// 예전 버전은 다크 모드 켬/끔만 `dark_mode`(bool)로 저장했다. 새 키가 없으면 그 값을 읽어
/// 켬이면 다크로 이어받는다. 끔은 예전 기본값이라 "라이트를 골랐다"는 뜻이 아니므로,
/// 끔이거나 값이 없으면(처음 설치) 기기 설정을 따른다.
class PrefsThemeModeStore implements ThemeModeStore {
  PrefsThemeModeStore._(this._prefs);

  static const _key = 'theme_mode';
  static const _legacyDarkKey = 'dark_mode';

  final SharedPreferencesWithCache _prefs;

  static Future<PrefsThemeModeStore> create() async {
    final prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: {_key, _legacyDarkKey},
      ),
    );
    return PrefsThemeModeStore._(prefs);
  }

  @override
  ThemeMode get mode {
    final saved = _prefs.getString(_key);
    final parsed = ThemeMode.values.where((m) => m.name == saved).firstOrNull;
    if (parsed != null) return parsed;
    return _prefs.getBool(_legacyDarkKey) == true
        ? ThemeMode.dark
        : ThemeMode.system;
  }

  @override
  Future<void> setMode(ThemeMode value) => _prefs.setString(_key, value.name);
}

/// 화면 모드 저장소. `main.dart`에서 [PrefsThemeModeStore]로 바꿔 끼운다.
final themeModeStoreProvider = Provider<ThemeModeStore>(
  (ref) => InMemoryThemeModeStore(),
);
