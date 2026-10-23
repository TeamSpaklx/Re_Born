import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/cta_button.dart';

/// 홈 데이터를 불러오지 못했을 때: 문구 + "다시 시도" (docs/FRONTEND.md 4장, 디자인 없음).
class HomeErrorView extends StatelessWidget {
  const HomeErrorView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: SizedBox(
        width: 200,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '불러오지 못했어요',
              style: AppTextStyles.body.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: 16),
            CtaButton(label: '다시 시도', height: 48, onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
