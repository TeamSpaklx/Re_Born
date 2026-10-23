import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_assets.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/widgets/app_text_button.dart';
import '../../../shared/widgets/bottom_cta_bar.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../../shared/widgets/permission_row.dart';
import '../../../shared/widgets/step_progress_bar.dart';
import '../../settings/models/app_settings.dart';
import '../../settings/presentation/settings_providers.dart';

/// 가입 4/4: 알림 안내. 켜면 인사이트 알림과 기록 리마인드를 쓰고, 나중에 설정에서 바꿀 수 있다.
class PermissionScreen extends ConsumerWidget {
  const PermissionScreen({super.key});

  Future<void> _enable(BuildContext context, WidgetRef ref) async {
    final router = GoRouter.of(context);
    await ref
        .read(settingsActionsProvider)
        .saveNotifications(
          const NotificationPrefs(insight: true, reminder: true),
        );
    router.go(AppRoutes.today);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    return PageScaffold(
      title: '알림을 켜면\n더 도움이 돼요',
      subtitle: '필요한 알림만 보내 드려요.',
      largeTitle: true,
      showBack: false,
      progress: const StepProgressBar(current: 4, total: 4),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageMargin,
          AppSpacing.space8,
          AppSpacing.pageMargin,
          AppSpacing.space24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '선택 권한',
              style: AppTextStyles.sectionLabel.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const PermissionRow(
              iconAsset: AppAssets.bell,
              title: '인사이트 알림',
              description: '관계의 변화가 감지되면 알려 드려요.',
            ),
            const PermissionRow(
              iconAsset: AppAssets.forum,
              title: '기록 리마인드',
              description: '정해 둔 시간에 오늘의 마음을 남기도록 알려 드려요.',
            ),
            const SizedBox(height: AppSpacing.space16),
            Text(
              '알림은 기기 설정과 리본 설정에서 언제든 끌 수 있어요.',
              style: AppTextStyles.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      bottom: BottomCtaBar(
        label: '알림 켜기',
        onPressed: () => _enable(context, ref),
        secondary: AppTextButton(
          label: '나중에 할게요',
          color: colors.textSecondary,
          onTap: () => context.go(AppRoutes.today),
        ),
      ),
    );
  }
}
