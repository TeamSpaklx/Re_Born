import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_assets.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import '../../../../shared/widgets/settings_group.dart';
import '../../../auth/presentation/auth_providers.dart';
import '../../../ai_comment/models/ai_feedback.dart';
import '../../../notifications/presentation/notifications_providers.dart';
import '../../../record/presentation/crisis_notice.dart';
import '../../../security/presentation/app_lock_controller.dart';
import '../../../settings/presentation/settings_providers.dart';

/// 마이 탭의 설정 (F-10·F-11). 레퍼런스 설정 화면처럼 카드 밖 소제목 + 아이콘 목록 카드로 묶는다.
/// - 앱 사용: 알림, 알림 설정, 화면 모드(기기 설정 / 라이트 / 다크), 앱 잠금
/// - AI 코멘트: 말투(다정하게 / 담백하게)
/// - 계정: 로그아웃, 기록 전체 삭제(확인 팝업), 계정 삭제(재인증 화면)
/// - 도움: 도움받을 곳(위기 상담 연락처)
/// 맨 아래에 의료 서비스 아님 안내.
class SettingsSection extends ConsumerWidget {
  const SettingsSection({super.key});

  Future<void> _deleteRecords(BuildContext context, WidgetRef ref) async {
    final ok = await showAppConfirmDialog(
      context,
      title: '기록을 모두 삭제할까요?',
      message: '일기와 AI 코멘트가 모두 지워지고, 되돌릴 수 없어요. 체크리스트는 남아요.',
      confirmLabel: '삭제',
      destructive: true,
    );
    if (!ok) return;
    await ref.read(settingsActionsProvider).deleteAllRecords();
    if (context.mounted) showAppToast(context, '기록을 모두 삭제했어요', success: true);
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final ok = await showAppConfirmDialog(
      context,
      title: '로그아웃할까요?',
      message: '언제든 다시 로그인할 수 있어요.',
      confirmLabel: '로그아웃',
    );
    if (!ok) return;
    await ref.read(authActionsProvider).signOut();
    if (context.mounted) context.go(AppRoutes.login);
  }

  /// 화면 모드 고르기: 기기 설정(자동 전환) / 라이트 / 다크. 고르면 바로 바뀌고 시트가 닫힌다.
  Future<void> _pickThemeMode(BuildContext context, WidgetRef ref) async {
    final current = ref.read(themeModeProvider);
    final picked = await showAppBottomSheet<ThemeMode>(
      context,
      title: '화면 모드',
      builder: (context) => Column(
        children: [
          for (final mode in const [
            ThemeMode.system,
            ThemeMode.light,
            ThemeMode.dark,
          ])
            SheetOptionRow(
              key: Key('theme-mode-${mode.name}'),
              title: mode.label,
              subtitle: mode == ThemeMode.system
                  ? '기기의 라이트·다크 설정에 맞춰 자동으로 바뀌어요.'
                  : null,
              selected: mode == current,
              onTap: () => Navigator.of(context).pop(mode),
            ),
        ],
      ),
    );
    if (picked == null || picked == current) return;
    await ref.read(themeModeProvider.notifier).setMode(picked);
  }

  /// AI 코멘트 말투 고르기. 다음에 받는 코멘트부터 바뀐다.
  Future<void> _pickTone(
    BuildContext context,
    WidgetRef ref,
    CommentTone current,
  ) async {
    final picked = await showAppBottomSheet<CommentTone>(
      context,
      title: 'AI 코멘트 말투',
      message: '다음에 쓰는 일기부터 이 말투로 코멘트를 받아요.',
      builder: (context) => Column(
        children: [
          for (final tone in CommentTone.values)
            SheetOptionRow(
              key: Key('comment-tone-${tone.name}'),
              title: tone.label,
              subtitle: tone.description,
              selected: tone == current,
              onTap: () => Navigator.of(context).pop(tone),
            ),
        ],
      ),
    );
    if (picked == null || picked == current) return;
    await ref.read(settingsActionsProvider).saveCommentTone(picked);
  }

  void _openHelp(BuildContext context) {
    showAppBottomSheet<void>(
      context,
      title: '도움받을 곳',
      message: '힘든 마음이 계속되면 혼자 견디지 말고 전문 기관에 이야기해 보세요.',
      builder: (context) => const CrisisContacts(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final unread = ref.watch(unreadNotificationCountProvider);
    final tone =
        ref.watch(settingsProvider).value?.commentTone ?? CommentTone.warm;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsGroup(
          title: '앱 사용',
          children: [
            SettingsRow.link(
              key: const Key('open-notifications'),
              iconAsset: AppAssets.ixNotification,
              title: '알림',
              trailingText: unread > 0 ? '$unread개 안 읽음' : null,
              trailingEmphasis: true,
              onTap: () => context.push(AppRoutes.notifications),
            ),
            SettingsRow.link(
              key: const Key('open-notification-settings'),
              iconAsset: AppAssets.ixSetting,
              title: '알림 설정',
              onTap: () => context.push(AppRoutes.notificationSettings),
            ),
            SettingsRow.link(
              key: const Key('theme-mode'),
              iconAsset: AppAssets.ixMoon,
              title: '화면 모드',
              trailingText: ref.watch(themeModeProvider).label,
              onTap: () => _pickThemeMode(context, ref),
            ),
            const _AppLockRow(),
          ],
        ),
        const SizedBox(height: AppSpacing.space24),
        SettingsGroup(
          title: 'AI 코멘트',
          children: [
            SettingsRow.link(
              key: const Key('comment-tone'),
              iconAsset: AppAssets.ixMessageText,
              title: '코멘트 말투',
              trailingText: tone.label,
              onTap: () => _pickTone(context, ref, tone),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space24),
        SettingsGroup(
          title: '계정',
          children: [
            SettingsRow.link(
              key: const Key('logout'),
              iconAsset: AppAssets.ixLogout,
              title: '로그아웃',
              onTap: () => _logout(context, ref),
            ),
            SettingsRow.destructive(
              key: const Key('delete-records'),
              iconAsset: AppAssets.trash,
              title: '기록 전체 삭제',
              onTap: () => _deleteRecords(context, ref),
            ),
            SettingsRow.destructive(
              key: const Key('delete-account'),
              iconAsset: AppAssets.ixProfileDelete,
              title: '계정 삭제',
              onTap: () => context.push(AppRoutes.accountDelete),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space24),
        SettingsGroup(
          title: '도움',
          children: [
            SettingsRow.link(
              key: const Key('open-help'),
              iconAsset: AppAssets.ixCall,
              title: '도움받을 곳',
              onTap: () => _openHelp(context),
            ),
          ],
        ),
        if (kDebugMode) ...[
          const SizedBox(height: AppSpacing.space24),
          SettingsGroup(
            title: '개발용',
            children: [
              SettingsRow.link(
                key: const Key('open-design-gallery'),
                title: '디자인 갤러리',
                onTap: () => context.push(AppRoutes.devGallery),
              ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.space16),
        Text(
          '리본은 의료·상담 서비스가 아니에요. 힘든 마음이 계속되면 가까운 사람이나 전문 기관의 도움을 받아 보세요.',
          style: AppTextStyles.caption.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}

/// 앱 잠금(Face ID·Touch ID·지문·기기 암호) 토글 행. 켤 때 한 번 인증에 성공해야 켜진다.
class _AppLockRow extends ConsumerWidget {
  const _AppLockRow();

  Future<void> _toggle(BuildContext context, WidgetRef ref, bool on) async {
    final result = await ref
        .read(appLockControllerProvider.notifier)
        .setEnabled(on);
    if (!context.mounted) return;
    switch (result) {
      case AppLockToggleResult.enabled:
        showAppToast(context, '앱 잠금을 켰어요', success: true);
      case AppLockToggleResult.disabled:
        showAppToast(context, '앱 잠금을 껐어요', success: true);
      case AppLockToggleResult.unavailable:
        showAppToast(context, '휴대폰 화면 잠금을 먼저 설정해 주세요');
      case AppLockToggleResult.failed:
        showAppToast(context, '인증하지 못해 앱 잠금을 켜지 않았어요');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(
      appLockControllerProvider.select((s) => s.enabled),
    );
    final label = ref.watch(deviceAuthKindProvider).value?.label ?? '';
    return SettingsRow.toggle(
      key: const Key('app-lock'),
      iconAsset: AppAssets.ixLock,
      title: label.isEmpty ? '앱 잠금' : '앱 잠금 ($label)',
      value: enabled,
      onChanged: (v) => _toggle(context, ref, v),
    );
  }
}
