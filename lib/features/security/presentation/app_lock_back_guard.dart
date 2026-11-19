import 'package:flutter/widgets.dart';

/// 잠긴 동안 Android 뒤로 버튼이 잠금 화면 뒤의 화면을 닫지 않게 막는다.
///
/// 뒤로 버튼은 관찰자를 **등록한 순서대로** 묻기 때문에, 라우터(`MaterialApp`)보다 먼저 물어보려면
/// `runApp` 전에 [install]해야 한다(`main.dart`). [AppLockGate]가 잠금 상태에 맞춰 [blocking]을 바꾼다.
class AppLockBackGuard with WidgetsBindingObserver {
  AppLockBackGuard._();

  static final instance = AppLockBackGuard._();

  bool _installed = false;

  /// true면 뒤로 버튼을 여기서 먹는다(아무 일도 일어나지 않음).
  bool blocking = false;

  void install() {
    if (_installed) return;
    WidgetsBinding.instance.addObserver(this);
    _installed = true;
  }

  @override
  Future<bool> didPopRoute() async => blocking;
}
