import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/app/app.dart';
import 'package:reborn_app/app/data_providers.dart';
import 'package:reborn_app/app/router.dart';
import 'package:reborn_app/app/theme/app_assets.dart';
import 'package:reborn_app/core/errors/app_error_log.dart';
import 'package:reborn_app/features/auth/data/auth_session_store.dart';
import 'package:reborn_app/features/auth/data/in_memory_auth_repository.dart';
import 'package:reborn_app/features/auth/models/auth_user.dart';
import 'package:reborn_app/features/auth/presentation/auth_providers.dart';
import 'package:reborn_app/features/auth/presentation/login_screen.dart';
import 'package:reborn_app/features/auth/presentation/signup_screen.dart';
import 'package:reborn_app/features/home/presentation/today_screen.dart';
import 'package:reborn_app/features/onboarding/data/intro_store.dart';
import 'package:reborn_app/features/settings/presentation/settings_providers.dart';

import '../../helpers/fakes.dart';

/// 로그인 호출 수를 세고, [hold]가 있으면 그 Future가 끝날 때까지 응답을 미룬다.
/// [error]가 있으면 로그인 대신 그 오류를 던진다(네트워크·알 수 없는 오류 확인용).
class _ScriptedAuth extends InMemoryAuthRepository {
  _ScriptedAuth({super.store});

  int signInCalls = 0;
  Completer<void>? hold;
  Object? error;

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    signInCalls++;
    await hold?.future;
    if (error case final e?) throw e;
    return super.signIn(email: email, password: password);
  }
}

void main() {
  late InMemoryAuthSessionStore store;
  late _ScriptedAuth auth;
  late AppErrorLog errorLog;

  setUp(() {
    store = InMemoryAuthSessionStore();
    auth = _ScriptedAuth(store: store);
    errorLog = AppErrorLog();
  });

  Future<ProviderContainer> pumpLogin(WidgetTester tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 62, bottom: 34);
    tester.view.viewPadding = const FakeViewPadding(top: 62, bottom: 34);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialLocationProvider.overrideWithValue(AppRoutes.login),
          notificationServiceProvider.overrideWithValue(
            FakeNotificationService(),
          ),
          // 첫 로그인 뒤 끝 화면은 인트로 테스트에서 다룬다. 여기서는 이미 본 상태로 둔다.
          introStoreProvider.overrideWithValue(InMemoryIntroStore(true, true)),
          authRepositoryProvider.overrideWithValue(auth),
          appErrorLogProvider.overrideWithValue(errorLog),
        ],
        child: const RebornApp(),
      ),
    );
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
  }

  Finder wordmark() => find.byWidgetPredicate(
    (w) =>
        w is Image &&
        w.image is AssetImage &&
        (w.image as AssetImage).assetName == AppAssets.logo,
  );

  Future<void> fillLogin(WidgetTester tester, String email, String pw) async {
    await tester.enterText(find.byKey(const Key('login-email')), email);
    await tester.enterText(find.byKey(const Key('login-password')), pw);
    await tester.tap(find.byKey(const Key('login-submit')));
  }

  group('로그인', () {
    testWidgets('워드마크·입력·버튼·약관 안내가 좌우 44 여백 안에 그려진다', (tester) async {
      await pumpLogin(tester);

      final logo = tester.getRect(wordmark());
      expect(logo.left, closeTo(44, 0.5));
      expect(logo.size, const Size(314, 78));

      final email = tester.getRect(find.byKey(const Key('login-email')));
      final button = tester.getRect(find.byKey(const Key('login-submit')));
      expect(email.top, greaterThan(logo.bottom));
      expect(email.width, closeTo(314, 0.5));
      expect(button.height, 55);
      expect(button.width, closeTo(314, 0.5));
      expect(find.text('이메일로 회원가입'), findsOneWidget);

      // 약관 안내: 글자 아래가 안전 영역 위 14(화면 아래에서 48).
      final legal = tester.getRect(find.byKey(const Key('login-legal')));
      expect(legal.bottom, closeTo(874 - 48, 0.5));
      expect(legal.center.dx, closeTo(201, 0.5));
      expect(find.textContaining('로그인은 '), findsOneWidget);
    });

    testWidgets('데모 계정으로 로그인하면 투데이로 가고, 로그인 상태가 기기에 남는다', (tester) async {
      final c = await pumpLogin(tester);

      await fillLogin(
        tester,
        '  Demo@Reborn.app ',
        InMemoryAuthRepository.demoPassword,
      );
      await tester.pumpAndSettle();

      expect(find.byType(TodayScreen), findsOneWidget);
      expect(c.read(sessionProvider)?.email, InMemoryAuthRepository.demoEmail);
      expect(store.sessionEmail, InMemoryAuthRepository.demoEmail);
      // 다시 켠 것처럼 저장소에서 새로 만들면 로그인된 채로 시작한다.
      expect(
        InMemoryAuthRepository(store: store).currentUser?.email,
        InMemoryAuthRepository.demoEmail,
      );
    });

    testWidgets('형식이 틀리면 서버에 보내지 않고 입력창 아래에 안내한다', (tester) async {
      await pumpLogin(tester);

      await fillLogin(tester, 'not-an-email', '');
      await tester.pumpAndSettle();

      expect(find.text('이메일 형식이 올바르지 않아요.'), findsOneWidget);
      expect(find.text('비밀번호를 입력해 주세요.'), findsOneWidget);
      expect(auth.signInCalls, 0);

      // 다시 입력하면 안내가 사라진다.
      await tester.enterText(find.byKey(const Key('login-email')), 'a@b.co');
      await tester.pump();
      expect(find.text('이메일 형식이 올바르지 않아요.'), findsNothing);
    });

    testWidgets('비밀번호가 틀리면 비밀번호 아래에 안내하고 로그인 화면에 있다', (tester) async {
      final c = await pumpLogin(tester);

      await fillLogin(tester, InMemoryAuthRepository.demoEmail, 'wrongpass1');
      await tester.pumpAndSettle();

      expect(
        find.text(
          const AuthFailure(AuthFailureType.invalidCredentials).message,
        ),
        findsOneWidget,
      );
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(c.read(sessionProvider), isNull);
      expect(store.sessionEmail, isNull);
    });

    testWidgets('네트워크 오류는 토스트로 알리고 다시 누를 수 있다', (tester) async {
      await pumpLogin(tester);
      auth.error = const AuthFailure(AuthFailureType.network);

      await fillLogin(
        tester,
        InMemoryAuthRepository.demoEmail,
        InMemoryAuthRepository.demoPassword,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.text(const AuthFailure(AuthFailureType.network).message),
        findsOneWidget,
      );
      await tester.pumpAndSettle(const Duration(seconds: 4));

      auth.error = null;
      await tester.tap(find.byKey(const Key('login-submit')));
      await tester.pumpAndSettle();
      expect(find.byType(TodayScreen), findsOneWidget);
      expect(auth.signInCalls, 2);
    });

    testWidgets('알 수 없는 오류는 일반 안내를 보여 주고 오류 기록에 남긴다', (tester) async {
      await pumpLogin(tester);
      auth.error = StateError('boom');

      await fillLogin(
        tester,
        InMemoryAuthRepository.demoEmail,
        InMemoryAuthRepository.demoPassword,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.text(const AuthFailure(AuthFailureType.unknown).message),
        findsOneWidget,
      );
      expect(errorLog.entries.single.where, 'login');
      await tester.pumpAndSettle(const Duration(seconds: 4));
    });

    testWidgets('로그인 중에는 버튼이 막혀 연타해도 한 번만 보낸다', (tester) async {
      await pumpLogin(tester);
      auth.hold = Completer<void>();

      await fillLogin(
        tester,
        InMemoryAuthRepository.demoEmail,
        InMemoryAuthRepository.demoPassword,
      );
      await tester.pump();
      expect(find.text('로그인 중…'), findsOneWidget);

      await tester.tap(find.byKey(const Key('login-submit')));
      await tester.pump();
      expect(auth.signInCalls, 1);

      auth.hold!.complete();
      await tester.pumpAndSettle();
      expect(find.byType(TodayScreen), findsOneWidget);
    });

    testWidgets('약관 안내의 두 링크가 각각 내용을 연다', (tester) async {
      await pumpLogin(tester);

      await tester.tap(find.byKey(const Key('login-legal-서비스 이용약관')));
      await tester.pumpAndSettle();
      expect(find.text('서비스 이용약관'), findsOneWidget);
      await tester.tapAt(const Offset(201, 100)); // 바깥을 눌러 닫는다
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('login-legal-개인정보 수집·이용')));
      await tester.pumpAndSettle();
      expect(find.text('개인정보 수집·이용'), findsOneWidget);
    });
  });

  group('회원가입', () {
    Future<void> openSignup(WidgetTester tester) async {
      await tester.tap(find.byKey(const Key('login-signup')));
      await tester.pumpAndSettle();
      expect(find.byType(SignupScreen), findsOneWidget);
    }

    Future<void> fillSignup(
      WidgetTester tester, {
      String email = 'new@reborn.app',
      String nickname = '리본이',
      String password = 'password1',
      String? confirm,
    }) async {
      await tester.enterText(find.byKey(const Key('signup-email')), email);
      await tester.enterText(
        find.byKey(const Key('signup-nickname')),
        nickname,
      );
      await tester.enterText(
        find.byKey(const Key('signup-password')),
        password,
      );
      await tester.enterText(
        find.byKey(const Key('signup-confirm')),
        confirm ?? password,
      );
      await tester.tap(find.text('가입하기'));
      await tester.pumpAndSettle();
    }

    testWidgets('가입하면 바로 투데이로 가고, 닉네임·필수 동의가 저장된다', (tester) async {
      final c = await pumpLogin(tester);
      await openSignup(tester);

      await fillSignup(tester);

      expect(find.byType(TodayScreen), findsOneWidget);
      expect(c.read(sessionProvider)?.email, 'new@reborn.app');
      expect(store.sessionEmail, 'new@reborn.app');
      final settings = await c.read(settingsProvider.future);
      expect(settings.nickname, '리본이');
      expect(settings.consents.privacy, isTrue);
      expect(settings.consents.aiAnalysis, isTrue);
      expect(settings.consents.analytics, isFalse);
    });

    testWidgets('형식이 틀리면 각 입력창 아래에 안내하고 가입하지 않는다', (tester) async {
      final c = await pumpLogin(tester);
      await openSignup(tester);

      await fillSignup(
        tester,
        email: 'bad',
        nickname: ' ',
        password: 'short',
        confirm: 'other',
      );

      expect(find.text('이메일 형식이 올바르지 않아요.'), findsOneWidget);
      expect(find.text('닉네임을 입력해 주세요.'), findsOneWidget);
      expect(find.text('비밀번호는 8자 이상이어야 해요.'), findsOneWidget);
      expect(find.text('비밀번호가 서로 달라요.'), findsOneWidget);
      expect(find.byType(SignupScreen), findsOneWidget);
      expect(c.read(sessionProvider), isNull);
    });

    testWidgets('이미 가입된 이메일이면 이메일 아래에 안내한다', (tester) async {
      await pumpLogin(tester);
      await openSignup(tester);

      await fillSignup(tester, email: InMemoryAuthRepository.demoEmail);

      expect(
        find.text(const AuthFailure(AuthFailureType.emailTaken).message),
        findsOneWidget,
      );
      expect(find.byType(SignupScreen), findsOneWidget);
    });
  });

  test('가입한 계정으로 로그아웃 뒤 다시 로그인할 수 있고, 세션 저장소는 이메일만 남긴다', () async {
    final s = InMemoryAuthSessionStore();
    final repo = InMemoryAuthRepository(store: s);

    await repo.signUp(email: 'Me@Reborn.app', password: 'password1');
    expect(s.sessionEmail, 'me@reborn.app');

    await repo.signOut();
    expect(s.sessionEmail, isNull);
    expect(repo.currentUser, isNull);

    await expectLater(
      repo.signIn(email: 'me@reborn.app', password: 'wrongpass1'),
      throwsA(isA<AuthFailure>()),
    );
    final user = await repo.signIn(
      email: 'me@reborn.app',
      password: 'password1',
    );
    expect(user.email, 'me@reborn.app');
    expect(s.sessionEmail, 'me@reborn.app');

    await repo.deleteAccount(password: 'password1');
    expect(s.sessionEmail, isNull);
    await expectLater(
      repo.signIn(email: 'me@reborn.app', password: 'password1'),
      throwsA(isA<AuthFailure>()),
    );
  });
}
