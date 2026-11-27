import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/utils/dates.dart';

/// 선 그래프의 점 하나(날짜별 값).
class ChartPoint {
  const ChartPoint(this.date, this.value);

  final DateTime date;
  final double value;
}

/// 감정 수치 곡선 그래프 (SPEC F-09). 패키지 없이 직접 그린다.
/// 세로축은 [min]~[max]이고 가운데(0)에 기준선을 긋는다. 점이 1개면 가운데 한 점만,
/// 여러 개면 날짜 간격에 맞춰 부드러운 곡선으로 잇고 선 아래를 옅게 채운다.
/// 마지막 점은 크게 그리고 값을 위에 적는다.
class EmotionLineChart extends StatelessWidget {
  const EmotionLineChart({
    super.key,
    required this.points,
    this.min = -5,
    this.max = 5,
  });

  /// 날짜 오름차순, 1개 이상.
  final List<ChartPoint> points;
  final double min;
  final double max;

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
          min: min,
          max: max,
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
    required this.min,
    required this.max,
    required this.line,
    required this.grid,
    required this.label,
    required this.background,
  });

  final List<ChartPoint> points;
  final double min;
  final double max;
  final Color line;
  final Color grid;
  final Color label;
  final Color background;

  static const _left = 28.0;
  static const _right = 12.0;
  static const _top = 24.0;
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
    double yOf(double v) => plot.bottom - plot.height * (v - min) / (max - min);
    for (final v in [max, (min + max) / 2, min]) {
      final y = yOf(v);
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), gridPaint);
      _text(canvas, _format(v), Offset(0, y - 6), label, 10);
    }

    if (points.isEmpty) return;
    final first = points.first.date;
    final span = daysBetween(first, points.last.date);

    Offset at(ChartPoint p) {
      final x = span == 0
          ? plot.center.dx
          : plot.left + plot.width * daysBetween(first, p.date) / span;
      return Offset(x, yOf(p.value.clamp(min, max)));
    }

    final offsets = [for (final p in points) at(p)];

    // 곡선: 이웃 점의 가운데 x를 조절점으로 쓰는 수평 접선 베지어(꺾이지 않고 값을 넘지 않는다).
    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (var i = 1; i < offsets.length; i++) {
      final a = offsets[i - 1];
      final b = offsets[i];
      final mid = (a.dx + b.dx) / 2;
      path.cubicTo(mid, a.dy, mid, b.dy, b.dx, b.dy);
    }

    if (offsets.length > 1) {
      final area = Path.from(path)
        ..lineTo(offsets.last.dx, plot.bottom)
        ..lineTo(offsets.first.dx, plot.bottom)
        ..close();
      canvas.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [line.withValues(alpha: 0.22), line.withValues(alpha: 0)],
          ).createShader(plot),
      );
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

    if (points.length <= 14) {
      for (final o in offsets) {
        canvas.drawCircle(o, 4, Paint()..color = background);
        canvas.drawCircle(o, 2.5, Paint()..color = line);
      }
    }
    final end = offsets.last;
    canvas.drawCircle(end, 6, Paint()..color = line.withValues(alpha: 0.25));
    canvas.drawCircle(end, 4.5, Paint()..color = line);
    canvas.drawCircle(end, 2, Paint()..color = background);
    final valueText = _format(points.last.value);
    final tp = _layout(valueText, line, 12, FontWeight.w700);
    tp.paint(
      canvas,
      Offset(
        (end.dx - tp.width / 2).clamp(0, size.width - tp.width),
        end.dy - 22,
      ),
    );

    _text(
      canvas,
      '${points.first.date.month}/${points.first.date.day}',
      Offset(plot.left - 8, size.height - 16),
      label,
      10,
    );
    if (points.length > 1) {
      final lastText = '${points.last.date.month}/${points.last.date.day}';
      _text(
        canvas,
        lastText,
        Offset(plot.right - 22, size.height - 16),
        label,
        10,
      );
    }
  }

  /// 소수 한 자리까지, 양수는 +를 붙인다(0은 그대로).
  static String _format(double v) {
    final text = v == v.roundToDouble()
        ? v.toStringAsFixed(0)
        : v.toStringAsFixed(1);
    return v > 0 ? '+$text' : text;
  }

  TextPainter _layout(
    String text,
    Color color,
    double size, [
    FontWeight weight = FontWeight.w400,
  ]) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontSize: size,
          fontWeight: weight,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  void _text(
    Canvas canvas,
    String text,
    Offset offset,
    Color color,
    double size,
  ) {
    _layout(text, color, size).paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) =>
      old.points != points ||
      old.line != line ||
      old.min != min ||
      old.max != max;
}
