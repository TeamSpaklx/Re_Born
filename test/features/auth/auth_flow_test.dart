import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/app/app.dart';
import 'package:reborn_app/app/data_providers.dart';
import 'package:reborn_app/app/router.dart';
import 'package:reborn_app/features/auth/data/in_memory_auth_repository.dart';
import 'package:reborn_app/features/auth/models/auth_validator.dart';
import 'package:reborn_app/features/auth/presentation/auth_providers.dart';
import 'package:reborn_app/features/auth/presentation/login_screen.dart';
import 'package:reborn_app/features/people/presentation/people_providers.dart';

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
}
