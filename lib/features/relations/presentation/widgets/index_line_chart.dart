import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/dates.dart';
import '../../../insights/models/index_point.dart';

/// 관계 지수(0~100) 선 그래프 (SPEC F-09). 패키지 없이 직접 그린다. **임시 디자인**.
/// 점이 1개면 가운데 한 점만, 여러 개면 날짜 간격에 맞춰 선으로 잇는다.
class IndexLineChart extends StatelessWidget {
  const IndexLineChart({super.key, required this.points});

  /// 날짜 오름차순, 1개 이상.
  final List<IndexPoint> points;

  static const height = 180.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _ChartPainter(
          points: points,
          line: colors.brand,
          grid: colors.gridLine,
          label: colors.textSecondary,
          background: colors.cardWhite,
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({
    required this.points,
    required this.line,
    required this.grid,
    required this.label,
    required this.background,
  });

  final List<IndexPoint> points;
  final Color line;
  final Color grid;
  final Color label;
  final Color background;

  static const _left = 28.0;
  static const _right = 8.0;
  static const _top = 12.0;
  static const _bottom = 24.0;

  @override
  void paint(Canvas canvas, Size size) {
    final plot = Rect.fromLTRB(
      _left,
      _top,
      size.width - _right,
      size.height - _bottom,
    );
    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (final v in [0, 50, 100]) {
      final y = plot.bottom - plot.height * v / 100;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), gridPaint);
      _text(canvas, '$v', Offset(0, y - 6), label, 10);
    }

    if (points.isEmpty) return;
    final first = points.first.date;
    final span = daysBetween(first, points.last.date);

    Offset at(IndexPoint p) {
      final x = span == 0
          ? plot.center.dx
          : plot.left + plot.width * daysBetween(first, p.date) / span;
      final y = plot.bottom - plot.height * p.index / 100;
      return Offset(x, y);
    }

    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final o = at(points[i]);
      i == 0 ? path.moveTo(o.dx, o.dy) : path.lineTo(o.dx, o.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    if (points.length <= 31) {
      for (final p in points) {
        canvas.drawCircle(at(p), 4, Paint()..color = background);
        canvas.drawCircle(
          at(p),
          3,
          Paint()
            ..color = line
            ..style = PaintingStyle.fill,
        );
      }
    }

    _text(
      canvas,
      '${points.first.date.month}/${points.first.date.day}',
      Offset(plot.left - 8, size.height - 16),
      label,
      10,
    );
    final lastText = '${points.last.date.month}/${points.last.date.day}';
    _text(
      canvas,
      lastText,
      Offset(plot.right - 22, size.height - 16),
      label,
      10,
    );
  }

  void _text(
    Canvas canvas,
    String text,
    Offset offset,
    Color color,
    double size,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: AppTextStyles.caption.copyWith(color: color, fontSize: size),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) =>
      old.points != points || old.line != line;
}
