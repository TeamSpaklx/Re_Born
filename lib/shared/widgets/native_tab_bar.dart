import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show PlatformViewHitTestBehavior;
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/app_assets.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/theme/bottom_nav_tokens.dart';
import 'nav_tabs.dart';

/// 네이티브 탭 바에 넘기는 아이콘 PNG (기본 4개 + 선택 4개).
class NativeTabIcons {
  const NativeTabIcons({required this.icons, required this.selectedIcons});

  final List<Uint8List> icons;
  final List<Uint8List> selectedIcons;
}

/// [tint]는 선택되지 않은 탭 아이콘에 입힐 색이다(선택된 아이콘은 분홍 그대로).
typedef NativeTabIconLoader =
    Future<NativeTabIcons> Function(double pixelRatio, Color tint);

/// Figma SVG 아이콘을 [BottomNavTokens.iconSize] 크기의 PNG로 그린다(기기 배율 적용).
/// 네이티브 탭 바(UIKit)는 SVG를 읽지 못해서 Flutter가 대신 그려 넘긴다.
Future<NativeTabIcons> renderNativeTabIcons(
  double pixelRatio,
  Color tint,
) async {
  Future<Uint8List> render(String asset, {Color? color}) async {
    final info = await vg.loadPicture(SvgAssetLoader(asset), null);
    try {
      final side = (BottomNavTokens.iconSize * pixelRatio).round();
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      // 한 색 아이콘이라, 모양(알파)만 쓰고 색은 [color]로 바꿔 칠한다.
      if (color != null) {
        canvas.saveLayer(
          Rect.fromLTWH(0, 0, side.toDouble(), side.toDouble()),
          Paint()..colorFilter = ColorFilter.mode(color, BlendMode.srcIn),
        );
      }
      canvas
        ..scale(side / info.size.width, side / info.size.height)
        ..drawPicture(info.picture);
      if (color != null) canvas.restore();
      final image = await recorder.endRecording().toImage(side, side);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      return data!.buffer.asUint8List();
    } finally {
      info.picture.dispose();
    }
  }

  return NativeTabIcons(
    icons: [for (final tab in NavTab.all) await render(tab.icon, color: tint)],
    selectedIcons: [for (final tab in NavTab.all) await render(tab.activeIcon)],
  );
}

/// iOS 26 이상의 네이티브 탭 바(`UITabBar`, Liquid Glass). 구현은 ios/Runner/NativeTabBarView.swift.
///
/// 유리 재질·선택 알약·접근성은 시스템이 처리하고, 아이콘·라벨·색·글꼴은 이 앱의 테마
/// 상수에서 읽어 네이티브에 넘긴다. 탭을 누르면 [onTap]으로 index가 오고,
/// [currentIndex]가 바뀌면(예: 화면 안 버튼으로 탭 이동) 네이티브 선택 표시를 맞춘다.
class NativeTabBar extends StatefulWidget {
  const NativeTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.width = BottomNavTokens.width,
    this.iconLoader = renderNativeTabIcons,
  });

  static const viewType = 'reborn/native_tab_bar';

  final int currentIndex;
  final ValueChanged<int> onTap;
  final double width;

  /// 테스트에서 아이콘 렌더링을 바꿀 때만 지정한다.
  final NativeTabIconLoader iconLoader;

  @override
  State<NativeTabBar> createState() => _NativeTabBarState();
}

class _NativeTabBarState extends State<NativeTabBar> {
  Future<NativeTabIcons>? _icons;
  double? _pixelRatio;
  Color? _tint;
  bool _dark = false;
  MethodChannel? _channel;

  /// 네이티브 뷰를 만들 때 넘긴 선택 index (그 뒤로 바뀌었으면 만들어진 뒤에 맞춰 준다).
  int? _initialIndex;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ratio = MediaQuery.devicePixelRatioOf(context);
    final tint = context.colors.textStrong;
    if (ratio != _pixelRatio || tint != _tint) {
      _pixelRatio = ratio;
      _tint = tint;
      _dark = Theme.of(context).brightness == Brightness.dark;
      _icons = widget.iconLoader(ratio, tint);
      // 화면 모드가 바뀌면 네이티브 뷰를 새로 만든다(아이콘·색·재질을 만들 때 한 번만 넘기므로).
      _initialIndex = null;
    }
  }

  @override
  void didUpdateWidget(NativeTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _channel?.invokeMethod<void>('setSelectedIndex', widget.currentIndex);
    }
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('reborn/native_tab_bar_$id')
      ..setMethodCallHandler((call) async {
        if (call.method == 'onTap') widget.onTap(call.arguments as int);
        return null;
      });
    if (widget.currentIndex != _initialIndex) {
      _channel!.invokeMethod<void>('setSelectedIndex', widget.currentIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tint = colors.textStrong;
    final label = AppTextStyles.navLabel;

    // 시스템이 알약을 뷰 안쪽에 그리므로 그만큼 넓게 만든다(알약 폭 = width).
    return SizedBox(
      width: widget.width + BottomNavTokens.nativeSideInset * 2,
      height: BottomNavTokens.height,
      child: FutureBuilder<NativeTabIcons>(
        future: _icons,
        builder: (context, snapshot) {
          final icons = snapshot.data;
          // 아이콘이 준비되기 전에는 같은 크기의 빈 자리만 둔다. 화면 모드가 바뀌어 새 아이콘을
          // 그리는 중에는 이전 아이콘이 남아 있으므로, 이번 그리기가 끝난 뒤에만 뷰를 만든다.
          if (snapshot.connectionState != ConnectionState.done ||
              icons == null) {
            return const SizedBox.shrink();
          }
          _initialIndex ??= widget.currentIndex;
          return UiKitView(
            key: ValueKey('${tint.toARGB32()}-$_dark'),
            viewType: NativeTabBar.viewType,
            // 네이티브 탭 바가 터치를 받고 뒤의 Flutter 화면으로 새지 않게 한다.
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
            creationParamsCodec: const StandardMessageCodec(),
            creationParams: {
              'labels': BottomNavTokens.labels,
              'icons': icons.icons,
              'selectedIcons': icons.selectedIcons,
              'selectedIndex': _initialIndex,
              'pixelRatio': _pixelRatio,
              'dark': _dark,
              'normalColor': colors.textStrong.toARGB32(),
              'selectedColor': colors.brand.toARGB32(),
              'fontAsset': AppAssets.pretendardBold,
              'fontName': BottomNavTokens.nativeLabelFontName,
              'fontSize': label.fontSize,
              'letterSpacing': label.letterSpacing,
            },
            onPlatformViewCreated: _onPlatformViewCreated,
          );
        },
      ),
    );
  }
}
