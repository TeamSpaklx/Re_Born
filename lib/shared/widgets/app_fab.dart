import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/utils/app_haptics.dart';
import 'pressable.dart';

/// 떠 있는 추가 버튼: 브랜드 핑크 알약 + "+" + 이름. 화면의 주요 행동이 목록 위에 계속 보여야 할 때 쓴다
/// (기록 탭의 "기록하기"). 탭 바 위에 놓는 위치는 [TabPageScaffold]가 정한다.
class AppFab extends StatelessWidget {
  const AppFab({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    void press() {
      AppHaptics.tap();
      onTap();
    }

    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: press,
      child: Pressable(
        onTap: press,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: colors.cta,
            borderRadius: AppRadii.pillBorderRadius,
            boxShadow: AppShadows.floating,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomPaint(
                size: const Size(16, 16),
                painter: _PlusPainter(colors.onCta),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.buttonLarge.copyWith(color: colors.onCta),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlusPainter extends CustomPainter {
  _PlusPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width / 2, 1),
      Offset(size.width / 2, size.height - 1),
      paint,
    );
    canvas.drawLine(
      Offset(1, size.height / 2),
      Offset(size.width - 1, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _PlusPainter old) => old.color != color;
}
