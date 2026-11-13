import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/app_assets.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_card.dart';
import 'app_toggle.dart';
import 'pressable.dart';

/// 설정 목록 묶음: 흰 둥근 카드 하나에 행들을 모은다. 선택적으로 굵은 제목이 맨 위에 온다.
/// Figma에 없어서 토스 설정 화면의 구조(둥근 카드로 묶은 목록)를 참고해 만든 추정 디자인.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, this.title, required this.children});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard.white(
      padding: const EdgeInsets.symmetric(
        horizontal: ComponentLayout.settingsGroupPaddingH,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            SizedBox(
              height: ComponentLayout.settingsGroupTitleHeight,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title!,
                  style: AppTextStyles.groupTitle.copyWith(
                    color: colors.textBlack,
                  ),
                ),
              ),
            ),
          ...children,
        ],
      ),
    );
  }
}

/// 설정 행 하나(높이 56). 오른쪽 끝에 토글([SettingsRow.toggle]), 값과 화살표([SettingsRow.link]),
/// 또는 아무것도 없는 위험 동작 행([SettingsRow.destructive])을 둔다.
class SettingsRow extends StatelessWidget {
  const SettingsRow.toggle({
    super.key,
    required this.title,
    required bool this.value,
    required ValueChanged<bool> this.onChanged,
  }) : onTap = null,
       trailingText = null,
       destructive = false;

  const SettingsRow.link({
    super.key,
    required this.title,
    required VoidCallback this.onTap,
    this.trailingText,
  }) : value = null,
       onChanged = null,
       destructive = false;

  const SettingsRow.destructive({
    super.key,
    required this.title,
    required VoidCallback this.onTap,
  }) : value = null,
       onChanged = null,
       trailingText = null,
       destructive = true;

  final String title;
  final bool? value;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onTap;
  final String? trailingText;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final titleStyle = AppTextStyles.rowTitle.copyWith(
      color: destructive ? colors.danger : colors.textBlack,
    );

    final row = SizedBox(
      height: ComponentLayout.settingsRowHeight,
      child: Row(
        children: [
          Expanded(child: Text(title, style: titleStyle)),
          if (value != null)
            AppToggle(value: value!, onChanged: onChanged)
          else if (!destructive) ...[
            if (trailingText != null) ...[
              Text(
                trailingText!,
                style: AppTextStyles.rowTitle.copyWith(color: colors.brand),
              ),
              const SizedBox(width: 6),
            ],
            SvgPicture.asset(AppAssets.chevronSignal),
          ],
        ],
      ),
    );

    if (value != null) return row;
    return Semantics(
      button: true,
      label: title,
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(onTap: onTap, child: row),
    );
  }
}
