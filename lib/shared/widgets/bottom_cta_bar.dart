import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import 'cta_button.dart';

/// 화면 맨 아래에 고정되는 주요 행동 영역: 큰 버튼 하나(+ 선택적으로 아래 보조 링크).
/// 토스처럼 화면당 주요 행동을 하단에 하나만 둘 때 쓴다. 키보드가 올라오면 위로 밀린다.
class BottomCtaBar extends StatelessWidget {
  const BottomCtaBar({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = CtaVariant.primary,
    this.secondary,
  });

  final String label;

  /// null이면 비활성.
  final VoidCallback? onPressed;
  final CtaVariant variant;

  /// 버튼 아래에 놓는 보조 행동(예: 텍스트 링크).
  final Widget? secondary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ColoredBox(
      color: colors.background,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageMargin,
          ComponentLayout.ctaBarTop,
          AppSpacing.pageMargin,
          ComponentLayout.ctaBarBottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CtaButton(
              label: label,
              height: ComponentLayout.ctaButtonHeight,
              variant: variant,
              onPressed: onPressed,
            ),
            if (secondary != null) ...[
              const SizedBox(height: AppSpacing.space8),
              secondary!,
            ],
          ],
        ),
      ),
    );
  }
}
