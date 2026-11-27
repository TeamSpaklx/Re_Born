import 'package:flutter/material.dart';

import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/bottom_nav_tokens.dart';
import '../../../../shared/widgets/skeleton.dart';
import 'home_top_bar.dart';

/// 홈 데이터를 불러오는 동안의 화면 (Figma 홈 화면 스켈레톤 `834:2351`).
///
/// 상단 바(로고·알림)는 그대로 보이고, 아래에 인사말 3줄 → 기록 카드 → 최근 관계 → 감정 차트 → 제안 2장 자리를
/// 회색 막대로 채운다. 막대 크기·위치는 Figma 좌표 그대로이고, 카드 사이 간격은 실제 홈([HomeLayout])과 같다.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    const margin = EdgeInsets.symmetric(horizontal: AppSpacing.pageMargin);
    return Stack(
      children: [
        SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: SkeletonPulse(
            child: Padding(
              padding: margin,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: HomeTopBar.heightOf(context)),
                  const SizedBox(height: HomeLayout.headerToDate),
                  const _Greeting(),
                  const SizedBox(height: HomeLayout.greetingToRecordCard),
                  const _RecordCard(),
                  const SizedBox(height: HomeLayout.recordCardToGraph),
                  const _ChartCard(),
                  const SizedBox(height: HomeLayout.graphToActionTitle),
                  const _SectionHeader(titleWidth: 120),
                  const SizedBox(height: HomeLayout.sectionTitleToCard),
                  const SkeletonListCard(titleWidth: 190),
                  const SizedBox(height: AppSpacing.actionCardGap),
                  const SkeletonListCard(titleWidth: 170),
                  const SizedBox(height: BottomNavTokens.scrollBottomPadding),
                ],
              ),
            ),
          ),
        ),
        const Positioned(left: 0, right: 0, top: 0, child: HomeTopBar()),
      ],
    );
  }
}

/// 날짜 + 인사말 두 줄 (Figma `859:457`, 85 높이).
class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 85,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 3,
            child: SkeletonBox(width: 88, height: 12),
          ),
          Positioned(
            left: 0,
            top: 29,
            child: SkeletonBox(width: 212, height: 20),
          ),
          Positioned(
            left: 0,
            top: 59,
            child: SkeletonBox(width: 154, height: 20),
          ),
        ],
      ),
    );
  }
}

/// 감정 기록 카드 (Figma `859:461`, 268 높이).
class _RecordCard extends StatelessWidget {
  const _RecordCard();

  @override
  Widget build(BuildContext context) {
    return const SkeletonCard(
      height: HomeLayout.recordCardHeightBefore,
      children: [
        Positioned(
          left: 21,
          top: 28,
          child: SkeletonBox(width: 250, height: 15),
        ),
        Positioned(
          left: 21,
          top: 58,
          child: SkeletonBox(width: 158, height: 12),
        ),
        Positioned(
          left: 21,
          right: 20,
          top: 90,
          child: SkeletonBox(height: 88, radius: 20),
        ),
        Positioned(
          left: 20,
          right: 20,
          top: 194,
          child: SkeletonBox(height: 52, radius: AppRadii.button),
        ),
      ],
    );
  }
}

/// 섹션 제목(+ 오른쪽 "전체 보기") 자리 (Figma `859:467`, `859:468`).
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.titleWidth});

  final double titleWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: HomeLayout.sectionTitleHeight,
      child: Row(
        children: [
          SkeletonBox(width: titleWidth, height: 16),
          const Spacer(),
        ],
      ),
    );
  }
}

/// 감정 차트 카드 (Figma `859:474`, 180 높이).
class _ChartCard extends StatelessWidget {
  const _ChartCard();

  @override
  Widget build(BuildContext context) {
    return const SkeletonCard(
      height: HomeLayout.graphCardHeight,
      children: [
        Positioned(
          left: 20,
          top: 17,
          child: SkeletonBox(width: 120, height: 12),
        ),
        Positioned(
          left: 20,
          top: 43,
          child: SkeletonBox(width: 48, height: 10),
        ),
        Positioned(
          left: 20,
          right: 20,
          top: 65,
          child: SkeletonBox(height: 76, radius: 10),
        ),
        Positioned(
          left: 20,
          top: 155,
          child: SkeletonBox(width: 204, height: 10),
        ),
      ],
    );
  }
}
