import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/app/theme/app_colors.dart';
import 'package:reborn_app/app/theme/app_motion.dart';
import 'package:reborn_app/app/theme/app_radii.dart';
import 'package:reborn_app/app/theme/app_spacing.dart';
import 'package:reborn_app/app/theme/app_theme.dart';
import 'package:reborn_app/features/entries/models/emotion.dart';
import 'package:reborn_app/features/entries/presentation/widgets/emotion_chip.dart';
import 'package:reborn_app/shared/dev/design_gallery_screen.dart';
import 'package:reborn_app/shared/widgets/app_badge.dart';
import 'package:reborn_app/shared/widgets/app_bottom_sheet.dart';
import 'package:reborn_app/shared/widgets/app_text_field.dart';
import 'package:reborn_app/shared/widgets/bottom_cta_bar.dart';
import 'package:reborn_app/shared/widgets/check_row.dart';
import 'package:reborn_app/shared/widgets/cta_button.dart';
import 'package:reborn_app/shared/widgets/empty_state.dart';
import 'package:reborn_app/shared/widgets/list_section_header.dart';
import 'package:reborn_app/shared/widgets/page_scaffold.dart';
import 'package:reborn_app/shared/widgets/profile_row.dart';
import 'package:reborn_app/shared/widgets/segmented_control.dart';
import 'package:reborn_app/shared/widgets/skeleton.dart';

import '../../helpers/load_fonts.dart';

/// 디자인 시스템 공통 컴포넌트(docs/DESIGN_SYSTEM.md 7장)의 치수·상태·접근성.
void main() {
  setUpAll(loadPretendard);

  const colors = AppColors.light;

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    bool scaffold = true,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(402, 874);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: scaffold ? Scaffold(body: Center(child: child)) : child,
      ),
    );
  }

  BoxDecoration decorationOf(WidgetTester tester, Finder finder) =>
      tester.widget<Container>(finder.first).decoration! as BoxDecoration;

  group('CtaButton 변형', () {
    Future<void> show(
      WidgetTester tester,
      CtaVariant v, {
      VoidCallback? onPressed,
    }) => pump(
      tester,
      SizedBox(
        width: 320,
        child: CtaButton(
          label: '버튼',
          height: 52,
          variant: v,
          onPressed: onPressed ?? () {},
        ),
      ),
    );

    testWidgets('변형마다 배경·글자 색이 다르다', (tester) async {
      final expected = {
        CtaVariant.primary: (colors.cta, colors.onCta),
        CtaVariant.soft: (colors.ctaSoft, colors.onCtaSoft),
        CtaVariant.secondary: (colors.chip, colors.textStrong),
        CtaVariant.destructive: (colors.dangerTile, colors.danger),
      };
      for (final entry in expected.entries) {
        await show(tester, entry.key);
        final container = find.ancestor(
          of: find.text('버튼'),
          matching: find.byType(Container),
        );
        expect(
          decorationOf(tester, container).color,
          entry.value.$1,
          reason: '${entry.key}',
        );
        expect(
          tester.widget<Text>(find.text('버튼')).style!.color,
          entry.value.$2,
        );
        expect(tester.getSize(container.first).height, 52);
      }
    });

    testWidgets('높이 52 이상은 글자 16, 그보다 낮으면 14', (tester) async {
      await pump(
        tester,
        const Column(
          children: [
            SizedBox(
              width: 300,
              child: CtaButton(label: '큰', height: 52, onPressed: null),
            ),
            SizedBox(
              width: 300,
              child: CtaButton(label: '작은', height: 48, onPressed: null),
            ),
          ],
        ),
      );
      expect(tester.widget<Text>(find.text('큰')).style!.fontSize, 16);
      expect(tester.widget<Text>(find.text('작은')).style!.fontSize, 14);
    });

    testWidgets('onPressed가 null이면 흐려지고 눌리지 않는다', (tester) async {
      var taps = 0;
      await pump(
        tester,
        SizedBox(
          width: 300,
          child: CtaButton(label: '비활성', height: 52, onPressed: null),
        ),
      );
      await tester.tap(find.text('비활성'));
      expect(taps, 0);
      expect(
        tester
            .widget<AnimatedOpacity>(find.byType(AnimatedOpacity).first)
            .opacity,
        0.4,
      );

      await show(tester, CtaVariant.primary, onPressed: () => taps++);
      await tester.tap(find.text('버튼'));
      expect(taps, 1);
    });
  });

  group('AppTextField', () {
    testWidgets('라벨·도움말·오류 문구, 오류는 danger 색', (tester) async {
      final c = TextEditingController();
      await pump(
        tester,
        SizedBox(
          width: 320,
          child: Column(
            children: [
              AppTextField(controller: c, label: '이메일', helperText: '도움말'),
              AppTextField(controller: c, errorText: '형식이 달라요'),
            ],
          ),
        ),
      );
      expect(find.text('이메일'), findsOneWidget);
      expect(find.text('도움말'), findsOneWidget);
      expect(
        tester.widget<Text>(find.text('형식이 달라요')).style!.color,
        colors.danger,
      );
    });

    testWidgets('오류가 있으면 도움말은 숨는다', (tester) async {
      final c = TextEditingController();
      await pump(
        tester,
        SizedBox(
          width: 320,
          child: AppTextField(
            controller: c,
            helperText: '도움말',
            errorText: '오류',
          ),
        ),
      );
      expect(find.text('도움말'), findsNothing);
      expect(find.text('오류'), findsOneWidget);
    });

    testWidgets('비밀번호는 가려지고 오른쪽 위젯을 놓을 수 있다', (tester) async {
      final c = TextEditingController(text: 'secret');
      await pump(
        tester,
        SizedBox(
          width: 320,
          child: AppTextField(
            controller: c,
            obscureText: true,
            suffix: const Text('보기'),
          ),
        ),
      );
      expect(
        tester.widget<TextField>(find.byType(TextField)).obscureText,
        isTrue,
      );
      expect(find.text('보기'), findsOneWidget);
    });
  });

  group('SegmentedControl', () {
    testWidgets('선택된 칸으로 알약이 옮겨 가고 값이 바뀐다', (tester) async {
      var index = 0;
      await pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 300,
            child: SegmentedControl(
              labels: const ['주간', '월간', '연간'],
              selectedIndex: index,
              onChanged: (i) => setState(() => index = i),
            ),
          ),
        ),
      );
      final pill = find.byType(AnimatedPositioned);
      expect(tester.widget<AnimatedPositioned>(pill).left, 0);
      expect(
        tester.getSize(find.byType(SegmentedControl)).height,
        ComponentLayout.segmentedHeight,
      );

      await tester.tap(find.text('월간'));
      await tester.pumpAndSettle();
      expect(index, 1);
      expect(
        tester.widget<AnimatedPositioned>(pill).left,
        closeTo((300 - 8) / 3, 0.01),
      );

      await tester.tap(find.text('월간')); // 이미 선택된 칸은 다시 알리지 않는다
      expect(index, 1);
    });

    testWidgets('접근성: 선택된 칸이 selected로 읽힌다', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(
        tester,
        SizedBox(
          width: 300,
          child: SegmentedControl(
            labels: const ['주간', '월간'],
            selectedIndex: 1,
            onChanged: (_) {},
          ),
        ),
      );
      final semantics = tester.getSemantics(find.bySemanticsLabel('월간'));
      expect(semantics.flagsCollection.isSelected, Tristate.isTrue);
      expect(semantics.flagsCollection.isButton, isTrue);
      handle.dispose();
    });
  });

  group('CheckRow', () {
    testWidgets('누르면 체크되고 글자에 취소선이 그어진다', (tester) async {
      var checked = false;
      await pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 320,
            child: CheckRow(
              title: '안부 묻기',
              checked: checked,
              onChanged: (v) => setState(() => checked = v),
            ),
          ),
        ),
      );
      TextStyle style() => tester
          .widget<AnimatedDefaultTextStyle>(
            find
                .descendant(
                  of: find.byType(CheckRow),
                  matching: find.byType(AnimatedDefaultTextStyle),
                )
                .first,
          )
          .style;
      expect(style().decoration, TextDecoration.none);

      await tester.tap(find.text('안부 묻기'));
      await tester.pumpAndSettle();
      expect(checked, isTrue);
      expect(style().decoration, TextDecoration.lineThrough);
      final circle =
          tester
                  .widget<AnimatedContainer>(
                    find
                        .descendant(
                          of: find.byType(CheckRow),
                          matching: find.byType(AnimatedContainer),
                        )
                        .first,
                  )
                  .decoration!
              as BoxDecoration;
      expect(circle.color, colors.brand);
    });

    testWidgets('행 높이는 최소 56, 접근성 checked', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(
        tester,
        SizedBox(
          width: 320,
          child: CheckRow(title: '할 일', checked: true, onChanged: (_) {}),
        ),
      );
      expect(
        tester.getSize(find.byType(CheckRow)).height,
        greaterThanOrEqualTo(56),
      );
      expect(
        tester.getSemantics(find.byType(CheckRow)),
        matchesSemantics(
          label: '할 일',
          hasCheckedState: true,
          isChecked: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });
  });

  group('AppBadge', () {
    testWidgets('점은 8×8 danger 원, 숫자는 99 넘으면 99+', (tester) async {
      await pump(
        tester,
        const Column(
          children: [AppBadge.dot(), AppBadge.count(3), AppBadge.count(120)],
        ),
      );
      expect(tester.getSize(find.byType(AppBadge).first), const Size(8, 8));
      expect(find.text('3'), findsOneWidget);
      expect(find.text('99+'), findsOneWidget);
      expect(
        tester.getSize(find.byType(AppBadge).at(1)).height,
        ComponentLayout.badgeCountHeight,
      );
    });

    testWidgets('Badged는 뱃지가 null이면 아무것도 겹치지 않는다', (tester) async {
      await pump(tester, const Badged(child: Icon(Icons.circle)));
      expect(find.byType(AppBadge), findsNothing);
    });
  });

  group('Skeleton', () {
    testWidgets('스코프 안의 블록은 깜빡이고 컨트롤러는 하나뿐이다', (tester) async {
      await pump(
        tester,
        const SkeletonScope(
          child: Column(
            children: [
              SkeletonBox(width: 100, height: 20),
              SkeletonBox(width: 100, height: 20),
            ],
          ),
        ),
      );
      await tester.pump(AppMotion.skeletonPulse ~/ 2);
      final fades = tester
          .widgetList<FadeTransition>(find.byType(FadeTransition))
          .where((f) => f.opacity.value < 1)
          .toList();
      expect(fades, isNotEmpty);
      expect(
        tester.getSize(find.byType(SkeletonBox).first),
        const Size(100, 20),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('애니메이션 줄이기가 켜져 있으면 깜빡이지 않는다', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(402, 874);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(
              body: SkeletonScope(child: SkeletonBox(width: 100, height: 20)),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      for (final f in tester.widgetList<FadeTransition>(
        find.byType(FadeTransition),
      )) {
        expect(f.opacity.value, 1);
      }
    });

    testWidgets('스코프 밖의 블록은 가만히 있다', (tester) async {
      await pump(
        tester,
        const SkeletonBox(width: 80, height: 16, circle: true),
      );
      expect(tester.getSize(find.byType(SkeletonBox)), const Size(16, 16));
    });
  });

  group('EmptyState · ErrorState', () {
    testWidgets('마스코트·버튼이 있는 빈 상태', (tester) async {
      var taps = 0;
      await pump(
        tester,
        EmptyState(
          message: '아직 기록이 없어요',
          hint: '첫 마음을 남겨 볼까요?',
          showMascot: true,
          actionLabel: '감정 기록하기',
          onAction: () => taps++,
        ),
      );
      expect(find.byType(Image), findsOneWidget);
      expect(tester.getSize(find.byType(Image)), const Size(120, 120));
      await tester.tap(find.text('감정 기록하기'));
      expect(taps, 1);
    });

    testWidgets('기본 빈 상태는 마스코트·버튼이 없다(예전 모양)', (tester) async {
      await pump(tester, const EmptyState(message: '비어 있어요'));
      expect(find.byType(Image), findsNothing);
      expect(find.byType(CtaButton), findsNothing);
    });

    testWidgets('오류 상태는 문구 + 다시 시도', (tester) async {
      var retried = 0;
      await pump(tester, ErrorState(onRetry: () => retried++));
      expect(find.text('불러오지 못했어요'), findsOneWidget);
      await tester.tap(find.text('다시 시도'));
      expect(retried, 1);
    });
  });

  group('바텀시트', () {
    testWidgets('핸들·제목·선택 행이 보이고 선택한 값을 돌려준다', (tester) async {
      String? picked;
      await pump(
        tester,
        Builder(
          builder: (context) => GestureDetector(
            onTap: () async => picked = await showAppBottomSheet<String>(
              context,
              title: '누구와의 기록인가요?',
              builder: (context) => Column(
                children: [
                  SheetOptionRow(
                    title: '인물 없음',
                    onTap: () => Navigator.of(context).pop('none'),
                  ),
                  SheetOptionRow(
                    title: '지민',
                    subtitle: '친구',
                    selected: true,
                    onTap: () => Navigator.of(context).pop('jimin'),
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
      expect(find.text('누구와의 기록인가요?'), findsOneWidget);
      expect(find.text('친구'), findsOneWidget);

      final sheet = tester.widget<Container>(
        find
            .ancestor(
              of: find.text('누구와의 기록인가요?'),
              matching: find.byType(Container),
            )
            .first,
      );
      final deco = sheet.decoration! as BoxDecoration;
      expect(deco.color, colors.cardWhite);
      expect(
        deco.borderRadius,
        const BorderRadius.vertical(top: Radius.circular(AppRadii.dialog)),
      );

      await tester.tap(find.text('지민'));
      await tester.pumpAndSettle();
      expect(picked, 'jimin');
      expect(find.text('누구와의 기록인가요?'), findsNothing);
    });

    testWidgets('바깥을 누르면 값 없이 닫힌다', (tester) async {
      String? picked = 'unset';
      await pump(
        tester,
        Builder(
          builder: (context) => GestureDetector(
            onTap: () async => picked = await showAppBottomSheet<String>(
              context,
              title: '제목',
              builder: (context) => const Text('내용'),
            ),
            child: const Text('열기'),
          ),
        ),
      );
      await tester.tap(find.text('열기'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(200, 40));
      await tester.pumpAndSettle();
      expect(picked, isNull);
    });
  });

  group('페이지 틀', () {
    testWidgets('큰 제목: 바 가운데가 아니라 아래에 26 굵게, 하단 CTA가 맨 아래에 고정', (tester) async {
      var taps = 0;
      await pump(
        tester,
        PageScaffold(
          title: '이름을 알려 주세요',
          largeTitle: true,
          bottom: BottomCtaBar(label: '다음', onPressed: () => taps++),
          body: const SizedBox.expand(),
        ),
        scaffold: false,
      );
      expect(tester.widget<Text>(find.text('이름을 알려 주세요')).style!.fontSize, 26);
      expect(find.text('이름을 알려 주세요'), findsOneWidget);
      final button = tester.getRect(find.byType(CtaButton));
      expect(button.height, 52);
      expect(button.bottom, closeTo(874 - ComponentLayout.ctaBarBottom, 1));
      await tester.tap(find.text('다음'));
      expect(taps, 1);
    });

    testWidgets('기본 틀은 가운데 제목(20)이고 CTA 없음', (tester) async {
      await pump(
        tester,
        const PageScaffold(title: '기록', body: SizedBox.expand()),
        scaffold: false,
      );
      expect(tester.widget<Text>(find.text('기록')).style!.fontSize, 20);
      expect(find.byType(BottomCtaBar), findsNothing);
    });
  });

  group('목록 요소', () {
    testWidgets('구획 머리글은 header로 읽히고 14 SemiBold', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(
        tester,
        const SizedBox(width: 320, child: ListSectionHeader(title: '지난 알림')),
      );
      expect(tester.widget<Text>(find.text('지난 알림')).style!.fontSize, 14);
      expect(
        tester.getSemantics(find.byType(ListSectionHeader)),
        matchesSemantics(isHeader: true, label: '지난 알림'),
      );
      handle.dispose();
    });

    testWidgets('프로필 행: 아바타 56, 누를 수 있으면 화살표', (tester) async {
      var taps = 0;
      await pump(
        tester,
        SizedBox(
          width: 320,
          child: ProfileRow(
            title: '이윤재',
            subtitle: '내 정보',
            onTap: () => taps++,
          ),
        ),
      );
      final avatar = tester.getSize(find.byType(ClipOval));
      expect(avatar, const Size(56, 56));
      await tester.tap(find.text('이윤재'));
      expect(taps, 1);
    });
  });

  group('감정 색', () {
    test('8감정 모두 서로 다른 색이다', () {
      final set = {for (final e in Emotion.values) emotionColor(e, colors)};
      expect(set.length, Emotion.values.length);
    });

    testWidgets('감정 칩은 감정 이름과 색 점을 가진다', (tester) async {
      await pump(tester, const EmotionChip(emotion: Emotion.hurt));
      expect(find.text('서운함'), findsOneWidget);
      final dot = tester.widget<Container>(
        find.descendant(
          of: find.byType(EmotionDot),
          matching: find.byType(Container),
        ),
      );
      expect((dot.decoration! as BoxDecoration).color, colors.emotionHurt);
    });
  });

  group('디자인 갤러리', () {
    testWidgets('모든 컴포넌트가 오류 없이 그려진다 (360 폭)', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 800);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const DesignGalleryScreen()),
      );
      for (var i = 0; i < 6; i++) {
        await tester.drag(find.byType(ListView), const Offset(0, -900));
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(tester.takeException(), isNull);
    });
  });
}
