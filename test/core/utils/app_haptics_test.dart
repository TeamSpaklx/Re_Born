import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/core/utils/app_haptics.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const native = MethodChannel('reborn/haptics');

  late List<String> nativeCalls;
  late List<Object?> systemCalls;

  setUp(() {
    nativeCalls = [];
    systemCalls = [];
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') {
        systemCalls.add(call.arguments);
      }
      return null;
    });
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    messenger.setMockMethodCallHandler(SystemChannels.platform, null);
    messenger.setMockMethodCallHandler(native, null);
  });

  void mockNative() {
    messenger.setMockMethodCallHandler(native, (call) async {
      nativeCalls.add(call.method);
      return null;
    });
  }

  test('Android: 기기 기본 효과(네이티브)로 재생하고 Flutter 기본 햅틱은 부르지 않는다', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    mockNative();

    await AppHaptics.selection();
    await AppHaptics.tap();

    expect(nativeCalls, ['selection', 'tap']);
    expect(systemCalls, isEmpty);
  });

  test('Android: 네이티브가 없으면 Flutter 기본 햅틱으로 대신한다', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    await AppHaptics.selection();
    await AppHaptics.tap();

    expect(systemCalls, [
      'HapticFeedbackType.selectionClick',
      'HapticFeedbackType.lightImpact',
    ]);
  });

  test('iOS: 네이티브 채널 없이 Flutter 기본 햅틱(Taptic Engine)을 쓴다', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    mockNative();

    await AppHaptics.selection();
    await AppHaptics.tap();

    expect(nativeCalls, isEmpty);
    expect(systemCalls, [
      'HapticFeedbackType.selectionClick',
      'HapticFeedbackType.lightImpact',
    ]);
  });
}
