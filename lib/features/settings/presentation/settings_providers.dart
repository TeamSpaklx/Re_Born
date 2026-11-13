import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/data_providers.dart';
import '../../../app/data_revision.dart';
import '../models/app_settings.dart';

/// 닉네임·동의 설정.
final settingsProvider = FutureProvider<AppSettings>((ref) {
  ref.watch(dataRevisionProvider);
  return ref.watch(settingsRepositoryProvider).get();
});

/// 동의 변경과 데이터 삭제 (SPEC F-11).
class SettingsActions {
  SettingsActions(this._ref);

  final Ref _ref;

  Future<void> saveConsents(Consents consents) async {
    final repo = _ref.read(settingsRepositoryProvider);
    final current = await repo.get();
    await repo.save(current.copyWith(consents: consents));
    _ref.read(dataRevisionProvider.notifier).bump();
  }

  Future<void> saveNickname(String nickname) async {
    final repo = _ref.read(settingsRepositoryProvider);
    final current = await repo.get();
    await repo.save(current.copyWith(nickname: nickname.trim()));
    _ref.read(dataRevisionProvider.notifier).bump();
  }

  /// 프로필 사진을 바꾼다. [path]가 null이면 기본 캐릭터로 되돌린다.
  Future<void> saveProfileImage(String? path) async {
    final repo = _ref.read(settingsRepositoryProvider);
    final current = await repo.get();
    await repo.save(
      path == null
          ? current.copyWith(clearProfileImage: true)
          : current.copyWith(profileImagePath: path),
    );
    _ref.read(dataRevisionProvider.notifier).bump();
  }

  Future<void> saveNotifications(NotificationPrefs prefs) async {
    final repo = _ref.read(settingsRepositoryProvider);
    final current = await repo.get();
    await repo.save(current.copyWith(notifications: prefs));
    _ref.read(dataRevisionProvider.notifier).bump();
  }

  static (int, int) _parse(String hhmm) {
    final parts = hhmm.split(':');
    return (int.parse(parts[0]), int.parse(parts[1]));
  }

  /// 저장된 설정대로 OS 리마인드 예약을 맞춘다(앱을 켤 때 한 번). 켜져 있으면 예약, 아니면 취소.
  Future<void> syncReminder() async {
    final prefs =
        (await _ref.read(settingsRepositoryProvider).get()).notifications;
    final service = _ref.read(notificationServiceProvider);
    if (prefs.reminder) {
      final (h, m) = _parse(prefs.reminderTime);
      await service.scheduleDailyReminder(hour: h, minute: m);
    } else {
      await service.cancelReminder();
    }
  }

  /// 기록 리마인드를 켜거나 끈다. 켤 때 OS 알림 권한이 없으면 요청하고, 거부되면 켜지 않고 false를 돌려준다.
  Future<bool> setReminder(bool on) async {
    final service = _ref.read(notificationServiceProvider);
    final repo = _ref.read(settingsRepositoryProvider);
    final prefs = (await repo.get()).notifications;
    if (on) {
      final allowed =
          await service.hasPermission() || await service.requestPermission();
      if (!allowed) return false;
      final (h, m) = _parse(prefs.reminderTime);
      await service.scheduleDailyReminder(hour: h, minute: m);
    } else {
      await service.cancelReminder();
    }
    await saveNotifications(prefs.copyWith(reminder: on));
    return true;
  }

  /// 리마인드 시각을 바꾸고, 켜져 있으면 다시 예약한다.
  Future<void> setReminderTime(String hhmm) async {
    final prefs =
        (await _ref.read(settingsRepositoryProvider).get()).notifications;
    await saveNotifications(prefs.copyWith(reminderTime: hhmm));
    if (prefs.reminder) {
      final (h, m) = _parse(hhmm);
      await _ref
          .read(notificationServiceProvider)
          .scheduleDailyReminder(hour: h, minute: m);
    }
  }

  /// 가입 마지막 "알림 켜기": OS 권한을 요청하고, 허용되면 인사이트 알림과 리마인드를 켠다.
  /// 거부되면 인사이트 알림(앱 안 목록)만 켜고 false를 돌려준다.
  Future<bool> enableNotifications() async {
    final allowed = await _ref
        .read(notificationServiceProvider)
        .requestPermission();
    final repo = _ref.read(settingsRepositoryProvider);
    final prefs = (await repo.get()).notifications;
    await saveNotifications(prefs.copyWith(insight: true));
    if (allowed) return setReminder(true);
    return false;
  }

  /// 기록 전체 삭제: 기록과 거기서 만들어진 지수 이력·인사이트를 지운다. 인물·체크리스트는 남긴다.
  Future<void> deleteAllRecords() async {
    await _ref.read(entriesRepositoryProvider).deleteAll();
    await _ref.read(indexHistoryRepositoryProvider).deleteAll();
    await _ref.read(insightsRepositoryProvider).deleteAll();
    _ref.read(dataRevisionProvider.notifier).bump();
  }
}

final settingsActionsProvider = Provider<SettingsActions>(SettingsActions.new);
