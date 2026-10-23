import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_assets.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/providers/clock_provider.dart';
import '../../../shared/widgets/app_tab_bar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/list_section_header.dart';
import '../../../shared/widgets/notification_row.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../models/app_notification.dart';
import 'notifications_providers.dart';

/// 알림 목록: "전체 / 안 읽음" 탭, 읽지 않은 알림은 핑크 강조 + 점. 누르면 해당 인사이트로 간다.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final now = ref.watch(clockProvider)();
    final all = ref.watch(notificationsProvider);

    Widget rowFor(AppNotification n) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space8),
      child: NotificationRow(
        iconAsset: n.kind == NotificationKind.insightNegative
            ? AppAssets.forum
            : AppAssets.sealCheck,
        title: n.title,
        body: n.body,
        timeLabel: formatRelativeTime(n.createdAt, now),
        unread: !n.read,
        onTap: () => context.push(AppRoutes.insightDetail(n.insightId)),
      ),
    );

    return PageScaffold(
      title: '알림',
      largeTitle: true,
      actions: [
        PageAction(
          label: '알림 설정',
          onTap: () => context.push(AppRoutes.notificationSettings),
        ),
      ],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageMargin,
            ),
            child: AppTabBar(
              labels: const ['전체', '안 읽음'],
              selectedIndex: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
          ),
          Expanded(
            child: all.when(
              data: (list) {
                final unread = list.where((n) => !n.read).toList();
                final read = list.where((n) => n.read).toList();
                final shown = _tab == 0 ? list : unread;
                if (shown.isEmpty) {
                  return Center(
                    child: EmptyState(
                      message: _tab == 0 ? '아직 알림이 없어요' : '읽지 않은 알림이 없어요',
                      hint: '관계에 변화가 감지되면 여기서 알려 드릴게요.',
                      showMascot: true,
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageMargin,
                    0,
                    AppSpacing.pageMargin,
                    AppSpacing.space40,
                  ),
                  children: _tab == 0
                      ? [
                          if (unread.isNotEmpty) ...[
                            const ListSectionHeader(title: '새 알림'),
                            for (final n in unread) rowFor(n),
                          ],
                          if (read.isNotEmpty) ...[
                            const ListSectionHeader(title: '지난 알림'),
                            for (final n in read) rowFor(n),
                          ],
                        ]
                      : [
                          const SizedBox(height: AppSpacing.space16),
                          for (final n in unread) rowFor(n),
                        ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (e, st) => Center(
                child: ErrorState(
                  onRetry: () => ref.invalidate(notificationsProvider),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
