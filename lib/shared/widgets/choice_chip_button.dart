import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/utils/app_haptics.dart';

/// 고르는 알약 버튼 (감정, 강도, 관계 유형 선택). 임시 디자인: 홈의 칩·버튼 값으로 조합.
class ChoiceChipButton extends StatelessWidget {
  const ChoiceChipButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          AppHaptics.selection();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? colors.brand : colors.chip,
            borderRadius: AppRadii.pillBorderRadius,
          ),
          child: Text(
            label,
            style: AppTextStyles.button.copyWith(
              color: selected ? colors.onCta : colors.textStrong,
            ),
          ),
        ),
      ),
    );
  }
}
