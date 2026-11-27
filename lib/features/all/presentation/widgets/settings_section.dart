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
import '../../../notifications/presentation/notifications_providers.dart';
import '../../../security/presentation/app_lock_controller.dart';
import '../../../settings/presentation/settings_providers.dart';

/// 전체 탭의 설정 (F-10·F-11). 레퍼런스 설정 화면처럼 카드 밖 소제목 + 아이콘 목록 카드로 묶는다.
/// - 개인정보 보호 및 보안: 안내 카드(누르면 설명 시트), 동의 관리(하위 화면), 앱 잠금
/// - 앱 사용: 알림, 알림 설정, 화면 모드(기기 설정 / 라이트 / 다크)
/// - 계정: 로그아웃, 기록 전체 삭제(확인 팝업), 계정 삭제(재인증 화면)
/// 맨 아래에 의료 서비스 아님 안내.
class SettingsSection extends ConsumerWidget {
  const SettingsSection({super.key});

  Future<void> _deleteRecords(BuildContext context, WidgetRef ref) async {
    final ok = await showAppConfirmDialog(
      context,
      title: '기록을 모두 삭제할까요?',
      message: '기록과 거기서 만들어진 지수·인사이트가 모두 지워지고, 되돌릴 수 없어요. 인물과 체크리스트는 남아요.',
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

  void _openPrivacyInfo(BuildContext context) {
    final colors = context.colors;
    showAppBottomSheet<void>(
      context,
      title: '내 기록은 이렇게 지켜요',
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final line in _privacyPoints)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space12),
              child: Text(
                '• $line',
                style: AppTextStyles.body.copyWith(
                  color: colors.textSecondary,
                  height: 1.6,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static const _privacyPoints = [
    '감정 분석은 앱 안의 규칙으로만 해요. 외부 AI에 기록을 보내지 않아요.',
    '기록은 내 계정에서만 볼 수 있어요.',
    '앱 잠금을 켜면 Face ID·지문·기기 암호로 앱을 지킬 수 있어요.',
    '기록 전체 삭제와 계정 삭제는 아래 "계정"에서 언제든 할 수 있어요.',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final unread = ref.watch(unreadNotificationCountProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SettingsGroupHeader(title: '개인정보 보호 및 보안'),
        SettingsInfoCard(
          key: const Key('privacy-info'),
          iconAsset: AppAssets.ixShieldTick,
          title: '기록은 이 기기 안에서만 분석해요',
          description: '감정 분석은 앱 안 규칙으로만 해요.\n기록 내용은 밖으로 보내지 않아요.',
          onTap: () => _openPrivacyInfo(context),
        ),
        const SizedBox(height: AppSpacing.space12),
        const _SecurityGroup(),
        const SizedBox(height: AppSpacing.space24),
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

/// 개인정보 보호 및 보안 카드: 동의 관리(하위 화면)와 앱 잠금(Face ID·Touch ID·지문·기기 암호).
/// 앱 잠금은 켤 때 한 번 인증에 성공해야 켜진다.
class _SecurityGroup extends ConsumerWidget {
  const _SecurityGroup();

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
    return SettingsGroup(
      children: [
        SettingsRow.link(
          key: const Key('open-consents'),
          iconAsset: AppAssets.ixDocumentText,
          title: '동의 관리',
          onTap: () => context.push(AppRoutes.consentSettings),
        ),
        SettingsRow.toggle(
          key: const Key('app-lock'),
          iconAsset: AppAssets.ixLock,
          title: label.isEmpty ? '앱 잠금' : '앱 잠금 ($label)',
          value: enabled,
          onChanged: (v) => _toggle(context, ref, v),
        ),
      ],
    );
  }
}
