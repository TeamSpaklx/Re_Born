import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/app/theme/app_assets.dart';
import 'package:reborn_app/app/theme/app_colors.dart';
import 'package:reborn_app/app/theme/app_spacing.dart';
import 'package:reborn_app/app/theme/app_theme.dart';
import 'package:reborn_app/shared/widgets/app_bottom_sheet.dart';
import 'package:reborn_app/shared/widgets/app_dialogs.dart';
import 'package:reborn_app/shared/widgets/notification_bell_button.dart';
import 'package:reborn_app/shared/widgets/skeleton.dart';

import '../../helpers/load_fonts.dart';

/// Figma 컴포넌트 섹션(`749:337`)으로 새로 만든 공통 위젯: 토스트 성공 표시·확인, 시트 행동 행,
/// 알림 종 버튼, 스켈레톤.
void main() {
  setUpAll(loadPretendard);

  const colors = AppColors.light;

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    bool disableAnimations = false,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(402, 874);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(
          size: const Size(402, 874),
          disableAnimations: disableAnimations,
        ),
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(body: Center(child: child)),
        ),
      ),
    );
  }

  group('토스트', () {
    testWidgets('success면 분홍 체크 원(#FBE8EF, ✓ #D94F79)이 붙는다', (tester) async {
      await pump(
        tester,
        Builder(
          builder: (context) => GestureDetector(
            onTap: () => showAppToast(context, '감정이 기록되었어요.', success: true),
            child: const Text('열기'),
          ),
        ),
      );
      await tester.tap(find.text('열기'));
      await tester.pump();
      await tester.pump(ComponentLayout.toastFade);

      expect(find.text('✓'), findsOneWidget);
      final check = tester.widget<Container>(
        find
            .ancestor(of: find.text('✓'), matching: find.byType(Container))
            .first,
      );
      expect((check.decoration! as BoxDecoration).color, colors.toastCheckFill);
      expect(
        tester.widget<Text>(find.text('✓')).style!.color,
        colors.toastAccent,
      );
      expect(
        tester.widget<Text>(find.text('확인')).style!.color,
        colors.toastAccent,
      );
      await tester.pump(ComponentLayout.toastTotal);
    });

    testWidgets('확인을 누르면 3초를 기다리지 않고 사라진다', (tester) async {
      await pump(
        tester,
        Builder(
          builder: (context) => GestureDetector(
            onTap: () => showAppToast(context, '감정이 기록되었어요.'),
            child: const Text('열기'),
          ),
        ),
      );
      await tester.tap(find.text('열기'));
      await tester.pump();
      await tester.pump(ComponentLayout.toastFade);
      await tester.tap(find.text('확인'));
      await tester.pump();
      await tester.pump(
        ComponentLayout.toastFade + const Duration(milliseconds: 50),
      );
      expect(find.text('감정이 기록되었어요.'), findsNothing);
    });

    testWidgets('확인은 문구와 따로 읽히는 버튼이다', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(
        tester,
        Builder(
          builder: (context) => GestureDetector(
            onTap: () => showAppToast(context, '저장했어요'),
            child: const Text('열기'),
          ),
        ),
      );
      await tester.tap(find.text('열기'));
      await tester.pump();
      await tester.pump(ComponentLayout.toastFade);
      expect(find.bySemanticsLabel('저장했어요'), findsOneWidget);
      expect(find.bySemanticsLabel('확인'), findsOneWidget);
      await tester.pump(ComponentLayout.toastTotal);
      handle.dispose();
    });
  });

  testWidgets('시트 행동 행: 높이 56, 아이콘 24 + 글자 16 Medium #4B5260, 누르면 닫힌다', (
    tester,
  ) async {
    var taps = 0;
    await pump(
      tester,
      Builder(
        builder: (context) => GestureDetector(
          onTap: () => showAppBottomSheet<void>(
            context,
            title: '프로필 사진',
            builder: (context) => SheetActionRow(
              iconAsset: AppAssets.ixCamera,
              label: '사진 찍기',
              onTap: () {
                taps++;
                Navigator.of(context).pop();
              },
            ),
          ),
          child: const Text('열기'),
        ),
      ),
    );
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(SheetActionRow)).height, 56);
    final label = tester.widget<Text>(find.text('사진 찍기'));
    expect(label.style!.fontSize, 16);
    expect(label.style!.color, colors.sheetRowText);
    expect(
      tester.getSize(
        find.descendant(
          of: find.byType(SheetActionRow),
          matching: find.byType(SvgPicture),
        ),
      ),
      const Size(24, 24),
    );
    expect(tester.widget<Text>(find.text('프로필 사진')).style!.fontSize, 20);

    await tester.tap(find.text('사진 찍기'));
    await tester.pumpAndSettle();
    expect(taps, 1);
    expect(find.text('프로필 사진'), findsNothing);
  });

  group('바텀시트 끌기 (토스식)', () {
    Object? result = 'unset';

    Future<void> open(WidgetTester tester, {Widget? body}) async {
      result = 'unset';
      await pump(
        tester,
        Builder(
          builder: (context) => GestureDetector(
            onTap: () async => result = await showAppBottomSheet<String>(
              context,
              title: '프로필 사진',
              builder: (context) =>
                  body ??
                  Column(
                    children: [
                      SheetActionRow(
                        iconAsset: AppAssets.ixCamera,
                        label: '사진 찍기',
                        onTap: () => Navigator.of(context).pop('camera'),
                      ),
                      SheetActionRow(
                        iconAsset: AppAssets.ixGallery,
                        label: '앨범에서 선택',
                        onTap: () => Navigator.of(context).pop('gallery'),
                      ),
                    ],
                  ),
            ),
            child: const Text('열기'),
          ),
        ),
      );
      await tester.tap(find.text('열기'));
      await tester.pumpAndSettle();
    }

    Finder card() => find
        .ancestor(of: find.text('프로필 사진'), matching: find.byType(Container))
        .first;

    double scrimAlpha(WidgetTester tester) => tester
        .widget<ColoredBox>(
          find
              .descendant(
                of: find.byType(Stack).last,
                matching: find.byType(ColoredBox),
              )
              .first,
        )
        .color
        .a;

    testWidgets('행 위에서 조금 끌면 따라 내려오고, 놓으면 제자리로 돌아온다', (tester) async {
      await open(tester);
      final rest = tester.getRect(card());
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('사진 찍기')),
      );
      await gesture.moveBy(const Offset(0, 20)); // 끌기 시작 문턱
      await gesture.moveBy(const Offset(0, 30));
      await tester.pump();
      expect(tester.getRect(card()).top, greaterThan(rest.top + 25));
      expect(scrimAlpha(tester), lessThan(AppColors.light.scrim.a));

      await gesture.up();
      await tester.pumpAndSettle();
      expect(tester.getRect(card()).top, closeTo(rest.top, 0.5));
      expect(find.text('프로필 사진'), findsOneWidget);
      expect(result, 'unset');
    });

    testWidgets('높이의 25% 넘게 끌고 놓으면 닫히고 값은 null', (tester) async {
      await open(tester);
      final height = tester.getSize(card()).height;
      await tester.timedDrag(
        find.text('앨범에서 선택'),
        Offset(0, height * 0.4),
        const Duration(seconds: 1),
      );
      await tester.pumpAndSettle();
      expect(find.text('프로필 사진'), findsNothing);
      expect(result, isNull);
    });

    testWidgets('조금만 끌어도 아래로 빠르게 튕기면 닫힌다', (tester) async {
      await open(tester);
      await tester.fling(find.text('사진 찍기'), const Offset(0, 60), 1500);
      await tester.pumpAndSettle();
      expect(find.text('프로필 사진'), findsNothing);
    });

    testWidgets('위로 끌면 최대 24만 늘어나고 놓으면 돌아온다', (tester) async {
      await open(tester);
      final rest = tester.getRect(card());
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('사진 찍기')),
      );
      await gesture.moveBy(const Offset(0, -20));
      await gesture.moveBy(const Offset(0, -200));
      await tester.pump();
      final lifted = rest.top - tester.getRect(card()).top;
      expect(lifted, greaterThan(0));
      expect(lifted, lessThanOrEqualTo(ComponentLayout.sheetOverDrag));

      await gesture.up();
      await tester.pumpAndSettle();
      expect(tester.getRect(card()).top, closeTo(rest.top, 0.5));
    });

    testWidgets('긴 내용은 맨 위에서 더 끌어내리면 시트가 내려간다', (tester) async {
      await open(
        tester,
        body: Column(
          children: [
            for (var i = 0; i < 30; i++)
              SizedBox(height: 56, child: Text('줄 $i')),
          ],
        ),
      );
      final rest = tester.getRect(card());
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('줄 1')),
      );
      await gesture.moveBy(const Offset(0, 20));
      await gesture.moveBy(const Offset(0, 60));
      await tester.pump();
      expect(tester.getRect(card()).top, greaterThan(rest.top + 50));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(tester.getRect(card()).top, closeTo(rest.top, 0.5));

      // 위로 밀면 그대로 내용이 스크롤된다.
      await tester.drag(find.text('줄 5'), const Offset(0, -200));
      await tester.pumpAndSettle();
      expect(tester.getRect(card()).top, closeTo(rest.top, 0.5));
      expect(
        tester.getRect(find.text('줄 0')).bottom,
        lessThan(rest.top),
        reason: '첫 줄이 카드 위로 스크롤되어 올라갔다',
      );
    });
  });

  group('알림 종 버튼', () {
    String assetOf(WidgetTester tester) =>
        (tester.widget<SvgPicture>(find.byType(SvgPicture)).bytesLoader
                as SvgAssetLoader)
            .assetName;

    testWidgets('44 원, 안 읽은 알림이 없으면 기본 종', (tester) async {
      await pump(tester, NotificationBellButton(onTap: () {}));
      expect(
        tester.getSize(find.byType(NotificationBellButton)),
        const Size(44, 44),
      );
      expect(assetOf(tester), AppAssets.bell);
    });

    testWidgets('안 읽은 알림이 있으면 분홍 점 종, 수를 읽어 준다', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, NotificationBellButton(onTap: () {}, unreadCount: 3));
      expect(assetOf(tester), AppAssets.bellUnread);
      expect(find.bySemanticsLabel('알림, 읽지 않은 알림 3개'), findsOneWidget);
      handle.dispose();
    });
  });

  group('스켈레톤', () {
    Color colorOf(WidgetTester tester) =>
        ((tester.widget<DecoratedBox>(
                  find
                      .descendant(
                        of: find.byType(SkeletonBox).first,
                        matching: find.byType(DecoratedBox),
                      )
                      .first,
                )).decoration
                as BoxDecoration)
            .color!;

    testWidgets('막대는 #E4E4E4에서 시작해 깜빡이고, "불러오는 중"으로 읽힌다', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(
        tester,
        const SizedBox(width: 354, child: SkeletonList(count: 2)),
      );
      expect(colorOf(tester), colors.skeleton);
      expect(find.byType(SkeletonListCard), findsNWidgets(2));
      expect(find.bySemanticsLabel('불러오는 중'), findsOneWidget);

      await tester.pump(ComponentLayout.skeletonPulse);
      expect(colorOf(tester).a, lessThan(colors.skeleton.a));
      handle.dispose();
    });

    testWidgets('동작 줄이기가 켜져 있으면 깜빡이지 않는다', (tester) async {
      await pump(
        tester,
        const SizedBox(width: 354, child: SkeletonList(count: 1)),
        disableAnimations: true,
      );
      await tester.pump(ComponentLayout.skeletonPulse);
      expect(colorOf(tester), colors.skeleton);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });
}
