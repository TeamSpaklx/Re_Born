import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/app/app.dart';
import 'package:reborn_app/app/data_providers.dart';
import 'package:reborn_app/app/router.dart';
import 'package:reborn_app/features/auth/data/in_memory_auth_repository.dart';
import 'package:reborn_app/features/auth/presentation/login_screen.dart';
import 'package:reborn_app/features/home/presentation/today_screen.dart';
import 'package:reborn_app/features/onboarding/data/intro_store.dart';
import 'package:reborn_app/features/onboarding/presentation/intro_screen.dart';

import '../../helpers/fakes.dart';

/// 저장 여부를 세어 보는 저장소.
class _CountingIntroStore extends InMemoryIntroStore {
  int marked = 0;

  @override
  Future<void> markSeen() {
    marked++;
    return super.markSeen();
  }
}

/// 저장이 실패하는 저장소.
class _FailingIntroStore extends InMemoryIntroStore {
  @override
  Future<void> markSeen() async => throw StateError('disk full');
}

void main() {
  Future<void> pumpApp(
    WidgetTester tester, {
    required IntroStore store,
    required bool signedIn,
    String start = AppRoutes.splash,
  }) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 62, bottom: 34);
    tester.view.viewPadding = const FakeViewPadding(top: 62, bottom: 34);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialLocationProvider.overrideWithValue(start),
          notificationServiceProvider.overrideWithValue(
            FakeNotificationService(),
          ),
          introStoreProvider.overrideWithValue(store),
          authRepositoryProvider.overrideWithValue(
            InMemoryAuthRepository(
              signedInEmail: signedIn ? InMemoryAuthRepository.demoEmail : null,
            ),
          ),
        ],
        child: const RebornApp(),
      ),
    );
    await tester.pump();
  }

  Future<void> afterSplash(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  testWidgets('설치 후 처음이면 스플래시 다음에 인트로가 뜬다', (tester) async {
    await pumpApp(tester, store: InMemoryIntroStore(), signedIn: false);
    await afterSplash(tester);

    expect(find.byType(IntroScreen), findsOneWidget);
    expect(find.text('이제, 인간관계를 기록할 수 있어요'), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('시작하기를 누르면 본 것으로 기록하고 로그인으로 간다', (tester) async {
    final store = _CountingIntroStore();
    await pumpApp(tester, store: store, signedIn: false);
    await afterSplash(tester);

    await tester.tap(find.byKey(const Key('intro-start')));
    await tester.pumpAndSettle();

    expect(store.marked, 1);
    expect(store.seen, isTrue);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(IntroScreen), findsNothing);
  });

  testWidgets('저장이 실패해도 로그인으로는 간다', (tester) async {
    await pumpApp(tester, store: _FailingIntroStore(), signedIn: false);
    await afterSplash(tester);

    await tester.tap(find.byKey(const Key('intro-start')));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('이미 봤으면 인트로 없이 로그인으로 간다', (tester) async {
    await pumpApp(tester, store: InMemoryIntroStore(true), signedIn: false);
    await afterSplash(tester);

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(IntroScreen), findsNothing);
  });

  testWidgets('로그인된 상태면 인트로를 건너뛰고 투데이로 간다', (tester) async {
    await pumpApp(tester, store: InMemoryIntroStore(), signedIn: true);
    await afterSplash(tester);

    expect(find.byType(TodayScreen), findsOneWidget);
    expect(find.byType(IntroScreen), findsNothing);
  });

  testWidgets('작은 화면에서도 넘치지 않고 시작하기가 보인다', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialLocationProvider.overrideWithValue(AppRoutes.intro),
          notificationServiceProvider.overrideWithValue(
            FakeNotificationService(),
          ),
        ],
        child: const RebornApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final button = tester.getRect(find.byKey(const Key('intro-start')));
    expect(button.bottom, lessThanOrEqualTo(640));
  });
}
