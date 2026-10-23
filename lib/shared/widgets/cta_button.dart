import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/utils/app_haptics.dart';
import 'pressable.dart';

/// 주요 버튼 ("감정 기록하기", "오늘 기록 보기"). 폭은 부모를 채운다.
/// [soft]면 연한 핑크 배경 + 검정 글자(기록 카드 Before). 눌리면 살짝 흐려진다(머티리얼 번짐 효과 없음).
class CtaButton extends StatelessWidget {
  const CtaButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.height,
    this.soft = false,
  });

  final String label;
  final VoidCallback onPressed;
  final double height;
  final bool soft;

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
      child: Pressable(
        onTap: _press,
        child: Container(
          height: height,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: soft ? colors.ctaSoft : colors.cta,
            borderRadius: AppRadii.buttonBorderRadius,
          ),
          child: Text(
            label,
            style: soft
                ? AppTextStyles.buttonLarge.copyWith(color: colors.onCtaSoft)
                : AppTextStyles.button.copyWith(color: colors.onCta),
          ),
        ),
      ),
    );
  }
}
