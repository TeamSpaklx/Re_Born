import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/app/theme/app_theme.dart';
import 'package:reborn_app/app/theme/bottom_nav_tokens.dart';
import 'package:reborn_app/shared/widgets/scroll_edge_effect.dart';

void main() {
  Future<void> pumpEffect(WidgetTester tester, {VoidCallback? onTapBelow}) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTapBelow,
                child: const SizedBox.expand(),
              ),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: BottomNavTokens.scrollEdgeFadeHeight,
                child: ScrollEdgeEffect(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('iOS: 띠마다 BackdropFilter가 있고 블러가 아래로 갈수록 커져 최대 10이 된다', (
    tester,
  ) async {
    await pumpEffect(tester);

    final filters = tester
        .widgetList<BackdropFilter>(find.byType(BackdropFilter))
        .toList();
    expect(filters, hasLength(BottomNavTokens.scrollEdgeBlurBands));

    final sigmas = ScrollEdgeEffect.bandSigmas;
    expect(sigmas.first, greaterThan(0));
    expect(sigmas.last, BottomNavTokens.scrollEdgeBlurSigma);
    expect([...sigmas]..sort(), sigmas, reason: '단조 증가');
    // 위젯에 넘어간 필터가 띠 순서대로 같은 강도인지 확인한다.
    for (var i = 0; i < filters.length; i++) {
      expect(
        filters[i].filter,
        ImageFilter.blur(sigmaX: sigmas[i], sigmaY: sigmas[i]),
      );
    }
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('Android: 블러 없이 그라디언트만 그린다', (tester) async {
    await pumpEffect(tester);

    expect(find.byType(BackdropFilter), findsNothing);
    expect(find.byType(DecoratedBox), findsWidgets);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('터치는 효과 영역을 통과해 아래 내용에 닿는다', (tester) async {
    var taps = 0;
    await pumpEffect(tester, onTapBelow: () => taps++);

    final size = tester.view.physicalSize / tester.view.devicePixelRatio;
    await tester.tapAt(Offset(size.width / 2, size.height - 40));

    expect(taps, 1);
  }, variant: TargetPlatformVariant.mobile());
}
