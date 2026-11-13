import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/data_providers.dart';
import '../../../app/data_revision.dart';
import '../../insights/models/insight.dart';
import '../../people/presentation/people_providers.dart';
import '../../settings/presentation/settings_providers.dart';
import '../models/app_notification.dart';

/// 알림 목록(최근 것이 먼저). 인사이트에서 만들고, 설정에서 인사이트 알림을 끄면 비어 있다.
final notificationsProvider = FutureProvider<List<AppNotification>>((
  ref,
) async {
  ref.watch(dataRevisionProvider);
  final settings = await ref.watch(settingsProvider.future);
  if (!settings.notifications.insight) return const [];
  final insights = await ref.watch(insightsRepositoryProvider).list();
  final people = await ref.watch(peopleProvider.future);
  final names = {for (final p in people) p.id: p.name};
  return [
    for (final i in insights)
      AppNotification(
        id: 'n-${i.id}',
        kind: i.type == InsightType.negativeTrend
            ? NotificationKind.insightNegative
            : NotificationKind.insightRecovery,
        title: i.type == InsightType.negativeTrend
            ? '${names[i.personId] ?? '한 사람'}님과의 관계를 살펴보세요'
            : '${names[i.personId] ?? '한 사람'}님과의 관계가 나아지고 있어요',
        body: i.message,
        createdAt: i.createdAt,
        read: i.read,
        insightId: i.id,
      ),
  ];
});

/// 읽지 않은 알림 수 (홈 벨 뱃지).
final unreadNotificationCountProvider = Provider<int>((ref) {
  final list = ref.watch(notificationsProvider).value ?? const [];
  return list.where((n) => !n.read).length;
});
