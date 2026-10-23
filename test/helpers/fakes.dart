import 'package:reborn_app/core/platform/notification_service.dart';

/// 알림 서비스 가짜: OS 권한 허용 여부를 정해 두고, 예약·취소 호출을 기록한다.
class FakeNotificationService implements NotificationService {
  FakeNotificationService({this.allowed = true});

  bool allowed;
  int permissionRequests = 0;
  final scheduled = <(int, int)>[];
  int cancels = 0;

  @override
  Future<bool> hasPermission() async => allowed && permissionRequests > 0;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return allowed;
  }

  @override
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async => scheduled.add((hour, minute));

  @override
  Future<void> cancelReminder() async => cancels++;
}
