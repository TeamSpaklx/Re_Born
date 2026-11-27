import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/app/app.dart';
import 'package:reborn_app/app/data_providers.dart';
import 'package:reborn_app/app/router.dart';
import 'package:reborn_app/app/theme/app_colors.dart';
import 'package:reborn_app/app/theme/app_overlay_styles.dart';
import 'package:reborn_app/features/all/presentation/widgets/settings_section.dart';
import 'package:reborn_app/features/settings/data/theme_mode_store.dart';
import 'package:reborn_app/shared/widgets/app_toggle.dart';
import 'package:reborn_app/features/settings/presentation/settings_providers.dart';

import '../../helpers/fakes.dart';

/// 저장 횟수를 세고, 저장이 실패하게 만들 수 있는 저장소.
class _Store extends InMemoryThemeModeStore {
  _Store([super.dark, this.fail = false]);

  final bool fail;
  int saves = 0;

  @override
  Future<void> setDark(bool value) async {
    saves++;
    if (fail) throw StateError('disk full');
    return super.setDark(value);
  }
}

void main() {
  Future<ProviderContainer> pumpApp(
    WidgetTester tester,
    ThemeModeStore store, {
    String start = AppRoutes.today,
  }) async {
    tester.view.physicalSize = const Size(402, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialLocationProvider.overrideWithValue(start),
          notificationServiceProvider.overrideWithValue(
            FakeNotificationService(),
          ),
          themeModeStoreProvider.overrideWithValue(store),
        ],
        child: const RebornApp(),
      ),
    );
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
  }

  AppColors colorsOf(WidgetTester tester) => Theme.of(
    tester.element(find.byType(Scaffold).first),
  ).extension<AppColors>()!;

  testWidgets('저장된 값이 없으면 라이트로 시작한다', (tester) async {
    await pumpApp(tester, InMemoryThemeModeStore());
    expect(colorsOf(tester).background, AppColors.light.background);
  });

  testWidgets('다크로 저장돼 있으면 첫 화면부터 다크다', (tester) async {
    await pumpApp(tester, InMemoryThemeModeStore(true));
    expect(colorsOf(tester).background, const Color(0xFF0F1013));
  });

  testWidgets('컨트롤러가 라이트·다크를 바꾸고 저장한다', (tester) async {
    final store = _Store();
    final container = await pumpApp(tester, store);

    await container.read(themeModeProvider.notifier).setDark(true);
    await tester.pumpAndSettle();
    expect(colorsOf(tester).background, const Color(0xFF0F1013));
    expect(store.dark, isTrue);

    await container.read(themeModeProvider.notifier).setDark(false);
    await tester.pumpAndSettle();
    expect(colorsOf(tester).background, AppColors.light.background);
    expect(store.dark, isFalse);
    expect(store.saves, 2);
  });

  testWidgets('저장이 실패해도 이번 실행에서는 바로 다크가 된다', (tester) async {
    final container = await pumpApp(tester, _Store(false, true));
    await container.read(themeModeProvider.notifier).setDark(true);
    await tester.pumpAndSettle();
    expect(container.read(themeModeProvider), ThemeMode.dark);
    expect(colorsOf(tester).background, const Color(0xFF0F1013));
  });

  testWidgets('설정의 다크 모드 토글이 전체 화면에 적용된다', (tester) async {
    final store = _Store();
    await pumpApp(tester, store);

    final toggle = find.byKey(const Key('dark-mode-toggle'));
    // 전체 탭의 설정 구역까지 내려서 토글을 누른다.
    final nav = find.text('전체');
    await tester.tap(nav.last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      toggle,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(
      find.descendant(of: toggle, matching: find.byType(AppToggle)),
    );
    await tester.pumpAndSettle();

    expect(store.dark, isTrue);
    expect(colorsOf(tester).background, const Color(0xFF0F1013));
    expect(find.byType(SettingsSection), findsOneWidget);
  });

  testWidgets('상태 바 글자색이 앱 밝기를 따른다', (tester) async {
    final container = await pumpApp(tester, InMemoryThemeModeStore());
    SystemUiOverlayStyle? style() => tester
        .widgetList<AnnotatedRegion<SystemUiOverlayStyle>>(
          find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
        )
        .first
        .value;

    expect(style()?.statusBarIconBrightness, Brightness.dark);

    await container.read(themeModeProvider.notifier).setDark(true);
    await tester.pumpAndSettle();
    expect(style()?.statusBarIconBrightness, Brightness.light);
    expect(AppOverlayStyles.of(Brightness.dark), AppOverlayStyles.dark);
  });
}
