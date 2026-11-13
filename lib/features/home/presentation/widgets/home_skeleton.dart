import 'package:flutter/material.dart';

import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/skeleton.dart';
import 'home_top_bar.dart';

/// 홈 데이터를 불러오는 동안의 스켈레톤: 상단 바(로고·벨)는 그대로 두고, 날짜·인사말·카드 자리만 연한 블록이 깜빡인다.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    const margin = EdgeInsets.symmetric(horizontal: AppSpacing.pageMargin);

    return Stack(
      children: [
        SkeletonScope(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: HomeTopBar.heightOf(context)),
                const SizedBox(height: HomeLayout.headerToDate),
                const Padding(
                  padding: margin,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SkeletonBox(width: 96, height: 14, radius: 6),
                  ),
                ),
                const SizedBox(height: AppSpacing.space12),
                const Padding(
                  padding: margin,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SkeletonBox(width: 220, height: 24, radius: 8),
                  ),
                ),
                const SizedBox(height: AppSpacing.space8),
                const Padding(
                  padding: margin,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SkeletonBox(width: 150, height: 24, radius: 8),
                  ),
                ),
                const SizedBox(height: HomeLayout.greetingToRecordCard),
                const Padding(
                  padding: margin,
                  child: SkeletonBox(
                    height: HomeLayout.recordCardHeightBefore,
                    radius: AppRadii.card,
                  ),
                ),
                const SizedBox(height: HomeLayout.recordCardToSignalTitle),
                const Padding(
                  padding: margin,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SkeletonBox(width: 120, height: 20, radius: 6),
                  ),
                ),
                const SizedBox(height: HomeLayout.sectionTitleToCard),
                const Padding(
                  padding: margin,
                  child: SkeletonBox(
                    height: HomeLayout.signalCardHeight,
                    radius: AppRadii.card,
                  ),
                ),
                const SizedBox(height: HomeLayout.signalCardToGraph),
                const Padding(
                  padding: margin,
                  child: SkeletonBox(
                    height: HomeLayout.graphCardHeight,
                    radius: AppRadii.card,
                  ),
                ),
                const SizedBox(height: HomeLayout.graphToActionTitle),
                const Padding(
                  padding: margin,
                  child: SkeletonListCard(height: HomeLayout.actionCardHeight),
                ),
              ],
            ),
          ),
        ),
        const Positioned(left: 0, right: 0, top: 0, child: HomeTopBar()),
      ],
    );
  }
}
