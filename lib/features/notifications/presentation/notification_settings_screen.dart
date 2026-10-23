import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/widgets/app_bottom_sheet.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../../shared/widgets/settings_group.dart';
import '../../settings/models/app_settings.dart';
import '../../settings/presentation/settings_providers.dart';

/// 알림 설정: 인사이트 알림, 기록 리마인드와 시각. 앱 안 알림 목록이 먼저이고 기기 푸시는 준비 중이다.
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  static const _times = ['18:00', '19:00', '20:00', '21:00', '22:00', '23:00'];

  static String labelOf(String hhmm) {
    final hour = int.parse(hhmm.split(':').first);
    final period = hour < 12 ? '오전' : '오후';
    final h = hour % 12 == 0 ? 12 : hour % 12;
    return '$period $h시';
  }

  Future<void> _pickTime(
    BuildContext context,
    WidgetRef ref,
    NotificationPrefs prefs,
  ) async {
    final picked = await showAppBottomSheet<String>(
      context,
      title: '언제 알려 드릴까요?',
      builder: (context) => Column(
        children: [
          for (final t in _times)
            SheetOptionRow(
              title: labelOf(t),
              selected: prefs.reminderTime == t,
              onTap: () => Navigator.of(context).pop(t),
            ),
        ],
      ),
    );
    if (picked == null) return;
    await ref
        .read(settingsActionsProvider)
        .saveNotifications(prefs.copyWith(reminderTime: picked));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final settings =
        ref.watch(settingsProvider).value ?? const AppSettings(nickname: '');
    final prefs = settings.notifications;
    final actions = ref.read(settingsActionsProvider);

    return PageScaffold(
      title: '알림 설정',
      subtitle: '필요한 알림만 골라서 받아요.',
      largeTitle: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageMargin,
          AppSpacing.space8,
          AppSpacing.pageMargin,
          AppSpacing.space40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SettingsGroup(
              children: [
                SettingsRow.toggle(
                  key: const Key('notify-insight'),
                  title: '인사이트 알림',
                  value: prefs.insight,
                  onChanged: (v) =>
                      actions.saveNotifications(prefs.copyWith(insight: v)),
                ),
                SettingsRow.toggle(
                  key: const Key('notify-reminder'),
                  title: '기록 리마인드',
                  value: prefs.reminder,
                  onChanged: (v) =>
                      actions.saveNotifications(prefs.copyWith(reminder: v)),
                ),
                if (prefs.reminder)
                  SettingsRow.link(
                    key: const Key('notify-time'),
                    title: '알림 시간',
                    trailingText: labelOf(prefs.reminderTime),
                    onTap: () => _pickTime(context, ref, prefs),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.space16),
            Text(
              '알림은 먼저 앱 안 알림 목록에 모여요. 기기로 오는 푸시 알림은 준비 중이에요.',
              style: AppTextStyles.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
