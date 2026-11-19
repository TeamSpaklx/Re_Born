import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/app/data_providers.dart';
import 'package:reborn_app/app/theme/app_spacing.dart';
import 'package:reborn_app/app/theme/app_theme.dart';
import 'package:reborn_app/core/platform/device_auth_service.dart';
import 'package:reborn_app/features/all/presentation/widgets/settings_section.dart';
import 'package:reborn_app/features/security/data/app_lock_store.dart';
import 'package:reborn_app/features/security/presentation/app_lock_back_guard.dart';
import 'package:reborn_app/features/security/presentation/app_lock_controller.dart';
import 'package:reborn_app/features/security/presentation/app_lock_gate.dart';
import 'package:reborn_app/shared/widgets/app_toggle.dart';

/// 정해 둔 결과를 차례로 돌려주는 가짜 기기 인증. [hold]면 [release] 전까지 인증 창이 떠 있는 상태로 멈춘다.
class FakeDeviceAuth implements DeviceAuthService {
  FakeDeviceAuth({
    this.kind = DeviceAuthKind.faceId,
    List<DeviceAuthResult>? results,
  }) : results = results ?? [];

  DeviceAuthKind kind;
  final List<DeviceAuthResult> results;
  final reasons = <String>[];
  final previewHidden = <bool>[];
  Completer<DeviceAuthResult>? _pending;
  bool hold = false;

  void release(DeviceAuthResult result) => _pending!.complete(result);

  @override
  Future<DeviceAuthKind> availableKind() async => kind;

  @override
  Future<DeviceAuthResult> authenticate({required String reason}) {
    reasons.add(reason);
    if (hold) return (_pending = Completer<DeviceAuthResult>()).future;
    return Future.value(
      results.isEmpty ? const DeviceAuthSuccess() : results.removeAt(0),
    );
  }

  @override
  Future<void> setRecentsPreviewHidden(bool hidden) async =>
      previewHidden.add(hidden);
}

void main() {
  group('AppLockController', () {
    late FakeDeviceAuth auth;
    late InMemoryAppLockStore store;

    ProviderContainer make({bool enabled = false}) {
      auth = FakeDeviceAuth();
      store = InMemoryAppLockStore(enabled);
      final c = ProviderContainer(
        overrides: [
          deviceAuthServiceProvider.overrideWithValue(auth),
          appLockStoreProvider.overrideWithValue(store),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    AppLockPhase phase(ProviderContainer c) =>
        c.read(appLockControllerProvider).phase;
    AppLockController ctrl(ProviderContainer c) =>
        c.read(appLockControllerProvider.notifier);

    test('꺼져 있으면 생명주기에 반응하지 않는다', () async {
      final c = make();
      await ctrl(c).start(foreground: true);
      ctrl(c)
        ..onInactive()
        ..onBackground()
        ..onResume();
      expect(phase(c), AppLockPhase.unlocked);
      expect(auth.reasons, isEmpty);
    });

    test('켜진 채 시작하면 잠겨 있고, 앞에 있으면 바로 인증해 풀린다', () async {
      final c = make(enabled: true);
      expect(phase(c), AppLockPhase.locked);
      await ctrl(c).start(foreground: true);
      expect(auth.reasons, [AppLockController.unlockReason]);
      expect(auth.previewHidden, [true]);
      expect(phase(c), AppLockPhase.unlocked);
    });

    test('앞에 있지 않을 때 시작하면 돌아올 때 인증한다', () async {
      final c = make(enabled: true);
      await ctrl(c).start(foreground: false);
      expect(auth.reasons, isEmpty);
      ctrl(c).onResume();
      await Future<void>.delayed(Duration.zero);
      expect(phase(c), AppLockPhase.unlocked);
    });

    test('실패·취소·잠김이면 failed, 다시 시도해 성공하면 풀린다', () async {
      final c = make(enabled: true);
      auth.results.addAll([
        const DeviceAuthFailed(),
        const DeviceAuthLockedOut(),
      ]);
      await ctrl(c).unlock();
      expect(phase(c), AppLockPhase.failed);
      await ctrl(c).unlock();
      expect(phase(c), AppLockPhase.failed);
      await ctrl(c).unlock();
      expect(phase(c), AppLockPhase.unlocked);
    });

    test('기기 잠금이 없어져 인증할 수 없으면 잠금을 끄고 들여보낸다', () async {
      final c = make(enabled: true);
      auth.results.add(const DeviceAuthUnavailable());
      await ctrl(c).unlock();
      expect(phase(c), AppLockPhase.unlocked);
      expect(c.read(appLockControllerProvider).enabled, isFalse);
      expect(store.enabled, isFalse);
      expect(auth.previewHidden.last, isFalse);
    });

    test('앱 전환 화면은 덮기만 하고, 바로 돌아오면 인증 없이 풀린다', () async {
      final c = make(enabled: true);
      await ctrl(c).start(foreground: true);
      ctrl(c).onInactive();
      expect(phase(c), AppLockPhase.covered);
      ctrl(c).onResume();
      expect(phase(c), AppLockPhase.unlocked);
      expect(auth.reasons, hasLength(1));
    });

    test('백그라운드에 다녀오면 다시 인증한다', () async {
      final c = make(enabled: true);
      await ctrl(c).start(foreground: true);
      ctrl(c)
        ..onInactive()
        ..onBackground();
      expect(phase(c), AppLockPhase.locked);
      ctrl(c).onResume();
      await Future<void>.delayed(Duration.zero);
      expect(auth.reasons, hasLength(2));
      expect(phase(c), AppLockPhase.unlocked);
    });

    test('인증 창이 떠 있는 동안의 생명주기 변화는 무시한다', () async {
      final c = make(enabled: true);
      auth.hold = true;
      final pending = ctrl(c).unlock();
      expect(phase(c), AppLockPhase.authenticating);
      ctrl(c)
        ..onInactive()
        ..onBackground()
        ..onResume();
      expect(phase(c), AppLockPhase.authenticating);
      auth.release(const DeviceAuthSuccess());
      await pending;
      expect(phase(c), AppLockPhase.unlocked);
      expect(auth.reasons, hasLength(1));
    });

    test('suspendWhile 안(사진 고르기)에서는 나갔다 와도 잠그지 않는다', () async {
      final c = make(enabled: true);
      await ctrl(c).start(foreground: true);
      final value = await ctrl(c).suspendWhile(() async {
        ctrl(c)
          ..onInactive()
          ..onBackground()
          ..onResume();
        return 7;
      });
      expect(value, 7);
      expect(phase(c), AppLockPhase.unlocked);
      ctrl(c).onBackground();
      expect(phase(c), AppLockPhase.locked, reason: '끝난 뒤에는 다시 잠근다');
    });

    test('켜기는 인증에 성공해야 저장된다', () async {
      final c = make();
      auth.results.add(const DeviceAuthFailed());
      expect(await ctrl(c).setEnabled(true), AppLockToggleResult.failed);
      expect(store.enabled, isFalse);

      expect(await ctrl(c).setEnabled(true), AppLockToggleResult.enabled);
      expect(store.enabled, isTrue);
      expect(c.read(appLockControllerProvider).enabled, isTrue);
      expect(phase(c), AppLockPhase.unlocked, reason: '켜자마자 잠그지 않는다');
      expect(auth.reasons, everyElement(AppLockController.enableReason));

      expect(await ctrl(c).setEnabled(false), AppLockToggleResult.disabled);
      expect(store.enabled, isFalse);
    });

    test('기기에 화면 잠금이 없으면 켜지 않는다', () async {
      final c = make();
      auth.kind = DeviceAuthKind.none;
      expect(await ctrl(c).setEnabled(true), AppLockToggleResult.unavailable);
      expect(auth.reasons, isEmpty);
      expect(store.enabled, isFalse);
    });
  });

  group('AppLockGate', () {
    Future<FakeDeviceAuth> pumpGate(
      WidgetTester tester, {
      bool enabled = true,
      List<DeviceAuthResult>? results,
    }) async {
      final auth = FakeDeviceAuth(results: results);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            deviceAuthServiceProvider.overrideWithValue(auth),
            appLockStoreProvider.overrideWithValue(
              InMemoryAppLockStore(enabled),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            builder: (context, child) => AppLockGate(child: child!),
            home: const Scaffold(body: Center(child: Text('기록 화면'))),
          ),
        ),
      );
      return auth;
    }

    testWidgets('잠긴 동안 뒤 화면을 덮고 스크린 리더에서도 숨긴다, 성공하면 사라진다', (tester) async {
      final auth = FakeDeviceAuth()..hold = true;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            deviceAuthServiceProvider.overrideWithValue(auth),
            appLockStoreProvider.overrideWithValue(InMemoryAppLockStore(true)),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            builder: (context, child) => AppLockGate(child: child!),
            home: const Scaffold(body: Center(child: Text('기록 화면'))),
          ),
        ),
      );
      await tester.pump();
      expect(find.byKey(const Key('lock-screen')), findsOneWidget);
      expect(find.byKey(const Key('lock-retry')), findsNothing);
      expect(find.bySemanticsLabel('기록 화면'), findsNothing);
      expect(find.bySemanticsLabel('Re:Born 잠김'), findsOneWidget);

      auth.release(const DeviceAuthSuccess());
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('lock-screen')), findsNothing);
      expect(find.bySemanticsLabel('기록 화면'), findsOneWidget);
    });

    testWidgets('실패하면 "인증에 실패하거나…" 버튼이 나오고 누르면 다시 인증한다', (tester) async {
      final auth = await pumpGate(tester, results: [const DeviceAuthFailed()]);
      await tester.pumpAndSettle();
      expect(find.text('인증에 실패하거나 비밀번호를 잊으셨나요?'), findsOneWidget);
      expect(auth.reasons, hasLength(1));

      await tester.tap(find.byKey(const Key('lock-retry')));
      await tester.pumpAndSettle();
      expect(auth.reasons, hasLength(2));
      expect(find.byKey(const Key('lock-screen')), findsNothing);
    });

    testWidgets('앱 전환 화면에서는 로고로 덮고, 백그라운드에서 돌아오면 다시 인증한다', (tester) async {
      final auth = await pumpGate(tester);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('lock-screen')), findsNothing);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(find.byKey(const Key('lock-screen')), findsOneWidget);

      tester.binding
        ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
        ..handleAppLifecycleStateChanged(AppLifecycleState.paused)
        ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
        ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
        ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(auth.reasons, hasLength(2));
      expect(find.byKey(const Key('lock-screen')), findsNothing);
    });

    testWidgets('잠긴 동안 뒤로 버튼은 뒤 화면을 닫지 않는다', (tester) async {
      final auth = FakeDeviceAuth(results: [const DeviceAuthFailed()]);
      final navKey = GlobalKey<NavigatorState>();
      AppLockBackGuard.instance.install(); // main.dart처럼 앱보다 먼저 등록
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            deviceAuthServiceProvider.overrideWithValue(auth),
            appLockStoreProvider.overrideWithValue(InMemoryAppLockStore(true)),
          ],
          child: MaterialApp(
            navigatorKey: navKey,
            theme: AppTheme.light,
            builder: (context, child) => AppLockGate(child: child!),
            home: const Scaffold(body: Text('첫 화면')),
          ),
        ),
      );
      unawaited(
        navKey.currentState!.push(
          MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: Text('두 번째 화면')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('lock-retry')), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('두 번째 화면', skipOffstage: false), findsOneWidget);

      await tester.tap(find.byKey(const Key('lock-retry')));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('두 번째 화면', skipOffstage: false), findsNothing);
    });

    testWidgets('꺼져 있으면 아무것도 덮지 않는다', (tester) async {
      final auth = await pumpGate(tester, enabled: false);
      await tester.pumpAndSettle();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(find.byKey(const Key('lock-screen')), findsNothing);
      expect(auth.reasons, isEmpty);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    });
  });

  group('설정 > 보안 > 앱 잠금', () {
    Future<(FakeDeviceAuth, InMemoryAppLockStore)> pumpSettings(
      WidgetTester tester, {
      DeviceAuthKind kind = DeviceAuthKind.faceId,
      List<DeviceAuthResult>? results,
    }) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(402, 2000);
      addTearDown(tester.view.reset);
      final auth = FakeDeviceAuth(kind: kind, results: results);
      final store = InMemoryAppLockStore();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            deviceAuthServiceProvider.overrideWithValue(auth),
            appLockStoreProvider.overrideWithValue(store),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(
              body: SingleChildScrollView(child: SettingsSection()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return (auth, store);
    }

    Future<void> showToast(WidgetTester tester) async {
      await tester.pump();
      await tester.pump();
      await tester.pump(ComponentLayout.toastFade);
    }

    Finder toggle() => find.descendant(
      of: find.byKey(const Key('app-lock')),
      matching: find.byType(AppToggle),
    );

    testWidgets('기기 수단 이름을 보여 주고, 인증에 성공하면 켜진다', (tester) async {
      final (auth, store) = await pumpSettings(tester);
      expect(find.text('앱 잠금 (Face ID)'), findsOneWidget);

      await tester.tap(toggle());
      await showToast(tester);
      expect(auth.reasons, [AppLockController.enableReason]);
      expect(store.enabled, isTrue);
      expect(find.text('앱 잠금을 켰어요'), findsOneWidget);
      await tester.pump(ComponentLayout.toastTotal);
      await tester.pumpAndSettle();

      await tester.tap(toggle());
      await showToast(tester);
      expect(store.enabled, isFalse);
      await tester.pump(ComponentLayout.toastTotal);
      await tester.pumpAndSettle();
    });

    testWidgets('인증에 실패하면 켜지지 않는다', (tester) async {
      final (_, store) = await pumpSettings(
        tester,
        results: [const DeviceAuthFailed()],
      );
      await tester.tap(toggle());
      await showToast(tester);
      expect(store.enabled, isFalse);
      expect(find.text('인증하지 못해 앱 잠금을 켜지 않았어요'), findsOneWidget);
      await tester.pump(ComponentLayout.toastTotal);
      await tester.pumpAndSettle();
    });

    testWidgets('화면 잠금이 없는 기기는 안내만 한다', (tester) async {
      final (auth, store) = await pumpSettings(
        tester,
        kind: DeviceAuthKind.none,
      );
      expect(find.text('앱 잠금'), findsOneWidget);
      await tester.tap(toggle());
      await showToast(tester);
      expect(auth.reasons, isEmpty);
      expect(store.enabled, isFalse);
      expect(find.text('휴대폰 화면 잠금을 먼저 설정해 주세요'), findsOneWidget);
      await tester.pump(ComponentLayout.toastTotal);
      await tester.pumpAndSettle();
    });
  });
}
