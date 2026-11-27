import 'package:flutter/material.dart';

import '../../app/theme/app_assets.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_card.dart';
import 'app_toggle.dart';
import 'pressable.dart';
import 'tinted_svg.dart';

/// 설정 목록 묶음: 흰 둥근 카드 하나에 행들을 모으고, 행 사이에 얇은 구분선을 넣는다.
/// [title]이 있으면 카드 **밖** 위에 회색 작은 소제목으로 붙는다.
/// 행에 아이콘이 있으면 구분선은 아이콘 아래를 비우고 글자 시작점부터 그린다.
/// Figma에 없어서 토스·레퍼런스 설정 화면의 구조(소제목 + 아이콘 목록 카드)를 참고한 추정 디자인.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, this.title, required this.children});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasIcons = children.whereType<SettingsRow>().any(
      (r) => r.iconAsset != null,
    );
    final indent = hasIcons
        ? ComponentLayout.settingsIconSize + ComponentLayout.settingsIconGap
        : 0.0;
    final card = AppCard.white(
      padding: const EdgeInsets.symmetric(
        horizontal: ComponentLayout.settingsGroupPaddingH,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Padding(
                padding: EdgeInsets.only(left: indent),
                child: Container(
                  height: ComponentLayout.settingsDividerWidth,
                  color: colors.cardBorder,
                ),
              ),
            children[i],
          ],
        ],
      ),
    );
    if (title == null) return card;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsGroupHeader(title: title!),
        card,
      ],
    );
  }
}

/// 설정 카드 위 회색 작은 소제목(아래 간격 포함). [SettingsGroup.title]이 쓰고,
/// 안내 카드처럼 [SettingsGroup]이 아닌 카드 위에도 단독으로 쓴다.
class SettingsGroupHeader extends StatelessWidget {
  const SettingsGroupHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space4,
        0,
        AppSpacing.space4,
        ComponentLayout.settingsGroupTitleGap,
      ),
      child: Semantics(
        header: true,
        child: Text(
          title,
          style: AppTextStyles.sectionLabel.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// 설정 행 하나(높이 60). 왼쪽에 선택적 아이콘([iconAsset], 24)을 두고, 꺾쇠까지 모두 Iconsax(Linear)로 맞춘다.
///
/// 오른쪽 끝에 토글([SettingsRow.toggle]), 값과 화살표([SettingsRow.link]),
/// 또는 아무것도 없는 위험 동작 행([SettingsRow.destructive], 빨강)을 둔다.
class SettingsRow extends StatelessWidget {
  const SettingsRow.toggle({
    super.key,
    required this.title,
    required bool this.value,
    required ValueChanged<bool> this.onChanged,
    this.iconAsset,
  }) : onTap = null,
       trailingText = null,
       trailingEmphasis = false,
       destructive = false;

  const SettingsRow.link({
    super.key,
    required this.title,
    required VoidCallback this.onTap,
    this.trailingText,
    this.trailingEmphasis = false,
    this.iconAsset,
  }) : value = null,
       onChanged = null,
       destructive = false;

  const SettingsRow.destructive({
    super.key,
    required this.title,
    required VoidCallback this.onTap,
    this.iconAsset,
  }) : value = null,
       onChanged = null,
       trailingText = null,
       trailingEmphasis = false,
       destructive = true;

  final String title;
  final bool? value;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onTap;

  /// 화살표 앞 값(예: "한국어"). 기본은 회색이고, [trailingEmphasis]면 브랜드색(예: 안 읽은 알림 수).
  final String? trailingText;
  final bool trailingEmphasis;
  final bool destructive;

  /// 왼쪽 아이콘(한 가지 색 SVG). 글자와 같은 색으로 칠한다.
  final String? iconAsset;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final foreground = destructive ? colors.danger : colors.textBlack;
    final titleStyle = AppTextStyles.rowTitle.copyWith(color: foreground);

    final row = SizedBox(
      height: ComponentLayout.settingsRowHeight,
      child: Row(
        children: [
          if (iconAsset != null) ...[
            TintedSvg(
              iconAsset!,
              color: foreground,
              width: ComponentLayout.settingsIconSize,
              height: ComponentLayout.settingsIconSize,
            ),
            const SizedBox(width: ComponentLayout.settingsIconGap),
          ],
          Expanded(child: Text(title, style: titleStyle)),
          if (value != null)
            AppToggle(value: value!, onChanged: onChanged)
          else if (!destructive) ...[
            if (trailingText != null) ...[
              Text(
                trailingText!,
                style: AppTextStyles.rowTitle.copyWith(
                  color: trailingEmphasis ? colors.brand : colors.textSecondary,
                ),
              ),
              const SizedBox(width: 6),
            ],
            TintedSvg(
              AppAssets.ixArrowRight,
              color: colors.iconMuted,
              width: ComponentLayout.settingsChevronSize,
              height: ComponentLayout.settingsChevronSize,
            ),
          ],
        ],
      ),
    );

    if (value != null) return row;
    return Semantics(
      button: true,
      label: trailingText == null ? title : '$title, $trailingText',
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(onTap: onTap, child: row),
    );
  }
}

/// 설정 그룹 맨 위의 안내 카드: 아이콘(브랜드색) + 제목 + 회색 설명 + 화살표.
/// 누르면 자세한 설명을 연다(예: "기록은 이 기기 안에서만 분석해요").
class SettingsInfoCard extends StatelessWidget {
  const SettingsInfoCard({
    super.key,
    required this.iconAsset,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final String iconAsset;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: '$title. $description',
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: AppCard.white(
          padding: const EdgeInsets.all(ComponentLayout.settingsInfoPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TintedSvg(
                iconAsset,
                color: colors.brand,
                width: ComponentLayout.settingsIconSize,
                height: ComponentLayout.settingsIconSize,
              ),
              const SizedBox(width: ComponentLayout.settingsIconGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.groupTitle.copyWith(
                        color: colors.textBlack,
                      ),
                    ),
                    const SizedBox(height: ComponentLayout.settingsInfoTextGap),
                    Text(
                      description,
                      style: AppTextStyles.caption.copyWith(
                        color: colors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.space8),
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.space12),
                child: TintedSvg(
                  AppAssets.ixArrowRight,
                  color: colors.iconMuted,
                  width: ComponentLayout.settingsChevronSize,
                  height: ComponentLayout.settingsChevronSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
