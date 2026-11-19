import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_motion.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/utils/app_haptics.dart';

/// 2~4개 선택지를 가로로 묶은 세그먼트 버튼 (Figma `834:1248`).
///
/// 흰 알약 트랙 안에서 선택된 칸에만 회색(#F2F2F4) 알약이 깔리고, 선택이 바뀌면 미끄러지듯 옮겨 간다.
/// 글자 버전은 [SegmentedControl.new], 아이콘 버전은 [SegmentedControl.icons].
class SegmentedControl extends StatelessWidget {
  /// 글자 세그먼트 ("전체 / 안 읽음").
  const SegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  }) : iconAssets = null,
       assert(labels.length >= 2 && labels.length <= 4);

  /// 아이콘 세그먼트. [labels]는 화면 낭독기가 읽을 이름이고 화면에는 [iconAssets]만 보인다.
  const SegmentedControl.icons({
    super.key,
    required List<String> this.iconAssets,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  }) : assert(labels.length >= 2 && labels.length <= 4),
       assert(iconAssets.length == labels.length);

  final List<String> labels;
  final List<String>? iconAssets;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final count = labels.length;
    return Semantics(
      container: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ComponentLayout.segmentPaddingH,
          vertical: ComponentLayout.segmentPaddingV,
        ),
        decoration: BoxDecoration(
          color: colors.segmentTrack,
          borderRadius: AppRadii.pillBorderRadius,
        ),
        child: SizedBox(
          height: ComponentLayout.segmentHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              const gap = ComponentLayout.segmentGap;
              final segmentWidth =
                  (constraints.maxWidth - gap * (count - 1)) / count;
              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: ComponentLayout.segmentDuration,
                    curve: AppMotion.move,
                    left: (segmentWidth + gap) * selectedIndex,
                    width: segmentWidth,
                    top: 0,
                    bottom: 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.segmentSelected,
                        borderRadius: AppRadii.pillBorderRadius,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (var i = 0; i < count; i++) ...[
                        if (i > 0) const SizedBox(width: gap),
                        Expanded(child: _segment(context, i)),
                      ],
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _segment(BuildContext context, int i) {
    final colors = context.colors;
    final icons = iconAssets;
    return Semantics(
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
          child: icons == null
              ? Text(
                  labels[i],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.segmentLabel.copyWith(
                    color: colors.textBlack,
                  ),
                )
              : SvgPicture.asset(
                  icons[i],
                  width: ComponentLayout.segmentIconSize,
                  height: ComponentLayout.segmentIconSize,
                  colorFilter: ColorFilter.mode(
                    colors.textBlack,
                    BlendMode.srcIn,
                  ),
                ),
        ),
      ),
    );
  }
}
