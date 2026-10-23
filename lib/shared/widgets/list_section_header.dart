import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

/// 목록을 묶는 머리글 ("오늘", "어제", "지난 알림"). 오른쪽에 짧은 요약·동작을 둘 수 있다.
class ListSectionHeader extends StatelessWidget {
  const ListSectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.only(
          top: AppSpacing.space24,
          bottom: AppSpacing.space8,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.sectionLabel.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
