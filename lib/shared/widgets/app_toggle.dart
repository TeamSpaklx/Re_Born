import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/utils/app_haptics.dart';

/// Reborn 토글: iOS식 알약 모양(흰 동그라미가 움직임). 켜짐은 브랜드 핑크, 꺼짐은 연한 회색 핑크.
/// 머티리얼 `Switch`를 대신한다. 눈에 보이는 크기는 51×31이고, 누르는 영역은 최소 44이다.
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
                color: value ? colors.brand : colors.toggleOff,
                borderRadius: BorderRadius.circular(
                  ComponentLayout.toggleHeight / 2,
                ),
              ),
              child: Container(
                width: ComponentLayout.toggleThumb,
                height: ComponentLayout.toggleThumb,
                decoration: BoxDecoration(
                  color: colors.cardWhite,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colors.navShadow,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
