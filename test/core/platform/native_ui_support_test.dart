import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/core/platform/native_ui_support.dart';

void main() {
  group('parseIosMajorVersion', () {
    test('iOS의 operatingSystemVersion 문자열에서 주 버전을 읽는다', () {
      expect(parseIosMajorVersion('Version 27.0.1 (Build 24A446)'), 27);
      expect(parseIosMajorVersion('Version 26.5 (Build 23F73)'), 26);
      expect(parseIosMajorVersion('Version 18.7.2 (Build 22H124)'), 18);
    });

    test('읽을 수 없으면 null', () {
      expect(parseIosMajorVersion(''), isNull);
      expect(parseIosMajorVersion('알 수 없음'), isNull);
    });
  });

  group('supportsNativeTabBar', () {
    const ios27 = 'Version 27.0.1 (Build 24A446)';
    const ios26 = 'Version 26.0 (Build 23A340)';
    const ios18 = 'Version 18.7.2 (Build 22H124)';

    test('iOS 26 이상에서만 true', () {
      expect(
        supportsNativeTabBar(platform: TargetPlatform.iOS, osVersion: ios27),
        isTrue,
      );
      expect(
        supportsNativeTabBar(platform: TargetPlatform.iOS, osVersion: ios26),
        isTrue,
      );
      expect(
        supportsNativeTabBar(platform: TargetPlatform.iOS, osVersion: ios18),
        isFalse,
      );
    });

    test('Android는 버전 문자열과 상관없이 false', () {
      expect(
        supportsNativeTabBar(
          platform: TargetPlatform.android,
          osVersion: ios27,
        ),
        isFalse,
      );
    });

    test('버전을 읽을 수 없으면 false', () {
      expect(
        supportsNativeTabBar(platform: TargetPlatform.iOS, osVersion: '???'),
        isFalse,
      );
    });
  });
}
