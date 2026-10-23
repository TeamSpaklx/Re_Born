import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../models/emotion.dart';
import 'emotion_chip.dart';

/// 감정 캐릭터 자리 표시: 감정 대표색 원 + 간단한 표정. 정식 캐릭터 에셋이 오면 이 위젯의 안쪽만
/// 이미지로 바꾸면 달력·선택 격자·목록이 모두 따라온다 (docs/DESIGN_SYSTEM.md 6장).
/// 장식이므로 스크린 리더는 읽지 않는다(감정 이름은 옆 글자가 읽는다).
class EmotionFace extends StatelessWidget {
  const EmotionFace({super.key, required this.emotion, this.size = 40});

  final Emotion emotion;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _FacePainter(
            emotion: emotion,
            fill: emotionColor(emotion, colors),
            ink: colors.textStrong,
            blush: colors.brand.withValues(alpha: 0.35),
            tear: colors.emotionHurt,
          ),
        ),
      ),
    );
  }
}

class _FacePainter extends CustomPainter {
  _FacePainter({
    required this.emotion,
    required this.fill,
    required this.ink,
    required this.blush,
    required this.tear,
  });

  final Emotion emotion;
  final Color fill;
  final Color ink;
  final Color blush;
  final Color tear;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    canvas.drawCircle(Offset(s / 2, s / 2), s / 2, Paint()..color = fill);

    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.055
      ..strokeCap = StrokeCap.round;
    final solid = Paint()..color = ink;

    final leftEye = Offset(s * 0.34, s * 0.44);
    final rightEye = Offset(s * 0.66, s * 0.44);
    final eyeR = s * 0.05;

    void dots([double scale = 1]) {
      canvas.drawCircle(leftEye, eyeR * scale, solid);
      canvas.drawCircle(rightEye, eyeR * scale, solid);
    }

    void arcEye(Offset c, {required bool up}) {
      final rect = Rect.fromCenter(
        center: c,
        width: s * 0.16,
        height: s * 0.16,
      );
      canvas.drawArc(rect, up ? math.pi : 0, math.pi, false, stroke);
    }

    void smile(double width, double depth, {double y = 0.62}) {
      final path = Path()
        ..moveTo(s * (0.5 - width / 2), s * y)
        ..quadraticBezierTo(
          s * 0.5,
          s * (y + depth),
          s * (0.5 + width / 2),
          s * y,
        );
      canvas.drawPath(path, stroke);
    }

    void frown(double width, double depth, {double y = 0.7}) {
      final path = Path()
        ..moveTo(s * (0.5 - width / 2), s * y)
        ..quadraticBezierTo(
          s * 0.5,
          s * (y - depth),
          s * (0.5 + width / 2),
          s * y,
        );
      canvas.drawPath(path, stroke);
    }

    switch (emotion) {
      case Emotion.joy:
        dots();
        smile(0.34, 0.26);
      case Emotion.gratitude:
        arcEye(leftEye, up: true);
        arcEye(rightEye, up: true);
        smile(0.22, 0.16, y: 0.63);
        canvas.drawCircle(
          Offset(s * 0.22, s * 0.58),
          s * 0.06,
          Paint()..color = blush,
        );
        canvas.drawCircle(
          Offset(s * 0.78, s * 0.58),
          s * 0.06,
          Paint()..color = blush,
        );
      case Emotion.excitement:
        dots(1.3);
        final mouth = Path()
          ..moveTo(s * 0.36, s * 0.6)
          ..quadraticBezierTo(s * 0.5, s * 0.86, s * 0.64, s * 0.6)
          ..close();
        canvas.drawPath(mouth, solid);
      case Emotion.calm:
        arcEye(leftEye, up: false);
        arcEye(rightEye, up: false);
        smile(0.18, 0.1, y: 0.64);
      case Emotion.hurt:
        dots();
        canvas.drawLine(
          Offset(s * 0.26, s * 0.33),
          Offset(s * 0.4, s * 0.36),
          stroke,
        );
        canvas.drawLine(
          Offset(s * 0.74, s * 0.33),
          Offset(s * 0.6, s * 0.36),
          stroke,
        );
        frown(0.2, 0.1, y: 0.68);
      case Emotion.anxiety:
        dots(1.2);
        final wave = Path()
          ..moveTo(s * 0.36, s * 0.66)
          ..quadraticBezierTo(s * 0.42, s * 0.6, s * 0.48, s * 0.66)
          ..quadraticBezierTo(s * 0.54, s * 0.72, s * 0.6, s * 0.66);
        canvas.drawPath(wave, stroke);
        canvas.drawCircle(
          Offset(s * 0.82, s * 0.3),
          s * 0.04,
          Paint()..color = tear,
        );
      case Emotion.anger:
        dots();
        canvas.drawLine(
          Offset(s * 0.26, s * 0.35),
          Offset(s * 0.4, s * 0.32),
          stroke,
        );
        canvas.drawLine(
          Offset(s * 0.74, s * 0.35),
          Offset(s * 0.6, s * 0.32),
          stroke,
        );
        frown(0.24, 0.12, y: 0.7);
      case Emotion.sadness:
        dots();
        frown(0.2, 0.12, y: 0.7);
        final drop = Path()
          ..moveTo(s * 0.34, s * 0.54)
          ..quadraticBezierTo(s * 0.28, s * 0.64, s * 0.34, s * 0.68)
          ..quadraticBezierTo(s * 0.4, s * 0.64, s * 0.34, s * 0.54);
        canvas.drawPath(drop, Paint()..color = tear);
    }
  }

  @override
  bool shouldRepaint(covariant _FacePainter old) =>
      old.emotion != emotion || old.fill != fill || old.ink != ink;
}
