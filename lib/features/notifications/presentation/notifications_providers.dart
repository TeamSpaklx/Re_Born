import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/data_revision.dart';
import '../../../core/providers/clock_provider.dart';
import '../../entries/presentation/entries_providers.dart';
import '../../settings/presentation/settings_providers.dart';
import '../models/app_notification.dart';

/// 알림 목록에 담는 최대 개수.
const _maxNotifications = 20;

/// 이 시간보다 오래된 코멘트 알림은 읽은 것으로 본다(읽음 기록이 아직 서버에 없어서 쓰는 임시 규칙).
const _unreadWindow = Duration(hours: 24);

/// 읽은 알림 id. 지금은 메모리에만 둔다(앱을 다시 켜면 비워진다).
class ReadNotifications extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void markRead(String id) => state = {...state, id};
}

final readNotificationsProvider =
    NotifierProvider<ReadNotifications, Set<String>>(ReadNotifications.new);

/// 알림 목록(최근 것이 먼저). AI 코멘트가 도착한 일기에서 만들고, 설정에서 끄면 비어 있다.
final notificationsProvider = FutureProvider<List<AppNotification>>((
  ref,
) async {
  ref.watch(dataRevisionProvider);
  final settings = await ref.watch(settingsProvider.future);
  if (!settings.notifications.aiComment) return const [];
  final entries = await ref.watch(entriesProvider.future);
  final now = ref.watch(clockProvider)();
  final read = ref.watch(readNotificationsProvider);
  final withFeedback = [
    for (final e in entries)
      if (e.feedback != null) e,
  ]..sort((a, b) => b.feedback!.createdAt.compareTo(a.feedback!.createdAt));
  return [
    for (final e in withFeedback.take(_maxNotifications))
      AppNotification(
        id: 'n-${e.id}',
        kind: NotificationKind.aiComment,
        title: 'AI 코멘트가 도착했어요',
        body: e.feedback!.comment,
        createdAt: e.feedback!.createdAt,
        read:
            read.contains('n-${e.id}') ||
            now.difference(e.feedback!.createdAt) > _unreadWindow,
        entryId: e.id,
      ),
  ];
});

/// 읽지 않은 알림 수 (홈 벨 뱃지).
final unreadNotificationCountProvider = Provider<int>((ref) {
  final list = ref.watch(notificationsProvider).value ?? const [];
  return list.where((n) => !n.read).length;
});
