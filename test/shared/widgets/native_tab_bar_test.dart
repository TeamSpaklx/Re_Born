import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/app/theme/app_colors.dart';
import 'package:reborn_app/app/theme/app_theme.dart';
import 'package:reborn_app/app/theme/bottom_nav_tokens.dart';
import 'package:reborn_app/shared/widgets/native_tab_bar.dart';

void main() {
  // UiKitView는 iOS에서만 만들 수 있다.
  final iosOnly = TargetPlatformVariant.only(TargetPlatform.iOS);

  late List<MethodCall> platformViewCalls;
  late List<MethodCall> tabBarCalls;

  /// 가짜 아이콘: 실제 렌더링 없이 바이트만 넘긴다.
  Future<NativeTabIcons> fakeIcons(double pixelRatio) async {
    final bytes = Uint8List.fromList([1, 2, 3]);
    return NativeTabIcons(
      icons: List.filled(4, bytes),
      selectedIcons: List.filled(4, bytes),
    );
  }

  setUp(() {
    platformViewCalls = [];
    tabBarCalls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform_views, (call) async {
          platformViewCalls.add(call);
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform_views, null);
  });

  Future<void> pumpBar(
    WidgetTester tester, {
    int currentIndex = 0,
    ValueChanged<int>? onTap,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: NativeTabBar(
              currentIndex: currentIndex,
              onTap: onTap ?? (_) {},
              iconLoader: fakeIcons,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  /// 네이티브 뷰의 채널 이름은 플랫폼 뷰 id로 정해진다.
  String tabBarChannelName() {
    final create = platformViewCalls.firstWhere((c) => c.method == 'create');
    final id = (create.arguments as Map)['id'];
    return 'reborn/native_tab_bar_$id';
  }

  void mockTabBarChannel(String name) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(MethodChannel(name), (call) async {
          tabBarCalls.add(call);
          return null;
        });
  }

  testWidgets('알약 폭이 354가 되도록 시스템 여백만큼 넓은 네이티브 뷰를 만든다', (tester) async {
    await pumpBar(tester);

    final size = tester.getSize(find.byType(NativeTabBar));
    expect(
      size.width,
      BottomNavTokens.width + BottomNavTokens.nativeSideInset * 2,
    );
    expect(size.height, BottomNavTokens.height);
    expect(find.byType(UiKitView), findsOneWidget);
  }, variant: iosOnly);

  testWidgets('라벨·색·글꼴·선택 index를 만들 때 네이티브에 넘긴다', (tester) async {
    await pumpBar(tester, currentIndex: 2);

    final view = tester.widget<UiKitView>(find.byType(UiKitView));
    expect(view.viewType, NativeTabBar.viewType);
    final params = view.creationParams! as Map;
    expect(params['labels'], BottomNavTokens.labels);
    expect(params['selectedIndex'], 2);
    expect((params['icons'] as List).length, 4);
    expect((params['selectedIcons'] as List).length, 4);
    expect(params['normalColor'], AppColors.light.textStrong.toARGB32());
    expect(params['selectedColor'], AppColors.light.brand.toARGB32());
    expect(params['fontName'], BottomNavTokens.nativeLabelFontName);
    expect(params['fontSize'], 10);
    expect(params['letterSpacing'], -0.1);
  }, variant: iosOnly);

  testWidgets('네이티브 탭 눌림(onTap)을 index로 전달한다', (tester) async {
    final taps = <int>[];
    await pumpBar(tester, onTap: taps.add);

    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      tabBarChannelName(),
      const StandardMethodCodec().encodeMethodCall(
        const MethodCall('onTap', 3),
      ),
      (_) {},
    );

    expect(taps, [3]);
  }, variant: iosOnly);

  testWidgets('currentIndex가 바뀌면 네이티브 선택 표시를 맞춘다', (tester) async {
    await pumpBar(tester, currentIndex: 0);
    mockTabBarChannel(tabBarChannelName());

    await pumpBar(tester, currentIndex: 1);

    expect(tabBarCalls.map((c) => c.method), ['setSelectedIndex']);
    expect(tabBarCalls.single.arguments, 1);
  }, variant: iosOnly);

  testWidgets('index가 그대로면 네이티브를 다시 부르지 않는다', (tester) async {
    await pumpBar(tester, currentIndex: 0);
    mockTabBarChannel(tabBarChannelName());

    await pumpBar(tester, currentIndex: 0);

    expect(tabBarCalls, isEmpty);
  }, variant: iosOnly);
}
