import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_motion.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_spacing.dart';

/// 로딩 스켈레톤을 한꺼번에 깜빡이게 하는 틀. 안에 [SkeletonBox]를 여러 개 놓으면 같이 깜빡인다
/// (컨트롤러 하나만 쓴다). "애니메이션 줄이기" 설정이 켜져 있으면 깜빡이지 않는다.
class SkeletonScope extends StatefulWidget {
  const SkeletonScope({super.key, required this.child});

  final Widget child;

  @override
  State<SkeletonScope> createState() => _SkeletonScopeState();
}

class _SkeletonScopeState extends State<SkeletonScope>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.skeletonPulse,
  );
  late final Animation<double> _opacity = Tween<double>(
    begin: ComponentLayout.skeletonPulseMin,
    end: 1,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce) {
      _controller.stop();
      _controller.value = 1;
      _started = false;
    } else if (!_started) {
      _started = true;
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
    return _SkeletonPulse(
      opacity: _opacity,
      child: ExcludeSemantics(child: widget.child),
    );
  }
}

class _SkeletonPulse extends InheritedWidget {
  const _SkeletonPulse({required this.opacity, required super.child});

  final Animation<double> opacity;

  static Animation<double>? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_SkeletonPulse>()?.opacity;

  @override
  bool updateShouldNotify(_SkeletonPulse oldWidget) =>
      oldWidget.opacity != opacity;
}

/// 스켈레톤 블록 하나(둥근 직사각형). [SkeletonScope] 안에 있으면 깜빡이고, 밖이면 가만히 있다.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = AppRadii.button,
    this.circle = false,
  });

  final double? width;
  final double height;
  final double radius;

  /// true면 지름이 [height]인 원(아바타 자리).
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final box = Container(
      width: circle ? height : width,
      height: height,
      decoration: BoxDecoration(
        color: colors.skeleton,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(radius),
      ),
    );
    final pulse = _SkeletonPulse.maybeOf(context);
    if (pulse == null) return box;
    return FadeTransition(opacity: pulse, child: box);
  }
}

/// 흰 카드 모양 스켈레톤: 왼쪽 원 + 두 줄 글자 (목록 행·신호 카드 자리).
class SkeletonListCard extends StatelessWidget {
  const SkeletonListCard({super.key, this.height = 90});

  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20),
      decoration: BoxDecoration(
        color: colors.cardWhite,
        borderRadius: AppRadii.cardBorderRadius,
      ),
      child: const Row(
        children: [
          SkeletonBox(height: 48, circle: true),
          SizedBox(width: AppSpacing.space16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 140, height: 16, radius: 6),
                SizedBox(height: AppSpacing.space8),
                SkeletonBox(width: 200, height: 12, radius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
