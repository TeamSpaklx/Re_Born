import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// 도넛 차트의 한 조각.
class DonutSegment {
  const DonutSegment({required this.value, required this.color});

  final double value;
  final Color color;
}

/// 도넛 차트: 조각 사이에 작은 틈이 있고 가운데에 [center]를 놓는다. 값이 모두 0이면 회색 고리만 그린다.
/// 패키지 없이 직접 그린다.
class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    required this.segments,
    this.size = 120,
    this.strokeWidth = 16,
    this.center,
  });

  final List<DonutSegment> segments;
  final double size;
  final double strokeWidth;
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _DonutPainter(
            segments: segments,
            strokeWidth: strokeWidth,
            track: colors.chip,
          ),
          child: Center(child: center),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.segments,
    required this.strokeWidth,
    required this.track,
  });

  final List<DonutSegment> segments;
  final double strokeWidth;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    final total = segments.fold<double>(0, (a, s) => a + s.value);
    if (total <= 0) {
      canvas.drawArc(rect, 0, math.pi * 2, false, paint..color = track);
      return;
    }
    final gap = segments.where((s) => s.value > 0).length > 1 ? 0.06 : 0.0;
    var start = -math.pi / 2;
    for (final s in segments) {
      if (s.value <= 0) continue;
      final sweep = math.pi * 2 * s.value / total;
      canvas.drawArc(
        rect,
        start + gap / 2,
        math.max(sweep - gap, 0.01),
        false,
        paint..color = s.color,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.segments != segments || old.strokeWidth != strokeWidth;
}
