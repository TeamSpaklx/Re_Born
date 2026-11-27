import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/data_providers.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/widgets/app_bottom_sheet.dart';
import '../../../shared/widgets/app_dialogs.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../../shared/widgets/settings_group.dart';
import '../../security/presentation/app_lock_controller.dart';
import '../../settings/models/app_settings.dart';
import '../../settings/presentation/settings_providers.dart';

/// 알림 설정: AI 코멘트 알림, 기록 리마인드와 시각. 앱 안 알림 목록이 먼저이고 기기 푸시는 준비 중이다.
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
    await ref.read(settingsActionsProvider).setReminderTime(picked);
  }

  /// 디버그 전용: 알림음·배너를 바로 확인한다. 권한이 없으면 먼저 요청한다.
  Future<void> _sendTest(
    BuildContext context,
    WidgetRef ref, {
    Duration delay = Duration.zero,
  }) async {
    final service = ref.read(notificationServiceProvider);
    final allowed = await ref
        .read(appLockControllerProvider.notifier)
        .suspendWhile(service.requestPermission);
    if (!allowed) {
      if (context.mounted) {
        showAppToast(context, '알림 권한이 꺼져 있어요. 기기 설정에서 켜 주세요.');
      }
      return;
    }
    await service.showTestNotification(delay: delay);
    if (context.mounted && delay > Duration.zero) {
      showAppToast(context, '${delay.inSeconds}초 뒤에 알림이 와요. 홈 화면으로 나가 보세요.');
    }
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
                  key: const Key('notify-ai-comment'),
                  title: 'AI 코멘트 알림',
                  value: prefs.aiComment,
                  onChanged: (v) =>
                      actions.saveNotifications(prefs.copyWith(aiComment: v)),
                ),
                SettingsRow.toggle(
                  key: const Key('notify-reminder'),
                  title: '기록 리마인드',
                  value: prefs.reminder,
                  onChanged: (v) async {
                    final ok = await actions.setReminder(v);
                    if (!ok && context.mounted) {
                      showAppToast(context, '알림 권한이 꺼져 있어요. 기기 설정에서 켜 주세요.');
                    }
                  },
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
            if (kDebugMode) ...[
              const SizedBox(height: AppSpacing.space16),
              SettingsGroup(
                children: [
                  SettingsRow.link(
                    key: const Key('notify-test-now'),
                    title: '테스트 알림 바로 보내기 (개발용)',
                    onTap: () => _sendTest(context, ref),
                  ),
                  SettingsRow.link(
                    key: const Key('notify-test-delayed'),
                    title: '10초 뒤 테스트 알림 (개발용)',
                    onTap: () => _sendTest(
                      context,
                      ref,
                      delay: const Duration(seconds: 10),
                    ),
                  ),
                ],
              ),
            ],
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
