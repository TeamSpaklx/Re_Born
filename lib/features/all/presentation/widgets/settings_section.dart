import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import '../../../../shared/widgets/settings_group.dart';
import '../../../settings/models/app_settings.dart';
import '../../../settings/presentation/settings_providers.dart';

/// 전체 탭의 설정 (F-11). **임시 디자인**.
/// 동의 on/off, 기록 전체 삭제(확인 팝업), 계정 삭제(로그인 연결 뒤 사용), 의료 서비스 아님 안내.
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
    if (context.mounted) showAppToast(context, '기록을 모두 삭제했어요');
  }

  Future<void> _deleteAccount(BuildContext context) {
    return showAppConfirmDialog(
      context,
      title: '계정 삭제',
      message: '계정 삭제는 로그인 기능이 연결된 뒤에 사용할 수 있어요. 삭제하면 복구할 수 없고, 재인증이 필요해요.',
      confirmLabel: '확인',
      cancelLabel: null,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final settings =
        ref.watch(settingsProvider).value ?? const AppSettings(nickname: '');
    final consents = settings.consents;
    final actions = ref.read(settingsActionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '설정',
          style: AppTextStyles.sectionTitle.copyWith(color: colors.textBlack),
        ),
        const SizedBox(height: 12),
        SettingsGroup(
          children: [
            SettingsRow.toggle(
              key: const Key('consent-privacy'),
              title: '개인정보 수집·이용 동의',
              value: consents.privacy,
              onChanged: (v) =>
                  actions.saveConsents(consents.copyWith(privacy: v)),
            ),
            SettingsRow.toggle(
              key: const Key('consent-ai'),
              title: '감정 분석 사용 (앱 안 규칙 기반)',
              value: consents.aiAnalysis,
              onChanged: (v) =>
                  actions.saveConsents(consents.copyWith(aiAnalysis: v)),
            ),
            SettingsRow.toggle(
              key: const Key('consent-analytics'),
              title: '사용 분석 동의',
              value: consents.analytics,
              onChanged: (v) =>
                  actions.saveConsents(consents.copyWith(analytics: v)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SettingsGroup(
          title: '데이터 관리',
          children: [
            SettingsRow.destructive(
              key: const Key('delete-records'),
              title: '기록 전체 삭제',
              onTap: () => _deleteRecords(context, ref),
            ),
            SettingsRow.destructive(
              key: const Key('delete-account'),
              title: '계정 삭제',
              onTap: () => _deleteAccount(context),
            ),
          ],
        ),
        if (kDebugMode) ...[
          const SizedBox(height: 12),
          SettingsGroup(
            children: [
              SettingsRow.link(
                key: const Key('open-design-gallery'),
                title: '디자인 갤러리 (개발용)',
                onTap: () => context.push(AppRoutes.devGallery),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        Text(
          '리본은 의료·상담 서비스가 아니에요. 힘든 마음이 계속되면 가까운 사람이나 전문 기관의 도움을 받아 보세요.',
          style: AppTextStyles.caption.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}
