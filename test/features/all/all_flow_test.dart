import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/app/app.dart';
import 'package:reborn_app/app/data_providers.dart';
import 'package:reborn_app/app/main_shell.dart';
import 'package:reborn_app/app/theme/app_spacing.dart';
import 'package:reborn_app/core/platform/image_picker_service.dart';
import 'package:reborn_app/core/providers/clock_provider.dart';
import 'package:reborn_app/features/auth/data/in_memory_auth_repository.dart';
import 'package:reborn_app/features/auth/presentation/auth_providers.dart';
import 'package:reborn_app/features/auth/presentation/login_screen.dart';
import 'package:reborn_app/features/todos/data/in_memory_todos_repository.dart';
import 'package:reborn_app/features/todos/models/todo.dart';
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
    bool emptyTodos = false,
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
          if (emptyTodos)
            todosRepositoryProvider.overrideWithValue(
              InMemoryTodosRepository(),
            ),
        ],
        child: const RebornApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AppBottomNavBar),
        matching: find.text('전체'),
      ),
    );
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(MainShell)));
  }

  testWidgets('전체 탭: 체크리스트와 설정이 보인다', (tester) async {
    await pumpAll(tester);

    expect(find.text('체크리스트'), findsOneWidget);
    expect(find.text('지민님에게 가볍게 안부 묻기'), findsOneWidget);
    expect(find.text('이번 주 일기 3번 쓰기'), findsOneWidget);
    expect(find.text('1/2 완료 · 50%'), findsOneWidget);
    expect(find.text('설정'), findsOneWidget);
  });

  testWidgets('T-15: 항목을 추가하고 체크하면 상태가 저장되고 완료율이 바뀐다', (tester) async {
    final container = await pumpAll(tester);

    await tester.enterText(find.byKey(const Key('todo-title')), '하은에게 연락하기');
    await tester.tap(find.text('추가'));
    await tester.pumpAndSettle();
    expect(find.text('하은에게 연락하기'), findsOneWidget);
    expect(find.text('1/3 완료 · 33%'), findsOneWidget);

    final todos = await container.read(todosRepositoryProvider).list();
    final added = todos.firstWhere((t) => t.title == '하은에게 연락하기');
    await tester.tap(find.byKey(Key('todo-check-${added.id}')));
    await tester.pumpAndSettle();

    final after = (await container.read(todosRepositoryProvider).list())
        .firstWhere((t) => t.id == added.id);
    expect(after.done, isTrue);
    expect(after.doneAt, fixedNow);
    expect(find.text('2/3 완료 · 67%'), findsOneWidget);
  });

  testWidgets('T-16: 빈 제목은 저장되지 않는다', (tester) async {
    final container = await pumpAll(tester);
    final before =
        (await container.read(todosRepositoryProvider).list()).length;

    await tester.tap(find.text('추가'));
    await tester.pumpAndSettle();

    expect(find.text('제목을 입력해 주세요.'), findsOneWidget);
    expect(
      (await container.read(todosRepositoryProvider).list()).length,
      before,
    );
  });

  testWidgets('T-17: 항목이 없으면 빈 상태 안내가 나온다', (tester) async {
    await pumpAll(tester, emptyTodos: true);
    expect(find.text('체크리스트가 비어 있어요'), findsOneWidget);
    expect(find.text('0/0 완료 · 0%'), findsOneWidget);
  });

  testWidgets('삭제하면 항목이 사라진다', (tester) async {
    final container = await pumpAll(tester);
    final todo = (await container.read(todosRepositoryProvider).list()).first;

    await tester.tap(find.byKey(Key('todo-delete-${todo.id}')));
    await tester.pumpAndSettle();

    expect(await container.read(todosRepositoryProvider).list(), hasLength(1));
  });

  testWidgets('T-26: 인사이트의 제안을 체크리스트에 담으면 source = suggestion 항목이 생긴다', (
    tester,
  ) async {
    final container = await pumpAll(tester);
    final insight =
        (await container.read(insightsRepositoryProvider).list()).first;

    await tester.tap(
      find.descendant(
        of: find.byType(AppBottomNavBar),
        matching: find.text('관계'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('지민'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('최근 부정적인 기록이 늘었어요'));
    await tester.pumpAndSettle();

    expect(find.text('이렇게 해 보면 어떨까요?'), findsOneWidget);
    await tester.tap(find.text('체크리스트에 담기').first);
    await tester.pump(); // 토스트는 3초 뒤 사라지므로 settle하지 않고 바로 확인한다
    await tester.pump(ComponentLayout.toastFade);

    final todos = await container.read(todosRepositoryProvider).list();
    final added = todos.where(
      (t) => t.insightId == insight.id && t.source == TodoSource.suggestion,
    );
    expect(added.map((t) => t.title), contains('지민님에게 가볍게 안부 묻기'));
    expect(find.text('체크리스트에 담았어요'), findsWidgets);
    final opened = await container
        .read(insightsRepositoryProvider)
        .get(insight.id);
    expect(opened!.read, isTrue, reason: '열어 보면 읽음 처리');
  });

  testWidgets('T-30: 동의를 끄면 설정에 저장된다', (tester) async {
    final container = await pumpAll(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('consent-ai')),
      200,
      scrollable: find.byType(Scrollable).first,
    );

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
  });

  testWidgets('F-11: 기록 전체 삭제는 확인 후 기록·지수·인사이트를 지우고 인물은 남긴다', (tester) async {
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
    expect(await container.read(insightsRepositoryProvider).list(), isEmpty);
    expect(
      await container.read(indexHistoryRepositoryProvider).list('p1'),
      isEmpty,
    );
    expect(await container.read(peopleRepositoryProvider).list(), isNotEmpty);
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

  testWidgets('요약 카드: 기록·인물·체크 완료 수가 보인다', (tester) async {
    await pumpAll(tester);
    expect(find.text('체크 완료'), findsOneWidget);
    expect(find.text('1/2'), findsOneWidget);
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
