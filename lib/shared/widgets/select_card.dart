import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_motion.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/utils/app_haptics.dart';

/// 선택 카드: 제목 + 설명을 담은 큰 카드를 세로로 쌓아 하나를 고르게 한다(온보딩 질문 답, 관계 유형 선택).
/// 선택되면 연한 핑크 배경과 브랜드 핑크 테두리가 된다.
class SelectCard extends StatelessWidget {
  const SelectCard({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.description,
  });

  final String title;
  final String? description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: description == null ? title : '$title, $description',
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          AppHaptics.selection();
          onTap();
        },
        child: AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.enter,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space20,
            vertical: AppSpacing.space16,
          ),
          decoration: BoxDecoration(
            color: selected ? colors.cardPink : colors.cardWhite,
            borderRadius: BorderRadius.circular(AppRadii.card - 8),
            border: Border.all(
              color: selected ? colors.brand : colors.cardBorder,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.groupTitle.copyWith(
                  color: colors.textBlack,
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: AppSpacing.space4),
                Text(
                  description!,
                  style: AppTextStyles.body.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
