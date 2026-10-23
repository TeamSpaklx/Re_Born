import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/app/app.dart';
import 'package:reborn_app/app/router.dart';
import 'package:reborn_app/app/theme/app_assets.dart';
import 'package:reborn_app/app/theme/app_spacing.dart';
import 'package:reborn_app/app/theme/app_theme.dart';
import 'package:reborn_app/features/home/presentation/today_screen.dart';
import 'package:reborn_app/features/splash/presentation/splash_screen.dart';

void main() {
  Future<void> pumpSplash(WidgetTester tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialLocationProvider.overrideWithValue(AppRoutes.splash),
        ],
        child: const RebornApp(),
      ),
    );
    await tester.pump();
  }

  Finder logo() => find.byWidgetPredicate(
    (w) =>
        w is Image &&
        w.image is AssetImage &&
        (w.image as AssetImage).assetName == AppAssets.logoMark,
  );

  testWidgets('로고가 Figma 위치(화면 정중앙 200×200)에 그려진다', (tester) async {
    await pumpSplash(tester);

    expect(find.byType(SplashScreen), findsOneWidget);
    final rect = tester.getRect(logo());
    // Figma "스플릿 화면"(402×874): 박스 x=101, y=337 (200×200), 이미지는 박스 안에서 (−0.8, −1.7) 이동.
    expect(rect.left, closeTo(101 - 0.8, 0.5));
    expect(rect.top, closeTo(337 - 1.7, 0.5));
    expect(rect.width, closeTo(SplashLayout.logoSize, 0.01));
    expect(rect.height, closeTo(SplashLayout.logoSize, 0.01));

    await tester.pump(SplashLayout.duration);
    await tester.pumpAndSettle();
  });

  testWidgets('잠시 뒤 투데이(홈)로 넘어간다', (tester) async {
    await pumpSplash(tester);

    await tester.pump(SplashLayout.duration - const Duration(milliseconds: 1));
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(TodayScreen), findsNothing);

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();
    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(TodayScreen), findsOneWidget);
  });

  testWidgets('시간이 되기 전에 화면이 사라져도 오류가 없다', (tester) async {
    final show = ValueNotifier(true);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: ValueListenableBuilder<bool>(
          valueListenable: show,
          builder: (context, visible, _) =>
              visible ? const SplashScreen() : const SizedBox.shrink(),
        ),
      ),
    );
    show.value = false;
    await tester.pump();
    await tester.pump(SplashLayout.duration * 2);

    expect(tester.takeException(), isNull);
  });
}
