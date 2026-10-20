import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/app/theme/app_assets.dart';
import 'package:reborn_app/app/theme/app_colors.dart';
import 'package:reborn_app/app/theme/app_theme.dart';
import 'package:reborn_app/app/theme/bottom_nav_tokens.dart';
import 'package:reborn_app/shared/widgets/app_bottom_nav_bar.dart';

void main() {
  Future<void> pumpNav(
    WidgetTester tester, {
    int currentIndex = 0,
    ValueChanged<int>? onTap,
    TargetPlatform platform = TargetPlatform.iOS,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: AppBottomNavBar(
              currentIndex: currentIndex,
              onTap: onTap ?? (_) {},
              platform: platform,
            ),
          ),
        ),
      ),
    );
  }

  bool usesAsset(Widget widget, String asset) {
    if (widget is! SvgPicture) return false;
    final loader = widget.bytesLoader;
    return loader is SvgAssetLoader && loader.assetName == asset;
  }

  testWidgets('크기는 Figma와 같은 354×64이다', (tester) async {
    await pumpNav(tester);

    final size = tester.getSize(find.byType(AppBottomNavBar));
    expect(size.width, BottomNavTokens.width);
    expect(size.height, BottomNavTokens.height);
  });

  testWidgets('선택된 탭만 분홍 아이콘과 분홍 라벨을 쓴다', (tester) async {
    await pumpNav(tester, currentIndex: 1);

    expect(
      find.byWidgetPredicate((w) => usesAsset(w, AppAssets.tabRelationsActive)),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate((w) => usesAsset(w, AppAssets.tabRelations)),
      findsNothing,
    );
    for (final inactive in [
      AppAssets.tabHome,
      AppAssets.tabRecord,
      AppAssets.tabAll,
    ]) {
      expect(
        find.byWidgetPredicate((w) => usesAsset(w, inactive)),
        findsOneWidget,
      );
    }

    Color labelColor(String label) =>
        tester.widget<Text>(find.text(label)).style!.color!;
    expect(labelColor('관계'), AppColors.light.brand);
    expect(labelColor('투데이'), AppColors.light.textStrong);
    expect(labelColor('기록'), AppColors.light.textStrong);
    expect(labelColor('전체'), AppColors.light.textStrong);
  });

  testWidgets('탭을 누르면 그 순서(index)로 알린다', (tester) async {
    final taps = <int>[];
    await pumpNav(tester, onTap: taps.add);

    await tester.tap(find.text('기록'));
    await tester.tap(find.text('전체'));
    await tester.tap(find.text('투데이'));

    expect(taps, [2, 3, 0]);
  });

  testWidgets('선택 알약은 선택된 탭 뒤에 있고 Figma 위치와 ±2px 안에서 같다', (tester) async {
    for (var i = 0; i < 4; i++) {
      await pumpNav(tester, currentIndex: i);
      await tester.pumpAndSettle();

      final nav = tester.getTopLeft(find.byType(AppBottomNavBar));
      final pill = tester.getTopLeft(
        find.byWidgetPredicate((w) => usesAsset(w, AppAssets.tabSelection)),
      );
      expect(
        pill.dx - nav.dx,
        closeTo(BottomNavTokens.selectionLefts[i], 2),
        reason: 'tab $i',
      );
    }
  });

  testWidgets('iOS와 Android는 배경 블러 강도만 다르다', (tester) async {
    double sigmaOf(WidgetTester tester) {
      final filter = tester
          .widget<BackdropFilter>(find.byType(BackdropFilter))
          .filter;
      // ImageFilter.blur는 "ImageFilter.blur(sigmaX, sigmaY, ...)" 형태로 출력된다.
      final match = RegExp(r'blur\(([\d.]+),').firstMatch(filter.toString());
      return double.parse(match!.group(1)!);
    }

    await pumpNav(tester, platform: TargetPlatform.iOS);
    expect(sigmaOf(tester), BottomNavTokens.iosBlurSigma);

    await pumpNav(tester, platform: TargetPlatform.android);
    expect(sigmaOf(tester), BottomNavTokens.androidBlurSigma);
    expect(
      BottomNavTokens.androidBlurSigma,
      greaterThan(BottomNavTokens.iosBlurSigma),
    );
  });

  testWidgets('접근성: 각 탭이 라벨과 선택 상태를 가진 버튼이다', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpNav(tester, currentIndex: 2);

    expect(
      tester.getSemantics(find.bySemanticsLabel('기록')),
      matchesSemantics(
        label: '기록',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        hasTapAction: true,
        hasEnabledState: false,
      ),
    );
    handle.dispose();
  });
}
