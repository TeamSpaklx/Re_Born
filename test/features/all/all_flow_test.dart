import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/features/settings/presentation/consent_settings_screen.dart';
import 'package:reborn_app/features/auth/presentation/login_screen.dart';
import 'package:reborn_app/app/app.dart';
import 'package:reborn_app/app/data_providers.dart';
import 'package:reborn_app/app/main_shell.dart';
import 'package:reborn_app/app/theme/app_spacing.dart';
import 'package:reborn_app/core/platform/image_picker_service.dart';
import 'package:reborn_app/core/providers/clock_provider.dart';
import 'package:reborn_app/features/auth/data/in_memory_auth_repository.dart';
import 'package:reborn_app/features/auth/presentation/auth_providers.dart';
import 'package:reborn_app/shared/widgets/app_bottom_nav_bar.dart';
import 'package:reborn_app/shared/widgets/app_toggle.dart';

final fixedNow = DateTime(2026, 10, 22, 12);

/// 고른 사진 경로를 정해 둔 가짜 선택기. [fail]이면 권한 거부처럼 실패한다.
class _FakePicker implements ImagePickerService {
  _FakePicker({this.path, this.fail = false});

  final String? path;
  final bool fail;
  final picked = <PhotoSource>[];

  @override
  Future<String?> pick(PhotoSource source) async {
    picked.add(source);
    if (fail) throw PhotoPickException(source);
    return path;
  }
}

void main() {
  Future<ProviderContainer> pumpAll(
    WidgetTester tester, {
    bool signedIn = false,
    ImagePickerService? picker,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(402, 1400);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clockProvider.overrideWithValue(() => fixedNow),
          if (picker != null)
            imagePickerServiceProvider.overrideWithValue(picker),
          if (signedIn)
            authRepositoryProvider.overrideWithValue(
              InMemoryAuthRepository(
                signedInEmail: InMemoryAuthRepository.demoEmail,
              ),
            ),
        ],
        child: const RebornApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AppBottomNavBar),
        matching: find.text('마이'),
      ),
    );
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(MainShell)));
  }

  testWidgets('마이 탭: 설정이 보이고 체크리스트는 없다(기록 탭으로 옮김)', (tester) async {
    await pumpAll(tester);

    expect(find.text('체크리스트'), findsNothing);
    expect(find.byKey(const Key('todo-title')), findsNothing);
    // 설정은 카드 밖 소제목으로 묶인다(레퍼런스 설정 화면 구조).
    expect(find.text('개인정보 보호 및 보안'), findsOneWidget);
    expect(find.text('앱 사용'), findsOneWidget);
    expect(find.text('계정'), findsOneWidget);
  });

  testWidgets('개인정보 안내 카드를 누르면 보호 방식 설명이 열린다', (tester) async {
    await pumpAll(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('privacy-info')),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.tap(find.byKey(const Key('privacy-info')));
    await tester.pumpAndSettle();

    expect(find.text('내 기록은 이렇게 지켜요'), findsOneWidget);
    expect(find.textContaining('외부 AI에 기록을 보내지 않아요'), findsOneWidget);
  });

  testWidgets('T-30: 동의 관리 화면에서 동의를 끄면 설정에 저장된다', (tester) async {
    final container = await pumpAll(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('open-consents')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('open-consents')));
    await tester.pumpAndSettle();
    expect(find.byType(ConsentSettingsScreen), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('consent-ai')),
        matching: find.byType(AppToggle),
      ),
    );
    await tester.pumpAndSettle();

    final settings = await container.read(settingsRepositoryProvider).get();
    expect(settings.consents.aiAnalysis, isFalse);
    expect(settings.consents.privacy, isTrue);

    // 자세히 보기는 내용 시트를 연다.
    await tester.tap(find.byKey(const Key('consent-detail-ai')));
    await tester.pumpAndSettle();
    expect(find.textContaining('외부 AI 서비스로 보내지 않아요'), findsOneWidget);
  });

  testWidgets('F-11: 기록 전체 삭제는 확인 후 일기를 지우고 체크리스트는 남긴다', (tester) async {
    final container = await pumpAll(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('delete-records')),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.tap(find.byKey(const Key('delete-records')));
    await tester.pumpAndSettle();
    expect(find.text('기록을 모두 삭제할까요?'), findsOneWidget);
    await tester.tap(find.text('삭제').last);
    await tester.pumpAndSettle();

    expect(await container.read(entriesRepositoryProvider).list(), isEmpty);
    expect(await container.read(todosRepositoryProvider).list(), isNotEmpty);
  });

  testWidgets('계정 삭제 행은 재인증 화면으로 이동한다', (tester) async {
    await pumpAll(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('delete-account')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('delete-account')));
    await tester.pumpAndSettle();
    expect(find.text('계정을\n삭제할까요?'), findsOneWidget);
    expect(find.byKey(const Key('delete-password')), findsOneWidget);
  });

  testWidgets('로그아웃은 확인 뒤 세션을 지우고 로그인 화면으로 간다', (tester) async {
    final container = await pumpAll(tester, signedIn: true);
    await tester.scrollUntilVisible(
      find.byKey(const Key('logout')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('logout')));
    await tester.pumpAndSettle();
    expect(find.text('로그아웃할까요?'), findsOneWidget);
    await tester.tap(find.text('로그아웃').last);
    await tester.pumpAndSettle();

    expect(container.read(sessionProvider), isNull);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('프로필: 닉네임과 이메일이 보이고 닉네임을 바꿀 수 있다', (tester) async {
    final container = await pumpAll(tester, signedIn: true);
    expect(find.text('규리'), findsOneWidget);
    expect(find.text(InMemoryAuthRepository.demoEmail), findsOneWidget);

    await tester.tap(find.text('규리'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('nickname-field')), '새이름');
    await tester.pumpAndSettle();
    await tester.tap(find.text('저장'));
    await tester.pump();
    await tester.pump(ComponentLayout.toastFade);

    expect(
      (await container.read(settingsRepositoryProvider).get()).nickname,
      '새이름',
    );
    expect(find.text('닉네임을 바꿨어요'), findsOneWidget);
  });

  testWidgets('요약 카드: 총 기록·연속 기록·최장 연속이 보인다', (tester) async {
    final container = await pumpAll(tester);
    final count =
        (await container.read(entriesRepositoryProvider).list()).length;
    expect(find.text('총 기록'), findsOneWidget);
    expect(find.text('$count'), findsOneWidget);
    expect(find.text('5일'), findsOneWidget, reason: '샘플은 최근 5일 연속');
    expect(find.text('20일'), findsOneWidget, reason: '샘플 최장 20일');
  });

  testWidgets('프로필 편집: 앨범에서 사진을 고르면 저장되고, 기본 캐릭터로 되돌릴 수 있다', (tester) async {
    final picker = _FakePicker(path: '/tmp/none.jpg');
    final container = await pumpAll(tester, signedIn: true, picker: picker);
    await tester.tap(find.text('규리'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('profile-reset')), findsNothing);

    await tester.tap(find.byKey(const Key('profile-gallery')));
    await tester.pumpAndSettle();
    expect(picker.picked, [PhotoSource.gallery]);
    expect(
      (await container.read(settingsRepositoryProvider).get()).profileImagePath,
      '/tmp/none.jpg',
    );

    await tester.tap(find.byKey(const Key('profile-reset')));
    await tester.pumpAndSettle();
    expect(
      (await container.read(settingsRepositoryProvider).get()).profileImagePath,
      isNull,
    );
  });

  testWidgets('프로필 편집: 카메라 권한이 거부되면 안내 토스트가 나온다', (tester) async {
    final container = await pumpAll(
      tester,
      signedIn: true,
      picker: _FakePicker(fail: true),
    );
    await tester.tap(find.text('규리'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile-camera')));
    await tester.pump();
    await tester.pump(ComponentLayout.toastFade);

    expect(find.textContaining('카메라를 쓸 수 없어요'), findsOneWidget);
    expect(
      (await container.read(settingsRepositoryProvider).get()).profileImagePath,
      isNull,
    );
    await tester.pump(const Duration(seconds: 4));
  });
}
