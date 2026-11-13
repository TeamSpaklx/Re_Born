import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_motion.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/utils/app_haptics.dart';
import 'pressable.dart';

/// 버튼 모양. 화면당 주요 행동(primary)은 하나만 둔다.
enum CtaVariant {
  /// 브랜드 핑크 + 흰 글자: 화면의 주요 행동 ("저장", "감정 기록하기").
  primary,

  /// 연한 핑크 + 검정 글자: 기록 카드처럼 카드 안의 부드러운 주요 행동.
  soft,

  /// 연한 회색 + 진한 글자: 보조 행동 ("취소", "나중에").
  secondary,

  /// 연한 빨강 + 빨간 글자: 되돌릴 수 없는 행동 ("삭제").
  destructive,
}

/// 주요 버튼. 폭은 부모를 채운다. 높이가 52 이상이면 글자가 16, 그보다 낮으면 14다.
/// [onPressed]가 null이면 비활성(흐리게, 눌리지 않음). 눌리면 살짝 흐려진다(머티리얼 번짐 없음).
class CtaButton extends StatelessWidget {
  const CtaButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.height,
    this.variant = CtaVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final CtaVariant variant;

  void _press() {
    AppHaptics.tap();
    onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onPressed != null;
    final (fill, text) = switch (variant) {
      CtaVariant.primary => (colors.cta, colors.onCta),
      CtaVariant.soft => (colors.ctaSoft, colors.onCtaSoft),
      CtaVariant.secondary => (colors.chip, colors.textStrong),
      CtaVariant.destructive => (colors.dangerTile, colors.danger),
    };
    final style = height >= 52
        ? AppTextStyles.buttonLarge
        : AppTextStyles.button;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      onTap: enabled ? _press : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.4,
        duration: AppMotion.fast,
        child: Pressable(
          onTap: enabled ? _press : null,
          child: Container(
            height: height,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: fill,
              borderRadius: AppRadii.buttonBorderRadius,
            ),
            child: Text(label, style: style.copyWith(color: text)),
          ),
        ),
      ),
    );
  }
}
