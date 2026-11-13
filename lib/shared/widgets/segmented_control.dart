import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_motion.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/utils/app_haptics.dart';

/// 2~4개 선택지를 가로로 묶고, 선택된 쪽에 흰 알약이 미끄러지듯 옮겨 가는 컨트롤
/// (주/월 기간 선택, 목록/달력 전환). 칩 여러 개를 늘어놓는 대신 쓴다.
class SegmentedControl extends StatelessWidget {
  const SegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  }) : assert(labels.length >= 2 && labels.length <= 4);

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final count = labels.length;
    return Semantics(
      container: true,
      child: Container(
        height: ComponentLayout.segmentedHeight,
        padding: const EdgeInsets.all(ComponentLayout.segmentedPadding),
        decoration: BoxDecoration(
          color: colors.chip,
          borderRadius: BorderRadius.circular(AppRadii.button),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final segmentWidth = constraints.maxWidth / count;
            return Stack(
              children: [
                AnimatedPositioned(
                  duration: AppMotion.fast,
                  curve: AppMotion.move,
                  left: segmentWidth * selectedIndex,
                  width: segmentWidth,
                  top: 0,
                  bottom: 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.cardWhite,
                      borderRadius: BorderRadius.circular(
                        AppRadii.button - ComponentLayout.segmentedPadding / 2,
                      ),
                      boxShadow: AppShadows.subtle,
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < count; i++)
                      Expanded(
                        child: Semantics(
                          button: true,
                          selected: i == selectedIndex,
                          label: labels[i],
                          excludeSemantics: true,
                          onTap: () => onChanged(i),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              if (i == selectedIndex) return;
                              AppHaptics.selection();
                              onChanged(i);
                            },
                            child: Center(
                              child: AnimatedDefaultTextStyle(
                                duration: AppMotion.fast,
                                style: AppTextStyles.button.copyWith(
                                  color: i == selectedIndex
                                      ? colors.textBlack
                                      : colors.textSecondary,
                                ),
                                child: Text(labels[i]),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
