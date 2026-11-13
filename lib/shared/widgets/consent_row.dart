import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/app_assets.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_motion.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/utils/app_haptics.dart';

/// 약관·동의 한 줄: 체크 원 + 항목 이름 + ("필수"/"선택") + (내용 보기 화살표).
/// [emphasized]면 "전체 동의"처럼 연한 핑크 상자 안에 굵게 보인다.
class ConsentRow extends StatelessWidget {
  const ConsentRow({
    super.key,
    required this.label,
    required this.checked,
    required this.onChanged,
    this.tag,
    this.onView,
    this.emphasized = false,
  });

  final String label;
  final bool checked;
  final ValueChanged<bool> onChanged;

  /// "필수" 또는 "선택".
  final String? tag;

  /// 있으면 오른쪽에 내용 보기 화살표가 생긴다.
  final VoidCallback? onView;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    void toggle() {
      AppHaptics.selection();
      onChanged(!checked);
    }

    final row = Row(
      children: [
        Expanded(
          child: Semantics(
            checked: checked,
            label: tag == null ? label : '$tag $label',
            excludeSemantics: true,
            onTap: toggle,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: toggle,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: emphasized ? 56 : 48),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: AppMotion.fast,
                      curve: AppMotion.enter,
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: checked ? colors.brand : Colors.transparent,
                        border: Border.all(
                          color: checked ? colors.brand : colors.navBorder,
                          width: 1.5,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: SvgPicture.asset(
                          AppAssets.check,
                          colorFilter: ColorFilter.mode(
                            checked ? colors.onCta : colors.navBorder,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space12),
                    if (tag != null) ...[
                      Text(
                        tag!,
                        style: AppTextStyles.body.copyWith(
                          color: tag == '필수'
                              ? colors.brand
                              : colors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space8),
                    ],
                    Expanded(
                      child: Text(
                        label,
                        style:
                            (emphasized
                                    ? AppTextStyles.groupTitle
                                    : AppTextStyles.rowTitle)
                                .copyWith(color: colors.textBlack),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (onView != null)
          Semantics(
            button: true,
            label: '$label 내용 보기',
            excludeSemantics: true,
            onTap: onView,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onView,
              child: SizedBox(
                width: AppSpacing.minTouchTarget,
                height: AppSpacing.minTouchTarget,
                child: Center(child: SvgPicture.asset(AppAssets.chevronSignal)),
              ),
            ),
          ),
      ],
    );

    if (!emphasized) return row;
    return Container(
      padding: const EdgeInsets.only(left: AppSpacing.space16),
      decoration: BoxDecoration(
        color: colors.cardPink,
        borderRadius: BorderRadius.circular(AppRadii.button + 4),
      ),
      child: row,
    );
  }
}
