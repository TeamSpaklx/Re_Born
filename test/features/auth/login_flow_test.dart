import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/app/app.dart';
import 'package:reborn_app/app/data_providers.dart';
import 'package:reborn_app/app/router.dart';
import 'package:reborn_app/app/theme/app_assets.dart';
import 'package:reborn_app/app/theme/app_text_styles.dart';
import 'package:reborn_app/core/errors/app_error_log.dart';
import 'package:reborn_app/features/auth/data/auth_session_store.dart';
import 'package:reborn_app/features/auth/data/in_memory_auth_repository.dart';
import 'package:reborn_app/features/auth/models/auth_user.dart';
import 'package:reborn_app/features/auth/presentation/auth_providers.dart';
import 'package:reborn_app/features/auth/presentation/login_screen.dart';
import 'package:reborn_app/features/home/presentation/today_screen.dart';
import 'package:reborn_app/features/onboarding/data/intro_store.dart';
import 'package:reborn_app/features/settings/presentation/settings_providers.dart';

import '../../helpers/fakes.dart';

/// 소셜 로그인 호출 수를 세고, [hold]가 있으면 그 Future가 끝날 때까지 응답을 미룬다.
class _CountingAuth extends InMemoryAuthRepository {
  _CountingAuth({super.store});

  int socialCalls = 0;
  Completer<void>? hold;

  @override
  Future<SocialSignInResult> signInWithSocial(SocialProvider provider) async {
    socialCalls++;
    await hold?.future;
    return super.signInWithSocial(provider);
  }
}

void main() {
  late InMemoryAuthSessionStore store;
  late _CountingAuth auth;
  late AppErrorLog errorLog;

  setUp(() {
    store = InMemoryAuthSessionStore();
    auth = _CountingAuth(store: store);
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

  testWidgets('워드마크·버튼·약관 안내가 Figma 위치(402×874)에 그려진다', (tester) async {
    await pumpLogin(tester);

    // 워드마크 314×78, x=44, y=331.
    final logo = tester.getRect(wordmark());
    expect(logo.left, closeTo(44, 0.5));
    expect(logo.top, closeTo(331, 1));
    expect(logo.size, const Size(314, 78));

    // 버튼: 구글 y=615, 카카오 y=686(사이 16), 폭 314, 높이 55.
    final google = tester.getRect(find.byKey(const Key('social-google')));
    final kakao = tester.getRect(find.byKey(const Key('social-kakao')));
    expect(google.left, closeTo(44, 0.5));
    expect(google.width, closeTo(314, 0.5));
    expect(google.height, 55);
    expect(kakao.top - google.bottom, 16);
    expect(kakao.top, closeTo(686, 2));

    // 약관 안내: 버튼 아래 57, 글자 아래가 안전 영역 위 14(화면 아래에서 48).
    final legal = tester.getRect(find.byKey(const Key('login-legal')));
    expect(legal.top - kakao.bottom, 57);
    expect(legal.bottom, closeTo(874 - 48, 0.5));
    expect(legal.center.dx, closeTo(201, 0.5));

    // Scaffold 없이 그려도 글자에 기본(노란 밑줄) 스타일이 새지 않는다.
    final label = tester.widget<Text>(find.text('구글로 로그인'));
    final effective = DefaultTextStyle.of(
      tester.element(find.text('구글로 로그인')),
    ).style.merge(label.style);
    expect(effective.decoration, isNot(TextDecoration.underline));
    expect(
      DefaultTextStyle.of(
        tester.element(find.text('구글로 로그인')),
      ).style.fontFamily,
      AppTextStyles.fontFamily,
    );
  });

  testWidgets('기존 회원은 투데이로 가고, 로그인 상태가 기기에 남는다', (tester) async {
    store.members = {SocialProvider.google};
    auth = _CountingAuth(store: store);
    final c = await pumpLogin(tester);

    await tester.tap(find.byKey(const Key('social-google')));
    await tester.pumpAndSettle();

    expect(find.byType(TodayScreen), findsOneWidget);
    expect(c.read(sessionProvider)?.provider, SocialProvider.google);
    expect(store.session, SocialProvider.google);

    // 다시 켠 것처럼 저장소에서 새로 만들면 로그인된 채로 시작한다.
    expect(
      InMemoryAuthRepository(store: store).currentUser?.provider,
      SocialProvider.google,
    );
  });

  testWidgets('신규 회원도 바로 투데이로 가고, 닉네임·필수 동의가 기본값으로 저장된다', (tester) async {
    final c = await pumpLogin(tester);

    await tester.tap(find.byKey(const Key('social-kakao')));
    await tester.pumpAndSettle();

    expect(find.byType(TodayScreen), findsOneWidget);
    expect(c.read(sessionProvider)?.provider, SocialProvider.kakao);
    final settings = await c.read(settingsProvider.future);
    expect(settings.nickname, '카카오 사용자');
    expect(settings.consents.privacy, isTrue);
    expect(settings.consents.aiAnalysis, isTrue);
    expect(settings.consents.analytics, isFalse);
    // 로그인 상태가 바로 기기에 남고, 다음부터는 기존 회원이다.
    expect(store.session, SocialProvider.kakao);
    expect(store.members, {SocialProvider.kakao});
  });

  testWidgets('사용자가 로그인 창을 닫으면 안내 없이 로그인 화면에 그대로 있다', (tester) async {
    final c = await pumpLogin(tester);
    auth.nextOutcome = SocialOutcome.cancelled;

    await tester.tap(find.byKey(const Key('social-google')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('로그인을 취소했어요.'), findsNothing);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(c.read(sessionProvider), isNull);
    expect(errorLog.entries, isEmpty);
    await tester.pumpAndSettle(const Duration(seconds: 4));
  });

  testWidgets('네트워크 오류는 토스트로 알리고 다시 누를 수 있다', (tester) async {
    await pumpLogin(tester);
    auth.nextOutcome = SocialOutcome.network;

    await tester.tap(find.byKey(const Key('social-kakao')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.text(const AuthFailure(AuthFailureType.network).message),
      findsOneWidget,
    );
    await tester.pumpAndSettle(const Duration(seconds: 4));

    auth.nextOutcome = SocialOutcome.auto;
    await tester.tap(find.byKey(const Key('social-kakao')));
    await tester.pumpAndSettle();
    expect(find.byType(TodayScreen), findsOneWidget);
    expect(auth.socialCalls, 2);
  });

  testWidgets('알 수 없는 오류는 일반 안내를 보여 주고 오류 기록에 남긴다', (tester) async {
    await pumpLogin(tester);
    auth.nextOutcome = SocialOutcome.unknown;

    await tester.tap(find.byKey(const Key('social-google')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.text(const AuthFailure(AuthFailureType.unknown).message),
      findsOneWidget,
    );
    expect(errorLog.entries.single.where, 'social-login');
    await tester.pumpAndSettle(const Duration(seconds: 4));
  });

  testWidgets('응답이 30초 넘게 없으면 네트워크 오류로 안내한다', (tester) async {
    await pumpLogin(tester);
    auth.hold = Completer<void>();

    await tester.tap(find.byKey(const Key('social-google')));
    await tester.pump(AuthActions.socialSignInTimeout);
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.text(const AuthFailure(AuthFailureType.network).message),
      findsOneWidget,
    );
    auth.hold!.complete();
    await tester.pumpAndSettle(const Duration(seconds: 4));
  });

  testWidgets('로그인 중에는 두 버튼이 모두 막히고 누른 버튼에 로딩이 보인다', (tester) async {
    await pumpLogin(tester);
    auth.hold = Completer<void>();

    await tester.tap(find.byKey(const Key('social-google')));
    await tester.pump();
    expect(find.bySemanticsLabel('구글로 로그인, 로그인 중'), findsOneWidget);

    await tester.tap(find.byKey(const Key('social-google')));
    await tester.tap(find.byKey(const Key('social-kakao')));
    await tester.pump();
    expect(auth.socialCalls, 1);

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

  testWidgets('디버그 패널: 워드마크를 길게 눌러 다음 결과를 고를 수 있다', (tester) async {
    await pumpLogin(tester);

    await tester.longPress(find.byKey(const Key('login-debug-trigger')));
    await tester.pumpAndSettle();
    expect(find.text('다음 로그인 결과 (디버그)'), findsOneWidget);

    await tester.tap(find.byKey(const Key('debug-outcome-network')));
    await tester.tap(find.byKey(const Key('debug-latency')));
    await tester.pump();

    expect(auth.nextOutcome, SocialOutcome.network);
    expect(auth.latency, const Duration(seconds: 2));
  });

  test('세션 저장소: 동의를 마친 소셜 로그인만 남고, 로그아웃·계정 삭제는 지운다', () async {
    final s = InMemoryAuthSessionStore();
    final repo = InMemoryAuthRepository(store: s);

    await repo.signInWithSocial(SocialProvider.google);
    expect(s.session, isNull, reason: '첫 설정 저장 전');
    await repo.completeSocialSignup();
    expect(s.session, SocialProvider.google);

    await repo.signOut();
    expect(s.session, isNull);
    expect(s.members, {SocialProvider.google});

    final again = await repo.signInWithSocial(SocialProvider.google);
    expect(again.isNewUser, isFalse);
    await repo.deleteAccount();
    expect(s.session, isNull);
    expect(s.members, isEmpty);
  });
}
