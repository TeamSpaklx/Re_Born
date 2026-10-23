import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/app/app.dart';
import 'package:reborn_app/app/data_providers.dart';
import 'package:reborn_app/app/router.dart';
import 'package:reborn_app/app/theme/app_assets.dart';
import 'package:reborn_app/app/theme/app_spacing.dart';
import 'package:reborn_app/app/theme/app_theme.dart';
import 'package:reborn_app/features/entries/data/in_memory_entries_repository.dart';
import 'package:reborn_app/features/entries/models/entry.dart';
import 'package:reborn_app/features/home/presentation/today_screen.dart';
import 'package:reborn_app/features/splash/presentation/splash_screen.dart';

/// 기록 목록을 [delay] 뒤에 돌려주는 저장소 (홈 데이터가 늦게 오는 경우).
class _SlowEntries extends InMemoryEntriesRepository {
  _SlowEntries(this.delay);

  final Duration delay;

  @override
  Future<List<Entry>> list({String? personId}) async {
    await Future<void>.delayed(delay);
    return super.list(personId: personId);
  }
}

/// 기록 목록을 불러오다 실패하는 저장소.
class _FailingEntries extends InMemoryEntriesRepository {
  @override
  Future<List<Entry>> list({String? personId}) async =>
      throw StateError('network');
}

void main() {
  Future<void> pumpSplash(
    WidgetTester tester, {
    List<Override> overrides = const [],
  }) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialLocationProvider.overrideWithValue(AppRoutes.splash),
          ...overrides,
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

    await tester.pump(SplashLayout.maxDuration);
    await tester.pumpAndSettle();
  });

  testWidgets('로고는 투명도·색 보정 없이 원본 그대로 그려진다', (tester) async {
    await pumpSplash(tester);

    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      const Color(0xFFFFFFFF),
      reason: '스플래시는 흰 배경(Figma), 홈 배경 #FFF8F8과 다름',
    );

    final image = tester.widget<Image>(logo());
    expect(image.opacity, isNull);
    expect(image.color, isNull);
    expect(
      find.ancestor(of: logo(), matching: find.byType(Opacity)),
      findsNothing,
    );

    await tester.pump(SplashLayout.maxDuration);
    await tester.pumpAndSettle();
  });

  testWidgets('홈 데이터가 빨라도 최소 표시 시간이 지나야 넘어간다', (tester) async {
    await pumpSplash(tester);

    await tester.pump(
      SplashLayout.minDuration - const Duration(milliseconds: 1),
    );
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(TodayScreen), findsNothing);

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();
    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(TodayScreen), findsOneWidget);
  });

  testWidgets('홈 데이터가 늦으면 준비될 때까지 기다린다', (tester) async {
    const delay = Duration(milliseconds: 1500);
    await pumpSplash(
      tester,
      overrides: [
        entriesRepositoryProvider.overrideWith((ref) => _SlowEntries(delay)),
      ],
    );

    // 최소 표시 시간이 지나도 데이터가 오기 전에는 로고가 그대로 있다.
    await tester.pump(
      SplashLayout.minDuration + const Duration(milliseconds: 1),
    );
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(TodayScreen), findsNothing);

    await tester.pump(delay);
    await tester.pumpAndSettle();
    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(TodayScreen), findsOneWidget);
  });

  testWidgets('홈 데이터가 너무 늦으면 최대 대기 시간 뒤에 넘어간다', (tester) async {
    const delay = Duration(seconds: 10);
    await pumpSplash(
      tester,
      overrides: [
        entriesRepositoryProvider.overrideWith((ref) => _SlowEntries(delay)),
      ],
    );

    await tester.pump(
      SplashLayout.maxDuration - const Duration(milliseconds: 1),
    );
    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();
    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(TodayScreen), findsOneWidget);

    await tester.pump(delay); // 남은 타이머 정리
  });

  testWidgets('홈 데이터를 불러오지 못해도 넘어간다(홈이 오류 화면을 보여 준다)', (tester) async {
    await pumpSplash(
      tester,
      overrides: [
        entriesRepositoryProvider.overrideWith((ref) => _FailingEntries()),
      ],
    );

    await tester.pump(SplashLayout.minDuration);
    await tester.pumpAndSettle();
    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(TodayScreen), findsOneWidget);
  });

  testWidgets('홈은 옆에서 밀리지 않고 로고 화면 위로 서서히 나타난다', (tester) async {
    await pumpSplash(tester);
    await tester.pump(SplashLayout.minDuration);
    await tester.pump(); // 전환 시작 프레임
    await tester.pump(SplashLayout.fadeDuration ~/ 2);

    // 전환 도중에는 로고 화면이 그대로 남아 있고, 홈은 반투명이다.
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(TodayScreen), findsOneWidget);
    expect(tester.getTopLeft(find.byType(TodayScreen)), Offset.zero);
    final opacities = find
        .ancestor(
          of: find.byType(TodayScreen),
          matching: find.byType(FadeTransition),
        )
        .evaluate()
        .map((e) => (e.widget as FadeTransition).opacity.value);
    expect(opacities.any((v) => v > 0 && v < 1), isTrue);

    await tester.pumpAndSettle();
    expect(find.byType(SplashScreen), findsNothing);
  });

  testWidgets('시간이 되기 전에 화면이 사라져도 오류가 없다', (tester) async {
    final show = ValueNotifier(true);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: ValueListenableBuilder<bool>(
            valueListenable: show,
            builder: (context, visible, _) =>
                visible ? const SplashScreen() : const SizedBox.shrink(),
          ),
        ),
      ),
    );
    show.value = false;
    await tester.pump();
    await tester.pump(SplashLayout.maxDuration * 2);

    expect(tester.takeException(), isNull);
  });
}
