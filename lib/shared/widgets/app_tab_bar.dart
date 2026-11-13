import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_motion.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/utils/app_haptics.dart';

/// 밑줄 탭: 같은 화면 안의 내용 묶음을 바꾼다(알림의 "전체/안 읽음"). 선택된 탭 아래 핑크 줄이 미끄러진다.
/// 모양만 다른 선택이면 [SegmentedControl]을 쓴다.
class AppTabBar extends StatelessWidget {
  const AppTabBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final count = labels.length;
    return SizedBox(
      height: 48,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth / count;
          return Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SizedBox(
                  height: 1,
                  child: ColoredBox(color: colors.chip),
                ),
              ),
              AnimatedPositioned(
                duration: AppMotion.fast,
                curve: AppMotion.move,
                left: width * selectedIndex,
                width: width,
                bottom: 0,
                child: SizedBox(
                  height: 2,
                  child: ColoredBox(color: colors.brand),
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
                              style: AppTextStyles.buttonLarge.copyWith(
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
    );
  }
}
