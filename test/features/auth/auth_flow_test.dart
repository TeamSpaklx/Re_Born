import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/app/app.dart';
import 'package:reborn_app/app/data_providers.dart';
import 'package:reborn_app/app/router.dart';
import 'package:reborn_app/features/auth/data/in_memory_auth_repository.dart';
import 'package:reborn_app/features/auth/models/auth_user.dart';
import 'package:reborn_app/features/auth/models/auth_validator.dart';
import 'package:reborn_app/features/auth/presentation/auth_providers.dart';
import 'package:reborn_app/features/auth/presentation/login_screen.dart';
import 'package:reborn_app/features/home/presentation/today_screen.dart';
import 'package:reborn_app/features/people/presentation/people_providers.dart';
import 'package:reborn_app/features/settings/presentation/settings_providers.dart';

import '../../helpers/fakes.dart';

void main() {
  late FakeNotificationService notifications;

  setUp(() => notifications = FakeNotificationService());

  Future<ProviderContainer> pumpAt(
    WidgetTester tester,
    String location, {
    bool signedIn = false,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(402, 1000);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialLocationProvider.overrideWithValue(location),
          notificationServiceProvider.overrideWithValue(notifications),
          authRepositoryProvider.overrideWithValue(
            InMemoryAuthRepository(
              signedInEmail: signedIn ? InMemoryAuthRepository.demoEmail : null,
            ),
          ),
        ],
        child: const RebornApp(),
      ),
    );
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
  }

  group('검증', () {
    test('T-02: 이메일 형식과 비밀번호 8자 이상', () {
      expect(AuthValidator.validateEmail('abc'), isNotNull);
      expect(AuthValidator.validateEmail('a@b.co'), isNull);
      expect(AuthValidator.validatePassword('1234567'), isNotNull);
      expect(AuthValidator.validatePassword('12345678'), isNull);
      expect(
        AuthValidator.validatePasswordConfirm('12345678', '1234567'),
        isNotNull,
      );
      expect(AuthValidator.validateNickname('   '), isNotNull);
      expect(AuthValidator.validateNickname('열세글자를넘는닉네임입니다만'), isNotNull);
    });
  });

  group('로그인', () {
    testWidgets('형식이 틀리면 필드별 문구가 나오고 요청하지 않는다', (tester) async {
      final c = await pumpAt(tester, AppRoutes.login);
      await tester.enterText(find.byKey(const Key('login-email')), 'abc');
      await tester.tap(find.text('로그인').last);
      await tester.pumpAndSettle();

      expect(find.text('이메일 형식이 올바르지 않아요.'), findsOneWidget);
      expect(find.text('비밀번호를 입력해 주세요.'), findsOneWidget);
      expect(c.read(sessionProvider), isNull);
    });

    testWidgets('비밀번호가 틀리면 안내 문구가 나오고 다시 시도할 수 있다', (tester) async {
      final c = await pumpAt(tester, AppRoutes.login);
      await tester.enterText(
        find.byKey(const Key('login-email')),
        InMemoryAuthRepository.demoEmail,
      );
      await tester.enterText(
        find.byKey(const Key('login-password')),
        'wrongpass1',
      );
      await tester.tap(find.text('로그인').last);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('login-error')), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('login-password')),
        InMemoryAuthRepository.demoPassword,
      );
      await tester.tap(find.text('로그인').last);
      await tester.pumpAndSettle();

      expect(c.read(sessionProvider)?.email, InMemoryAuthRepository.demoEmail);
      expect(find.byType(TodayScreen), findsOneWidget);
    });
  });

  group('가입', () {
    Future<void> fillSignup(
      WidgetTester tester, {
      String password = 'abcd1234',
    }) async {
      await tester.enterText(
        find.byKey(const Key('signup-email')),
        'new@reborn.app',
      );
      await tester.enterText(find.byKey(const Key('signup-nickname')), '하늘');
      await tester.enterText(
        find.byKey(const Key('signup-password')),
        password,
      );
      await tester.enterText(find.byKey(const Key('signup-confirm')), password);
    }

    testWidgets('T-02: 잘못된 입력이면 다음 단계로 가지 않는다', (tester) async {
      await pumpAt(tester, AppRoutes.signup);
      await tester.enterText(find.byKey(const Key('signup-email')), 'abc');
      await tester.enterText(
        find.byKey(const Key('signup-password')),
        '1234567',
      );
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();

      expect(find.text('이메일 형식이 올바르지 않아요.'), findsOneWidget);
      expect(find.text('비밀번호는 8자 이상이어야 해요.'), findsOneWidget);
      expect(find.text('약관에\n동의해 주세요'), findsNothing);
    });

    testWidgets('T-03: 필수 동의 없이는 가입되지 않고, 동의하면 온보딩까지 이어진다', (tester) async {
      final c = await pumpAt(tester, AppRoutes.signup);
      await fillSignup(tester);
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('동의하고 가입하기'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('consent-error')), findsOneWidget);
      expect(c.read(sessionProvider), isNull);

      await tester.tap(find.byKey(const Key('consent-all')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('동의하고 가입하기'));
      await tester.pumpAndSettle();

      expect(c.read(sessionProvider)?.email, 'new@reborn.app');
      final settings = await c.read(settingsProvider.future);
      expect(settings.nickname, '하늘');
      expect(settings.consents.privacy, isTrue);
      expect(settings.consents.aiAnalysis, isTrue);

      // 온보딩: 이름을 비우면 막히고, 입력하면 인물이 생기고 알림 안내로 간다.
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      expect(find.text('이름을 입력해 주세요.'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('onboarding-name')), '서윤');
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      final people = await c.read(peopleProvider.future);
      expect(people.any((p) => p.name == '서윤'), isTrue);

      expect(find.text('알림을 켜면\n더 도움이 돼요'), findsOneWidget);
      await tester.tap(find.text('알림 켜기'));
      await tester.pumpAndSettle();
      expect(find.byType(TodayScreen), findsOneWidget);
      expect(
        (await c.read(settingsProvider.future)).notifications.reminder,
        isTrue,
      );
    });

    testWidgets('T-04: 이미 가입된 이메일이면 안내하고 가입 화면으로 돌아온다', (tester) async {
      await pumpAt(tester, AppRoutes.signup);
      await tester.enterText(
        find.byKey(const Key('signup-email')),
        InMemoryAuthRepository.demoEmail,
      );
      await tester.enterText(find.byKey(const Key('signup-nickname')), '하늘');
      await tester.enterText(
        find.byKey(const Key('signup-password')),
        'abcd1234',
      );
      await tester.enterText(
        find.byKey(const Key('signup-confirm')),
        'abcd1234',
      );
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('consent-all')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('동의하고 가입하기'));
      await tester.pump();
      await tester.pump();

      expect(find.text('이미 가입된 이메일이에요. 로그인해 주세요.'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 4));
      expect(find.byKey(const Key('signup-email')), findsOneWidget);
    });
  });

  testWidgets('T-31: 계정 삭제는 확인 체크와 비밀번호 재인증이 필요하고 데이터를 지운다', (tester) async {
    final c = await pumpAt(tester, AppRoutes.accountDelete, signedIn: true);

    // 확인 체크 전에는 삭제 버튼이 눌리지 않는다.
    await tester.tap(find.text('계정 삭제'));
    await tester.pumpAndSettle();
    expect(c.read(sessionProvider), isNotNull);

    await tester.tap(find.byKey(const Key('delete-confirm')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('delete-password')),
      'wrongpass1',
    );
    await tester.tap(find.text('계정 삭제'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();
    expect(find.text('비밀번호가 맞지 않아요.'), findsOneWidget);
    expect(c.read(sessionProvider), isNotNull);

    await tester.enterText(
      find.byKey(const Key('delete-password')),
      InMemoryAuthRepository.demoPassword,
    );
    await tester.tap(find.text('계정 삭제'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();

    expect(find.text('계정을 삭제했어요'), findsOneWidget);
    expect(c.read(sessionProvider), isNull);
    expect(await c.read(peopleProvider.future), isEmpty);

    await tester.tap(find.text('처음으로'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  group('소셜 로그인', () {
    testWidgets('처음 카카오로 들어오면 약관 동의 → 온보딩으로 이어진다', (tester) async {
      final c = await pumpAt(tester, AppRoutes.login);
      await tester.tap(find.byKey(const Key('social-kakao')));
      await tester.pumpAndSettle();

      expect(c.read(sessionProvider)?.provider, SocialProvider.kakao);
      expect(find.text('약관에\n동의해 주세요'), findsOneWidget);

      await tester.tap(find.byKey(const Key('consent-all')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('동의하고 가입하기'));
      await tester.pumpAndSettle();

      final settings = await c.read(settingsProvider.future);
      expect(settings.nickname, '카카오 사용자');
      expect(settings.consents.privacy, isTrue);
      expect(find.byKey(const Key('onboarding-name')), findsOneWidget);
    });

    testWidgets('이미 가입한 소셜 계정은 바로 홈으로 간다', (tester) async {
      final c = await pumpAt(tester, AppRoutes.login);
      final repo = c.read(authRepositoryProvider);
      await repo.signInWithSocial(SocialProvider.google); // 처음 한 번
      await repo.signOut();

      await tester.tap(find.byKey(const Key('social-google')));
      await tester.pumpAndSettle();
      expect(find.byType(TodayScreen), findsOneWidget);
    });

    testWidgets('가입 화면에도 소셜 버튼이 있고, 소셜 계정 삭제는 비밀번호 없이 된다', (tester) async {
      final c = await pumpAt(tester, AppRoutes.signup);
      expect(find.byKey(const Key('social-kakao')), findsOneWidget);
      expect(find.byKey(const Key('social-google')), findsOneWidget);

      await c.read(authActionsProvider).signInWithSocial(SocialProvider.google);
      c.read(routerProvider).go(AppRoutes.accountDelete);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('delete-password')), findsNothing);

      await tester.tap(find.byKey(const Key('delete-confirm')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('계정 삭제'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('삭제'));
      await tester.pumpAndSettle();
      expect(find.text('계정을 삭제했어요'), findsOneWidget);
      expect(c.read(sessionProvider), isNull);
    });
  });

  testWidgets('알림 권한이 거부되면 리마인드는 꺼진 채 안내하고 홈으로 간다', (tester) async {
    notifications.allowed = false;
    final c = await pumpAt(
      tester,
      AppRoutes.onboardingPermission,
      signedIn: true,
    );
    await tester.tap(find.text('알림 켜기'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('알림 권한이 꺼져 있어요'), findsOneWidget);
    final prefs = (await c.read(settingsProvider.future)).notifications;
    expect(prefs.reminder, isFalse);
    expect(prefs.insight, isTrue);
    expect(notifications.scheduled, isEmpty);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.byType(TodayScreen), findsOneWidget);
  });
}
