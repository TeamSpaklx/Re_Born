import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_assets.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/providers/clock_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/list_section_header.dart';
import '../../../shared/widgets/notification_row.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../../shared/widgets/segmented_control.dart';
import '../../../shared/widgets/skeleton.dart';
import '../models/app_notification.dart';
import 'notifications_providers.dart';

/// 알림 목록 (Figma 알림 `834:1148`): 가운데 제목 + 오른쪽 설정 톱니, "전체 / 안 읽음" 세그먼트.
/// 읽지 않은 알림은 핑크 강조 + 점이고, 누르면 해당 인사이트로 간다. 비어 있으면 마스코트 + "받은 알림이 없습니다".
/// 알림이 있을 때의 목록 디자인은 Figma에 아직 없어 기존 [NotificationRow]를 쓴다.
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
      centerTitle: true,
      actions: [
        PageIconAction(
          key: const Key('notification-settings'),
          iconAsset: AppAssets.ixSetting,
          label: '알림 설정',
          onTap: () => context.push(AppRoutes.notificationSettings),
        ),
      ],
      body: Column(
        children: [
          const SizedBox(height: ComponentLayout.centerTitleToSegment),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageMargin,
            ),
            child: SegmentedControl(
              labels: const ['전체', '안 읽음'],
              selectedIndex: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
          ),
          Expanded(
            child: all.when(
              skipLoadingOnReload: true,
              data: (list) {
                final unread = list.where((n) => !n.read).toList();
                final read = list.where((n) => n.read).toList();
                final shown = _tab == 0 ? list : unread;
                if (shown.isEmpty) {
                  return const Align(
                    alignment: ComponentLayout.quietEmptyAlignment,
                    child: QuietEmptyState(message: '받은 알림이 없습니다'),
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
              loading: () => const SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.pageMargin,
                  AppSpacing.space16,
                  AppSpacing.pageMargin,
                  0,
                ),
                child: SkeletonList(),
              ),
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
