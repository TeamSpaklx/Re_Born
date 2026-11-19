import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/utils/app_haptics.dart';

/// Reborn 토글 (Figma `834:1399`): 64×28 알약 안에서 흰 손잡이(38×24)가 좌우로 움직인다.
/// 켜짐은 연분홍 #FFAFC7, 꺼짐은 회색 30%. iOS·Android 모두 같은 모양이다.
/// 머티리얼 `Switch`를 대신한다. 누르는 영역은 최소 44이다.
class AppToggle extends StatelessWidget {
  const AppToggle({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onChanged != null;
    void toggle() {
      AppHaptics.selection();
      onChanged!(!value);
    }

    return Semantics(
      toggled: value,
      enabled: enabled,
      onTap: enabled ? toggle : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? toggle : null,
        child: SizedBox(
          width: ComponentLayout.toggleWidth,
          height: ComponentLayout.toggleMinHit,
          child: Center(
            child: AnimatedContainer(
              duration: ComponentLayout.toggleDuration,
              curve: Curves.easeOut,
              width: ComponentLayout.toggleWidth,
              height: ComponentLayout.toggleHeight,
              padding: const EdgeInsets.all(ComponentLayout.toggleThumbInset),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              decoration: BoxDecoration(
                color: value ? colors.toggleOn : colors.toggleOff,
                borderRadius: AppRadii.pillBorderRadius,
              ),
              child: Container(
                width: ComponentLayout.toggleThumbWidth,
                height: ComponentLayout.toggleThumbHeight,
                decoration: BoxDecoration(
                  color: colors.cardWhite,
                  borderRadius: AppRadii.pillBorderRadius,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
