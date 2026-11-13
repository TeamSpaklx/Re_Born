import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/app_assets.dart';

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
              SvgPicture.asset(
                AppAssets.ixAdd,
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(colors.onCta, BlendMode.srcIn),
              ),
              const SizedBox(width: 6),
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
