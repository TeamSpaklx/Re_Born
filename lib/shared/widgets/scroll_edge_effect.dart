import 'dart:ui' show ImageFilter;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/bottom_nav_tokens.dart';

/// 화면 아래 가장자리에서 스크롤 내용이 흐려지며 배경색으로 옅어지는 효과
/// (Figma `Scroll Edge Effect - Soft`, docs/DESIGN_SYSTEM.md 5.8).
///
/// - iOS: 아래로 갈수록 블러가 세지는 점진 블러 + 배경색 그라디언트. iOS 26 시스템 효과
///   (`UIScrollEdgeEffect`)는 네이티브 스크롤 뷰에서만 쓸 수 있어 Flutter로 비슷하게 만든다.
/// - 그 외(Android): 배경색 그라디언트만.
///
/// 터치는 그대로 아래 내용으로 통과한다. 놓을 자리의 크기는 부모가 정한다.
class ScrollEdgeEffect extends StatelessWidget {
  const ScrollEdgeEffect({super.key, this.platform});

  /// 테스트에서 플랫폼을 바꿔 볼 때만 지정한다.
  final TargetPlatform? platform;

  @override
  Widget build(BuildContext context) {
    final background = context.colors.background;
    final blurred = (platform ?? defaultTargetPlatform) == TargetPlatform.iOS;
    const bands = BottomNavTokens.scrollEdgeBlurBands;

    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (blurred)
            Column(
              children: [
                for (var i = 0; i < bands; i++)
                  Expanded(
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: _bandSigma(i),
                          sigmaY: _bandSigma(i),
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
              ],
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                // 중간에서 가장 옅어지고 맨 아래(화면 끝)에서는 내용이 비쳐 보이게 한다.
                colors: [
                  background.withValues(alpha: 0),
                  background.withValues(
                    alpha: BottomNavTokens.scrollEdgeVeilPeak,
                  ),
                  background.withValues(
                    alpha: BottomNavTokens.scrollEdgeVeilEnd,
                  ),
                ],
                stops: const [0, 0.45, 1],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 위에서 i번째 띠의 블러 강도: 아래로 갈수록 [BottomNavTokens.scrollEdgeBlurSigma]까지 커진다.
  static double _bandSigma(int i) =>
      BottomNavTokens.scrollEdgeBlurSigma *
      (i + 1) /
      BottomNavTokens.scrollEdgeBlurBands;

  /// 테스트용: 띠별 블러 강도.
  @visibleForTesting
  static List<double> get bandSigmas => [
    for (var i = 0; i < BottomNavTokens.scrollEdgeBlurBands; i++) _bandSigma(i),
  ];
}
