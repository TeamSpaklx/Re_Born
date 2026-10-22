import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_dialogs.dart';
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
    );
    if (!ok) return;
    await ref.read(settingsActionsProvider).deleteAllRecords();
    if (context.mounted) showAppSnackBar(context, '기록을 모두 삭제했어요');
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

    Widget switchRow(
      Key key,
      String title,
      bool value,
      ValueChanged<bool> onChanged,
    ) => Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.body.copyWith(color: colors.textBlack),
          ),
        ),
        Switch(
          key: key,
          value: value,
          activeTrackColor: colors.brand,
          activeThumbColor: colors.onCta,
          onChanged: onChanged,
        ),
      ],
    );

    Widget actionRow(Key key, String title, VoidCallback onTap) =>
        GestureDetector(
          key: key,
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                title,
                style: AppTextStyles.body.copyWith(color: colors.brand),
              ),
            ),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '설정',
          style: AppTextStyles.sectionTitle.copyWith(color: colors.textBlack),
        ),
        const SizedBox(height: 12),
        AppCard.white(
          padding: const EdgeInsets.fromLTRB(18, 8, 10, 8),
          child: Column(
            children: [
              switchRow(
                const Key('consent-privacy'),
                '개인정보 수집·이용 동의',
                consents.privacy,
                (v) => actions.saveConsents(consents.copyWith(privacy: v)),
              ),
              switchRow(
                const Key('consent-ai'),
                '감정 분석 사용 (앱 안 규칙 기반)',
                consents.aiAnalysis,
                (v) => actions.saveConsents(consents.copyWith(aiAnalysis: v)),
              ),
              switchRow(
                const Key('consent-analytics'),
                '사용 분석 동의',
                consents.analytics,
                (v) => actions.saveConsents(consents.copyWith(analytics: v)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard.white(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              actionRow(
                const Key('delete-records'),
                '기록 전체 삭제',
                () => _deleteRecords(context, ref),
              ),
              actionRow(
                const Key('delete-account'),
                '계정 삭제',
                () => _deleteAccount(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '리본은 의료·상담 서비스가 아니에요. 힘든 마음이 계속되면 가까운 사람이나 전문 기관의 도움을 받아 보세요.',
          style: AppTextStyles.caption.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}
