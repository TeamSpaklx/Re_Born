import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// iOS 26부터 시스템 탭 바가 Liquid Glass 재질로 그려진다.
const nativeTabBarMinIosVersion = 26;

/// `Platform.operatingSystemVersion`("Version 27.0.1 (Build 24A446)")에서 주 버전을 읽는다.
/// 읽을 수 없으면 null.
int? parseIosMajorVersion(String operatingSystemVersion) {
  final match = RegExp(r'(\d+)(?:\.\d+)*').firstMatch(operatingSystemVersion);
  return match == null ? null : int.tryParse(match.group(1)!);
}

/// 하단 탭 바를 네이티브(`UITabBar`, Liquid Glass)로 그릴 수 있는지.
/// iOS 26 이상에서만 true이고, Android·웹·iOS 26 미만은 Flutter가 그린 탭 바를 쓴다.
bool supportsNativeTabBar({TargetPlatform? platform, String? osVersion}) {
  if (kIsWeb) return false;
  if ((platform ?? defaultTargetPlatform) != TargetPlatform.iOS) return false;
  final major = parseIosMajorVersion(
    osVersion ?? Platform.operatingSystemVersion,
  );
  return major != null && major >= nativeTabBarMinIosVersion;
}
