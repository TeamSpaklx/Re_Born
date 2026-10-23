import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/app/theme/app_colors.dart';
import 'package:reborn_app/app/theme/app_radii.dart';
import 'package:reborn_app/app/theme/app_spacing.dart';
import 'package:reborn_app/app/theme/app_theme.dart';
import 'package:reborn_app/shared/widgets/app_dialogs.dart';
import 'package:reborn_app/shared/widgets/app_toggle.dart';
import 'package:reborn_app/shared/widgets/settings_group.dart';

import '../../helpers/load_fonts.dart';

/// Reborn 공통 컴포넌트(토글·모달·토스트·설정 목록). 머티리얼 Switch/SnackBar/Dialog를 쓰지 않는다.
void main() {
  setUpAll(loadPretendard);

  const colors = AppColors.light;

  Future<void> pump(WidgetTester tester, Widget child) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(402, 874);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: Center(child: child)),
      ),
    );
  }

  group('AppToggle', () {
    testWidgets('51×31 알약, 켜짐은 브랜드 핑크·꺼짐은 연한 회색 핑크, 누르는 영역은 44 이상', (
      tester,
    ) async {
      var value = false;
      await pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => AppToggle(
            value: value,
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      );

      BoxDecoration track() =>
          tester
                  .widget<AnimatedContainer>(find.byType(AnimatedContainer))
                  .decoration!
              as BoxDecoration;

      expect(track().color, colors.toggleOff);
      expect(
        tester.getSize(find.byType(AnimatedContainer)),
        const Size(51, 31),
      );
      expect(tester.getSize(find.byType(AppToggle)).height, 44);

      await tester.tap(find.byType(AppToggle));
      await tester.pumpAndSettle();
      expect(value, isTrue);
      expect(track().color, colors.brand);
    });

    testWidgets('동그라미는 꺼짐이면 왼쪽, 켜짐이면 오른쪽에 있다', (tester) async {
      var value = false;
      await pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => AppToggle(
            value: value,
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      );
      final track = tester.getRect(find.byType(AnimatedContainer));
      // AnimatedContainer 안의 Container 중 두 번째가 동그라미(첫째는 트랙 자신).
      final thumb = find
          .descendant(
            of: find.byType(AnimatedContainer),
            matching: find.byType(Container),
          )
          .last;
      expect(tester.getRect(thumb).left - track.left, closeTo(2, 0.01));

      await tester.tap(find.byType(AppToggle));
      await tester.pumpAndSettle();
      expect(track.right - tester.getRect(thumb).right, closeTo(2, 0.01));
    });

    testWidgets('접근성: toggled 상태를 알린다', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, AppToggle(value: true, onChanged: (_) {}));
      expect(
        tester.getSemantics(find.byType(AppToggle)),
        matchesSemantics(
          hasToggledState: true,
          isToggled: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('onChanged가 없으면 눌러도 바뀌지 않는다', (tester) async {
      await pump(tester, const AppToggle(value: false, onChanged: null));
      await tester.tap(find.byType(AppToggle));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('모달', () {
    Future<void> open(
      WidgetTester tester, {
      required ValueChanged<bool> onResult,
      bool destructive = false,
      String? cancelLabel = '취소',
    }) async {
      await pump(
        tester,
        Builder(
          builder: (context) => GestureDetector(
            onTap: () async => onResult(
              await showAppConfirmDialog(
                context,
                title: '로그아웃',
                message: '정말 로그아웃하시겠어요?',
                confirmLabel: '네',
                cancelLabel: cancelLabel,
                destructive: destructive,
              ),
            ),
            child: const Text('열기'),
          ),
        ),
      );
      await tester.tap(find.text('열기'));
      await tester.pumpAndSettle();
    }

    testWidgets('둥근 창 + 두 버튼: 취소는 연한 회색, 확인은 브랜드 핑크', (tester) async {
      bool? result;
      await open(tester, onResult: (v) => result = v);

      expect(find.text('로그아웃'), findsOneWidget);
      expect(find.text('정말 로그아웃하시겠어요?'), findsOneWidget);
      final window = tester.widget<Container>(
        find
            .ancestor(of: find.text('로그아웃'), matching: find.byType(Container))
            .first,
      );
      final deco = window.decoration! as BoxDecoration;
      expect(deco.color, colors.cardWhite);
      expect(deco.borderRadius, AppRadii.dialogBorderRadius);

      Color fillOf(String label) =>
          (tester
                      .widget<Container>(
                        find
                            .ancestor(
                              of: find.text(label),
                              matching: find.byType(Container),
                            )
                            .first,
                      )
                      .decoration!
                  as BoxDecoration)
              .color!;
      expect(fillOf('취소'), colors.chip);
      expect(fillOf('네'), colors.brand);
      // 두 버튼은 같은 높이(52), 나란히 놓인다.
      final cancel = tester.getRect(find.text('취소'));
      final ok = tester.getRect(find.text('네'));
      expect(cancel.top, closeTo(ok.top, 0.5));
      expect(cancel.left, lessThan(ok.left));

      await tester.tap(find.text('네'));
      await tester.pumpAndSettle();
      expect(result, isTrue);
    });

    testWidgets('취소를 누르거나 바깥을 누르면 false', (tester) async {
      bool? result;
      await open(tester, onResult: (v) => result = v);
      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();
      expect(result, isFalse);

      result = null;
      await tester.tap(find.text('열기'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(result, isFalse);
      expect(find.text('로그아웃'), findsNothing);
    });

    testWidgets('destructive면 확인 버튼이 연한 빨강 배경 + 빨간 글자', (tester) async {
      await open(tester, onResult: (_) {}, destructive: true);
      final ok = tester.widget<Container>(
        find
            .ancestor(of: find.text('네'), matching: find.byType(Container))
            .first,
      );
      expect((ok.decoration! as BoxDecoration).color, colors.dangerTile);
      expect(tester.widget<Text>(find.text('네')).style!.color, colors.danger);
    });

    testWidgets('취소 문구가 null이면 확인 버튼만 있다', (tester) async {
      await open(tester, onResult: (_) {}, cancelLabel: null);
      expect(find.text('취소'), findsNothing);
      expect(find.text('네'), findsOneWidget);
    });

    testWidgets('버튼이 3개면 세로로 쌓이고 누른 값을 돌려준다', (tester) async {
      String? picked;
      await pump(
        tester,
        Builder(
          builder: (context) => GestureDetector(
            onTap: () async => picked = await showAppDialog<String>(
              context,
              title: '인물을 삭제할까요?',
              message: '기록은 어떻게 할까요?',
              actions: const [
                AppDialogAction(
                  label: '기록은 남기기',
                  value: 'keep',
                  kind: AppDialogButtonKind.primary,
                ),
                AppDialogAction(
                  label: '기록도 함께 삭제',
                  value: 'delete',
                  kind: AppDialogButtonKind.destructive,
                ),
                AppDialogAction(label: '취소', value: null),
              ],
            ),
            child: const Text('열기'),
          ),
        ),
      );
      await tester.tap(find.text('열기'));
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.text('기록도 함께 삭제')).dy,
        greaterThan(tester.getTopLeft(find.text('기록은 남기기')).dy),
      );
      await tester.tap(find.text('기록도 함께 삭제'));
      await tester.pumpAndSettle();
      expect(picked, 'delete');
    });
  });

  group('토스트', () {
    testWidgets('어두운 둥근 상자로 나타나고 약 3초 뒤 사라지며, 터치는 아래로 통과한다', (tester) async {
      var taps = 0;
      await pump(
        tester,
        Builder(
          builder: (context) => GestureDetector(
            onTap: () {
              taps++;
              showAppToast(context, '체크리스트에 담았어요');
            },
            child: const SizedBox(width: 200, height: 200, child: Text('버튼')),
          ),
        ),
      );
      await tester.tap(find.text('버튼'));
      await tester.pump();
      await tester.pump(ComponentLayout.toastFade);

      expect(find.text('체크리스트에 담았어요'), findsOneWidget);
      final box = tester.widget<Container>(
        find
            .ancestor(
              of: find.text('체크리스트에 담았어요'),
              matching: find.byType(Container),
            )
            .first,
      );
      final deco = box.decoration! as BoxDecoration;
      expect(deco.color, colors.toastFill);
      expect(deco.borderRadius, AppRadii.toastBorderRadius);
      // 탭 바(아래 34 + 64) 위 16 → 화면 아래에서 114 이상 떨어진 곳
      expect(
        874 - tester.getRect(find.text('체크리스트에 담았어요')).bottom,
        greaterThan(114),
      );

      await tester.pump(const Duration(seconds: 1));
      expect(find.text('체크리스트에 담았어요'), findsOneWidget, reason: '머무는 중');

      await tester.pump(ComponentLayout.toastTotal);
      expect(find.text('체크리스트에 담았어요'), findsNothing);
      expect(taps, 1);
    });

    testWidgets('새 토스트가 오면 이전 토스트를 바꾼다', (tester) async {
      late BuildContext ctx;
      await pump(
        tester,
        Builder(
          builder: (context) {
            ctx = context;
            return const SizedBox();
          },
        ),
      );
      showAppToast(ctx, '첫째');
      await tester.pump();
      showAppToast(ctx, '둘째');
      await tester.pump(ComponentLayout.toastFade);

      expect(find.text('첫째'), findsNothing);
      expect(find.text('둘째'), findsOneWidget);
      await tester.pump(ComponentLayout.toastTotal);
    });

    testWidgets('화면이 먼저 사라져도 오류가 없다', (tester) async {
      late BuildContext ctx;
      await pump(
        tester,
        Builder(
          builder: (context) {
            ctx = context;
            return const SizedBox();
          },
        ),
      );
      showAppToast(ctx, '곧 사라져요');
      await tester.pump();
      await tester.pumpWidget(const SizedBox());
      await tester.pump(ComponentLayout.toastTotal);
      expect(tester.takeException(), isNull);
    });
  });

  group('설정 목록', () {
    testWidgets('묶음은 흰 카드, 행은 높이 56, 토글 행은 토글을 눌러 바꾼다', (tester) async {
      var on = true;
      var tapped = 0;
      await pump(
        tester,
        SizedBox(
          width: 354,
          child: StatefulBuilder(
            builder: (context, setState) => SettingsGroup(
              title: '알림',
              children: [
                SettingsRow.toggle(
                  title: '푸시 알림',
                  value: on,
                  onChanged: (v) => setState(() => on = v),
                ),
                SettingsRow.link(
                  title: '언어',
                  trailingText: '한국어',
                  onTap: () => tapped++,
                ),
                SettingsRow.destructive(
                  title: '로그아웃',
                  onTap: () => tapped += 10,
                ),
              ],
            ),
          ),
        ),
      );

      expect(
        tester
            .getSize(
              find
                  .ancestor(
                    of: find.text('푸시 알림'),
                    matching: find.byType(SizedBox),
                  )
                  .first,
            )
            .height,
        ComponentLayout.settingsRowHeight,
      );
      expect(find.text('알림'), findsOneWidget);
      expect(find.text('한국어'), findsOneWidget);

      await tester.tap(find.byType(AppToggle));
      await tester.pumpAndSettle();
      expect(on, isFalse);

      await tester.tap(find.text('언어'));
      await tester.tap(find.text('로그아웃'));
      expect(tapped, 11);
      expect(
        tester.widget<Text>(find.text('로그아웃')).style!.color,
        colors.danger,
      );
    });
  });
}
