import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// OS 알림 권한과 기록 리마인드(매일 정해진 시각의 로컬 알림). 서버·FCM 푸시는 쓰지 않는다(F-10 확장 범위).
/// 테스트에서는 가짜로 바꿔 끼운다.
abstract interface class NotificationService {
  /// 알림 권한을 OS에 요청한다(iOS 팝업, 안드로이드 13+ 팝업, 그 아래는 항상 허용). 허용되면 true.
  Future<bool> requestPermission();

  /// 지금 권한이 허용되어 있는지(팝업은 띄우지 않는다).
  Future<bool> hasPermission();

  /// 매일 [hour]:[minute]에 오늘의 기록을 남기도록 알린다(이미 있으면 바꾼다).
  Future<void> scheduleDailyReminder({required int hour, required int minute});

  Future<void> cancelReminder();
}

/// `flutter_local_notifications` 구현. 알림 문구에는 기록 내용이 들어가지 않는다.
class LocalNotificationService implements NotificationService {
  LocalNotificationService([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;

  static const _reminderId = 1;
  static const _channelId = 'daily_reminder';
  static const _channelName = '기록 리마인드';

  Future<void> _init() async {
    if (_ready) return;
    tz_data.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // 시간대를 못 읽으면 한국 시간으로 둔다(기본 사용자 시간대).
      tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // 권한은 "알림 켜기"를 눌렀을 때 요청하므로 초기화 때는 묻지 않는다.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _ready = true;
  }

  /// 알림 기능이 안 되는 환경(권한 거부, 플러그인 없음 등)에서도 앱이 멈추지 않도록 실패는 false/무시로 바꾼다.
  Future<T> _safe<T>(Future<T> Function() action, T fallback) async {
    try {
      return await action();
    } catch (error) {
      debugPrint('알림 서비스 실패: $error');
      return fallback;
    }
  }

  @override
  Future<bool> requestPermission() => _safe(_requestPermission, false);

  @override
  Future<bool> hasPermission() => _safe(_hasPermission, false);

  @override
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) => _safe(() => _schedule(hour, minute), null);

  @override
  Future<void> cancelReminder() => _safe(_cancel, null);

  Future<bool> _requestPermission() async {
    await _init();
    if (kIsWeb) return false;
    if (Platform.isIOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      return await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.requestNotificationsPermission() ?? false;
    }
    return false;
  }

  Future<bool> _hasPermission() async {
    await _init();
    if (kIsWeb) return false;
    if (Platform.isIOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final options = await ios?.checkPermissions();
      return options?.isEnabled ?? false;
    }
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.areNotificationsEnabled() ?? false;
    }
    return false;
  }

  Future<void> _schedule(int hour, int minute) async {
    await _init();
    final now = tz.TZDateTime.now(tz.local);
    var first = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!first.isAfter(now)) first = first.add(const Duration(days: 1));
    await _plugin.zonedSchedule(
      id: _reminderId,
      title: '오늘의 마음을 남겨 볼까요?',
      body: '1분만 천천히 돌아봐요.',
      scheduledDate: first,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: '정해 둔 시간에 기록을 남기도록 알려 줘요.',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      // 정확한 알람 권한 없이 대략적인 시각에 울린다(배터리 최적화에 맞춤).
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _cancel() async {
    await _init();
    await _plugin.cancel(id: _reminderId);
  }
}
