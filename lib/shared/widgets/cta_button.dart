import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/utils/app_haptics.dart';

/// 주요 버튼 ("감정 기록하기", "오늘 기록 보기"). 폭은 부모를 채운다.
class CtaButton extends StatelessWidget {
  const CtaButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.height,
  });

  final String label;
  final VoidCallback onPressed;
  final double height;

  void _press() {
    AppHaptics.tap();
    onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: _press,
      child: Material(
        color: colors.cta,
        borderRadius: AppRadii.buttonBorderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _press,
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: Center(
              child: Text(
                label,
                style: AppTextStyles.button.copyWith(color: colors.onCta),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
