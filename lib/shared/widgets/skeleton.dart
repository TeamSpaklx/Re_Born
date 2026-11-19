import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_spacing.dart';

/// 로딩 중에 내용 자리를 미리 보여 주는 스켈레톤 (Figma 홈 스켈레톤 `834:2351`).
///
/// 회색(#E4E4E4) 막대·원([SkeletonBox])을 흰 카드([SkeletonCard]) 위에 놓는다. 화면 하나의 스켈레톤은
/// [SkeletonPulse]로 감싸면 모든 막대가 같은 박자로 은은하게 깜빡인다(불투명도 1 ↔ 0.5, 1.2초 왕복, 추정).
/// 기기에서 '동작 줄이기'를 켜면 깜빡이지 않는다. 화면 낭독기에는 "불러오는 중"으로 한 번만 읽힌다.
///
/// 처음 불러올 때만 쓴다. 데이터가 바뀌어 다시 불러올 때는 이전 내용을 그대로 두도록
/// `AsyncValue.when(skipLoadingOnReload: true, ...)`로 감싼다(스크롤이 맨 위로 튀지 않게).
class SkeletonPulse extends StatefulWidget {
  const SkeletonPulse({super.key, required this.child});

  final Widget child;

  @override
  State<SkeletonPulse> createState() => _SkeletonPulseState();
}

class _SkeletonPulseState extends State<SkeletonPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: ComponentLayout.skeletonPulse,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '불러오는 중',
      container: true,
      child: ExcludeSemantics(
        child: _SkeletonScope(
          notifier: CurvedAnimation(
            parent: _controller,
            curve: Curves.easeInOut,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class _SkeletonScope extends InheritedNotifier<Animation<double>> {
  const _SkeletonScope({required super.notifier, required super.child});

  /// 0(가장 진함) ~ 1(가장 연함). [SkeletonPulse] 밖이면 0.
  static double phaseOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_SkeletonScope>()
          ?.notifier
          ?.value ??
      0;
}

/// 회색 막대(또는 [circle]이면 원). 크기를 주지 않으면 부모를 채운다.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.radius = AppRadii.skeletonBar,
  }) : circle = false;

  /// 지름 [size]인 원(아바타 자리).
  const SkeletonBox.circle({super.key, required double size})
    : width = size,
      height = size,
      radius = 0,
      circle = true;

  final double? width;
  final double? height;
  final double radius;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final phase = _SkeletonScope.phaseOf(context);
    final opacity = 1 - (1 - ComponentLayout.skeletonMinOpacity) * phase;
    final color = context.colors.skeleton;
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: color.a * opacity),
          shape: circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circle ? null : BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// 스켈레톤 막대를 올리는 흰 카드(모서리 24). 막대는 Figma 좌표대로 [Positioned]로 놓는다.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, required this.height, required this.children});

  final double height;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.colors.cardWhite,
        borderRadius: AppRadii.cardBorderRadius,
      ),
      child: Stack(children: children),
    );
  }
}

/// 목록 한 칸 모양의 스켈레톤 카드.
///
/// - [SkeletonListCard.new]: 아이콘 타일 48 + 두 줄 (Figma 제안 카드 `859:481`, 높이 90).
/// - [SkeletonListCard.avatar]: 원형 아바타 56 + 세 줄 (Figma 최근 관계 카드 `859:469`, 높이 104).
class SkeletonListCard extends StatelessWidget {
  const SkeletonListCard({super.key, this.titleWidth = 190}) : avatar = false;

  const SkeletonListCard.avatar({super.key, this.titleWidth = 78})
    : avatar = true;

  final bool avatar;

  /// 제목 막대 폭. 여러 장을 늘어놓을 때 조금씩 다르게 주면 덜 기계적으로 보인다.
  final double titleWidth;

  @override
  Widget build(BuildContext context) {
    if (avatar) {
      return SkeletonCard(
        height: 104,
        children: [
          const Positioned(
            left: 20,
            top: 28,
            child: SkeletonBox.circle(size: 56),
          ),
          Positioned(
            left: 87,
            top: 26,
            child: SkeletonBox(width: titleWidth, height: 16),
          ),
          const Positioned(
            left: 87,
            top: 53,
            child: SkeletonBox(width: 152, height: 12),
          ),
          const Positioned(
            left: 87,
            top: 75,
            child: SkeletonBox(width: 92, height: 8),
          ),
        ],
      );
    }
    return SkeletonCard(
      height: 90,
      children: [
        const Positioned(
          left: 20,
          top: 21,
          child: SkeletonBox(width: 48, height: 48, radius: AppRadii.iconTile),
        ),
        Positioned(
          left: 82,
          top: 27,
          child: SkeletonBox(width: titleWidth, height: 15),
        ),
        const Positioned(
          left: 82,
          top: 54,
          child: SkeletonBox(width: 132, height: 10),
        ),
      ],
    );
  }
}

/// 섹션 제목 자리 막대(높이 16, 위아래 여백 포함 32줄 안에 놓임).
class SkeletonHeading extends StatelessWidget {
  const SkeletonHeading({super.key, this.width = 120});

  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: Align(
        alignment: Alignment.centerLeft,
        child: SkeletonBox(width: width, height: 16),
      ),
    );
  }
}

/// 목록 화면 공용 스켈레톤: 카드 [count]장을 세로로(간격 12) 놓는다.
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.count = 3, this.avatar = false});

  final int count;
  final bool avatar;

  static const _titleWidths = [190.0, 170.0, 150.0, 180.0];
  static const _nameWidths = [78.0, 64.0, 92.0, 70.0];

  @override
  Widget build(BuildContext context) {
    return SkeletonPulse(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.actionCardGap),
            avatar
                ? SkeletonListCard.avatar(
                    titleWidth: _nameWidths[i % _nameWidths.length],
                  )
                : SkeletonListCard(
                    titleWidth: _titleWidths[i % _titleWidths.length],
                  ),
          ],
        ],
      ),
    );
  }
}
