import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/widgets/app_bottom_sheet.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../../shared/widgets/settings_group.dart';
import '../../auth/presentation/consent_texts.dart';
import '../models/app_settings.dart';
import 'settings_providers.dart';

/// 동의 관리 (F-11): 전체 탭 "동의 관리"에서 들어오는 하위 화면.
/// 위 카드에서 동의 3개를 켜고 끄고, 아래 카드에서 각 항목의 자세한 내용을 시트로 연다.
class ConsentSettingsScreen extends ConsumerWidget {
  const ConsentSettingsScreen({super.key});

  void _open(BuildContext context, String title, String body) {
    final colors = context.colors;
    showAppBottomSheet<void>(
      context,
      title: title,
      builder: (context) => Text(
        body,
        style: AppTextStyles.body.copyWith(
          color: colors.textSecondary,
          height: 1.6,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consents =
        (ref.watch(settingsProvider).value ?? const AppSettings(nickname: ''))
            .consents;
    final actions = ref.read(settingsActionsProvider);

    return PageScaffold(
      title: '동의 관리',
      subtitle: '언제든 바꿀 수 있어요.',
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
                  title: '사용 분석 동의 (선택)',
                  value: consents.analytics,
                  onChanged: (v) =>
                      actions.saveConsents(consents.copyWith(analytics: v)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space24),
            SettingsGroup(
              title: '자세히 보기',
              children: [
                SettingsRow.link(
                  key: const Key('consent-detail-privacy'),
                  title: ConsentTexts.privacyTitle,
                  onTap: () => _open(
                    context,
                    ConsentTexts.privacyTitle,
                    ConsentTexts.privacy,
                  ),
                ),
                SettingsRow.link(
                  key: const Key('consent-detail-ai'),
                  title: ConsentTexts.aiTitle,
                  onTap: () =>
                      _open(context, ConsentTexts.aiTitle, ConsentTexts.ai),
                ),
                SettingsRow.link(
                  key: const Key('consent-detail-analytics'),
                  title: ConsentTexts.analyticsTitle,
                  onTap: () => _open(
                    context,
                    ConsentTexts.analyticsTitle,
                    ConsentTexts.analytics,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
