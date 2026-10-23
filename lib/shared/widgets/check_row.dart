import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/app_assets.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_motion.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/utils/app_haptics.dart';

/// 체크 행(할 일): 왼쪽 원을 누르면 브랜드 핑크로 차오르며 체크가 나타나고, 완료되면 글자에
/// 취소선이 그어지고 흐려진다. 누르는 영역은 행 전체(최소 44).
class CheckRow extends StatelessWidget {
  const CheckRow({
    super.key,
    required this.title,
    required this.checked,
    required this.onChanged,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final bool checked;
  final ValueChanged<bool> onChanged;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    void toggle() {
      AppHaptics.selection();
      onChanged(!checked);
    }

    return Semantics(
      checked: checked,
      label: title,
      excludeSemantics: true,
      onTap: toggle,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: toggle,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: ComponentLayout.settingsRowHeight,
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: AppMotion.fast,
                curve: AppMotion.enter,
                width: ComponentLayout.checkSize,
                height: ComponentLayout.checkSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: checked ? colors.brand : Colors.transparent,
                  border: Border.all(
                    color: checked ? colors.brand : colors.navBorder,
                    width: 1.5,
                  ),
                ),
                child: AnimatedOpacity(
                  duration: AppMotion.fast,
                  opacity: checked ? 1 : 0,
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: SvgPicture.asset(
                      AppAssets.check,
                      colorFilter: ColorFilter.mode(
                        colors.onCta,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.space12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.space12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: AppMotion.fast,
                        style: AppTextStyles.rowTitle.copyWith(
                          color: checked
                              ? colors.textSecondary.withValues(alpha: 0.6)
                              : colors.textBlack,
                          decoration: checked
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                        child: Text(title),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: AppTextStyles.caption.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
