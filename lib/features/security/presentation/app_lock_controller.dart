import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/data_providers.dart';
import '../../../core/platform/device_auth_service.dart';
import '../data/app_lock_store.dart';

/// 잠금 화면의 단계.
enum AppLockPhase {
  /// 잠금 없음. 앱 화면이 그대로 보인다.
  unlocked,

  /// 앱 전환 화면에 들어간 상태(inactive). 기록이 보이지 않게 로고만 덮고, 인증은 하지 않는다.
  covered,

  /// 잠김. 앱이 앞으로 오면 인증 창을 띄운다.
  locked,

  /// 시스템 인증 창이 떠 있다.
  authenticating,

  /// 인증에 실패하거나 취소했다. "인증에 실패하거나…" 버튼을 보여 준다.
  failed,
}

@immutable
class AppLockState {
  const AppLockState({required this.enabled, required this.phase});

  final bool enabled;
  final AppLockPhase phase;

  /// 앱 화면을 가려야 하는지.
  bool get obscured => phase != AppLockPhase.unlocked;

  AppLockState copyWith({bool? enabled, AppLockPhase? phase}) => AppLockState(
    enabled: enabled ?? this.enabled,
    phase: phase ?? this.phase,
  );
}

/// 설정에서 앱 잠금을 켜고 끈 결과. 화면은 결과에 맞는 토스트만 보여 준다.
enum AppLockToggleResult {
  enabled,
  disabled,

  /// 기기에 화면 잠금(암호)이 없어 켤 수 없다.
  unavailable,

  /// 인증하지 못해 켜지 않았다.
  failed,
}

/// 앱 잠금 (Figma 834:1480, 834:2141).
///
/// - 켜져 있으면 앱을 처음 열 때와 백그라운드에서 돌아올 때 Face ID·지문·기기 암호로 잠금을 푼다.
/// - 앱 전환 화면(inactive)에서는 로고로 덮기만 한다.
/// - 인증 창이 떠 있는 동안(iOS는 이때 inactive가 된다)과 [suspendWhile] 안에서는 생명주기를 무시한다.
/// - 기기에 화면 잠금이 없어져 인증할 수 없으면 잠금을 끄고 들여보낸다(영영 못 들어가는 일 방지).
///
/// 로그인·계정이 생기면 "계정으로 잠금 풀기"를 [unlock] 실패 경로에 추가한다(docs/FRONTEND.md).
class AppLockController extends Notifier<AppLockState> {
  static const unlockReason = '기록을 보려면 잠금을 풀어 주세요';
  static const enableReason = '앱 잠금을 켜려면 인증해 주세요';

  int _suspended = 0;

  AppLockStore get _store => ref.read(appLockStoreProvider);
  DeviceAuthService get _auth => ref.read(deviceAuthServiceProvider);

  @override
  AppLockState build() {
    final enabled = ref.read(appLockStoreProvider).enabled;
    return AppLockState(
      enabled: enabled,
      phase: enabled ? AppLockPhase.locked : AppLockPhase.unlocked,
    );
  }

  /// 앱이 뜬 직후 한 번. 앱 전환 미리보기 숨김을 맞추고, 앱이 앞에 있으면 바로 인증 창을 띄운다.
  /// 아직 앞에 있지 않으면 [onResume]에서 띄운다.
  Future<void> start({required bool foreground}) async {
    unawaited(_auth.setRecentsPreviewHidden(state.enabled));
    if (foreground && state.phase == AppLockPhase.locked) await unlock();
  }

  void onInactive() {
    if (_ignoreLifecycle) return;
    if (state.phase == AppLockPhase.unlocked) {
      state = state.copyWith(phase: AppLockPhase.covered);
    }
  }

  void onBackground() {
    if (_ignoreLifecycle) return;
    if (state.phase == AppLockPhase.covered ||
        state.phase == AppLockPhase.unlocked) {
      state = state.copyWith(phase: AppLockPhase.locked);
    }
  }

  void onResume() {
    if (_ignoreLifecycle) return;
    switch (state.phase) {
      case AppLockPhase.covered:
        state = state.copyWith(phase: AppLockPhase.unlocked);
      case AppLockPhase.locked:
        unawaited(unlock());
      case AppLockPhase.unlocked ||
          AppLockPhase.authenticating ||
          AppLockPhase.failed:
        break;
    }
  }

  bool get _ignoreLifecycle =>
      !state.enabled ||
      _suspended > 0 ||
      state.phase == AppLockPhase.authenticating;

  /// 시스템 인증 창을 띄워 잠금을 푼다. 실패 버튼도 이걸 부른다(기기 암호 허용).
  Future<void> unlock() async {
    if (!state.enabled || state.phase == AppLockPhase.authenticating) return;
    state = state.copyWith(phase: AppLockPhase.authenticating);
    final result = await _auth.authenticate(reason: unlockReason);
    if (!ref.mounted) return;
    switch (result) {
      case DeviceAuthSuccess():
        state = state.copyWith(phase: AppLockPhase.unlocked);
      case DeviceAuthFailed() || DeviceAuthLockedOut():
        state = state.copyWith(phase: AppLockPhase.failed);
      case DeviceAuthUnavailable():
        await _disable();
    }
  }

  /// 설정 토글. 켤 때는 인증에 성공해야 켜진다.
  Future<AppLockToggleResult> setEnabled(bool on) async {
    if (!on) {
      await _disable();
      return AppLockToggleResult.disabled;
    }
    if (await _auth.availableKind() == DeviceAuthKind.none) {
      return AppLockToggleResult.unavailable;
    }
    // 켜기 전 인증 중에는 아직 enabled가 false라 생명주기에 반응하지 않는다.
    final result = await _auth.authenticate(reason: enableReason);
    if (!ref.mounted) return AppLockToggleResult.failed;
    switch (result) {
      case DeviceAuthSuccess():
        await _store.setEnabled(true);
        state = const AppLockState(enabled: true, phase: AppLockPhase.unlocked);
        unawaited(_auth.setRecentsPreviewHidden(true));
        return AppLockToggleResult.enabled;
      case DeviceAuthUnavailable():
        return AppLockToggleResult.unavailable;
      case DeviceAuthFailed() || DeviceAuthLockedOut():
        return AppLockToggleResult.failed;
    }
  }

  /// 사진 고르기·카메라처럼 앱이 일부러 다른 화면을 띄우는 동안은 잠그지 않는다.
  Future<T> suspendWhile<T>(Future<T> Function() action) async {
    _suspended++;
    try {
      return await action();
    } finally {
      _suspended--;
    }
  }

  Future<void> _disable() async {
    await _store.setEnabled(false);
    if (!ref.mounted) return;
    state = const AppLockState(enabled: false, phase: AppLockPhase.unlocked);
    unawaited(_auth.setRecentsPreviewHidden(false));
  }
}

final appLockControllerProvider =
    NotifierProvider<AppLockController, AppLockState>(AppLockController.new);

/// 설정 화면 문구용: 기기에서 쓸 수 있는 잠금 해제 수단.
final deviceAuthKindProvider = FutureProvider<DeviceAuthKind>(
  (ref) => ref.watch(deviceAuthServiceProvider).availableKind(),
);
