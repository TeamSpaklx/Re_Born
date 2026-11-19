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

  /// 개발 확인용 테스트 알림. [delay]가 0이면 바로, 아니면 그만큼 뒤에 한 번만 울린다.
  /// 소리·배너를 직접 확인하는 용도라 알림 설정 화면의 디버그 항목에서만 부른다.
  Future<void> showTestNotification({Duration delay = Duration.zero});
}

/// `flutter_local_notifications` 구현. 알림 문구에는 기록 내용이 들어가지 않는다.
class LocalNotificationService implements NotificationService {
  LocalNotificationService([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;

  static const _reminderId = 1;
  static const _testId = 99;
  // 안드로이드 알림 채널의 소리는 한 번 만들면 바꿀 수 없어서, 소리를 넣을 때 채널 ID를 새로 만들었다.
  static const _legacyChannelId = 'daily_reminder';
  static const _channelId = 'daily_reminder_v2';
  static const _channelName = '기록 리마인드';

  /// 알림음 파일 이름. 안드로이드는 `android/app/src/main/res/raw/reborn_notification.wav`,
  /// iOS는 `ios/Runner/reborn_notification.wav`에 있다(소문자·밑줄만 쓴다).
  static const _soundName = 'reborn_notification';

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
        // 상태바 작은 아이콘은 흰색 단색이어야 한다(컬러 앱 아이콘은 사각형으로 보인다).
        android: AndroidInitializationSettings('@drawable/ic_notification'),
        // 권한은 "알림 켜기"를 눌렀을 때 요청하므로 초기화 때는 묻지 않는다.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    await _removeLegacyChannel();
    _ready = true;
  }

  /// 소리 없는 예전 채널이 설정 화면에 남지 않도록 지운다. 실패해도 알림 예약에는 영향이 없다.
  Future<void> _removeLegacyChannel() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.deleteNotificationChannel(channelId: _legacyChannelId);
    } catch (error) {
      debugPrint('예전 알림 채널 삭제 실패: $error');
    }
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

  static const _notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: '정해 둔 시간에 기록을 남기도록 알려 줘요.',
      playSound: true,
      sound: RawResourceAndroidNotificationSound(_soundName),
    ),
    iOS: DarwinNotificationDetails(
      presentSound: true,
      sound: '$_soundName.wav',
    ),
  );

  @override
  Future<void> showTestNotification({Duration delay = Duration.zero}) =>
      _safe(() async {
        await _init();
        const title = '테스트 알림';
        const body = '알림음이 잘 들리나요?';
        if (delay <= Duration.zero) {
          await _plugin.show(
            id: _testId,
            title: title,
            body: body,
            notificationDetails: _notificationDetails,
          );
          return;
        }
        await _plugin.zonedSchedule(
          id: _testId,
          title: title,
          body: body,
          scheduledDate: tz.TZDateTime.now(tz.local).add(delay),
          notificationDetails: _notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }, null);

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
      notificationDetails: _notificationDetails,
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
