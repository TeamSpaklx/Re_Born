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
import 'package:reborn_app/features/settings/presentation/settings_providers.dart';

import '../../helpers/fakes.dart';

/// 저장 횟수를 세고, 저장이 실패하게 만들 수 있는 저장소.
class _Store extends InMemoryThemeModeStore {
  _Store([super.mode, this.fail = false]);

  final bool fail;
  int saves = 0;

  @override
  Future<void> setMode(ThemeMode value) async {
    saves++;
    if (fail) throw StateError('disk full');
    return super.setMode(value);
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

  const darkBackground = Color(0xFF0F1013);

  testWidgets('저장된 값이 없으면 기기 설정을 따른다(기기가 라이트면 라이트)', (tester) async {
    final container = await pumpApp(tester, InMemoryThemeModeStore());
    expect(container.read(themeModeProvider), ThemeMode.system);
    expect(colorsOf(tester).background, AppColors.light.background);
  });

  testWidgets('기기 설정을 따르면 기기가 다크로 바뀔 때 앱도 바로 다크가 된다', (tester) async {
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await pumpApp(tester, InMemoryThemeModeStore());
    expect(colorsOf(tester).background, AppColors.light.background);

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();
    expect(colorsOf(tester).background, darkBackground);

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    await tester.pumpAndSettle();
    expect(colorsOf(tester).background, AppColors.light.background);
  });

  testWidgets('라이트로 고르면 기기가 다크여도 라이트로 남는다', (tester) async {
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await pumpApp(tester, InMemoryThemeModeStore(ThemeMode.light));
    expect(colorsOf(tester).background, AppColors.light.background);
  });

  testWidgets('다크로 저장돼 있으면 첫 화면부터 다크다', (tester) async {
    await pumpApp(tester, InMemoryThemeModeStore(ThemeMode.dark));
    expect(colorsOf(tester).background, darkBackground);
  });

  testWidgets('컨트롤러가 모드를 바꾸고 저장한다', (tester) async {
    final store = _Store();
    final container = await pumpApp(tester, store);

    await container.read(themeModeProvider.notifier).setMode(ThemeMode.dark);
    await tester.pumpAndSettle();
    expect(colorsOf(tester).background, darkBackground);
    expect(store.mode, ThemeMode.dark);

    await container.read(themeModeProvider.notifier).setMode(ThemeMode.system);
    await tester.pumpAndSettle();
    expect(colorsOf(tester).background, AppColors.light.background);
    expect(store.mode, ThemeMode.system);
    expect(store.saves, 2);
  });

  testWidgets('저장이 실패해도 이번 실행에서는 바로 다크가 된다', (tester) async {
    final container = await pumpApp(tester, _Store(ThemeMode.system, true));
    await container.read(themeModeProvider.notifier).setMode(ThemeMode.dark);
    await tester.pumpAndSettle();
    expect(container.read(themeModeProvider), ThemeMode.dark);
    expect(colorsOf(tester).background, darkBackground);
  });

  testWidgets('설정의 화면 모드에서 다크를 고르면 전체 화면에 적용된다', (tester) async {
    final store = _Store();
    // 탭 라벨 대신 마이(코드 이름 all) 탭 경로에서 바로 시작한다.
    await pumpApp(tester, store, start: AppRoutes.all);

    final row = find.byKey(const Key('theme-mode'));
    await tester.scrollUntilVisible(
      row,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.descendant(of: row, matching: find.text('기기 설정')),
      findsOneWidget,
    );

    await tester.tap(row);
    await tester.pumpAndSettle();
    expect(find.text('기기의 라이트·다크 설정에 맞춰 자동으로 바뀌어요.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('theme-mode-dark')));
    await tester.pumpAndSettle();

    expect(store.mode, ThemeMode.dark);
    expect(colorsOf(tester).background, darkBackground);
    expect(find.descendant(of: row, matching: find.text('다크')), findsOneWidget);
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

    await container.read(themeModeProvider.notifier).setMode(ThemeMode.dark);
    await tester.pumpAndSettle();
    expect(style()?.statusBarIconBrightness, Brightness.light);
    expect(AppOverlayStyles.of(Brightness.dark), AppOverlayStyles.dark);
  });
}
