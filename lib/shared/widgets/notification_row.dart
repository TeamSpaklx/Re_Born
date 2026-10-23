import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import 'pressable.dart';

/// 알림 한 줄: 아이콘 타일 + 제목 + 본문 + 시간. 읽지 않은 알림은 연한 핑크 배경과 점으로 강조한다.
class NotificationRow extends StatelessWidget {
  const NotificationRow({
    super.key,
    required this.iconAsset,
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.unread,
    required this.onTap,
  });

  final String iconAsset;
  final String title;
  final String body;
  final String timeLabel;
  final bool unread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: '${unread ? '읽지 않음, ' : ''}$title, $body, $timeLabel',
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space16,
            vertical: AppSpacing.space16,
          ),
          decoration: BoxDecoration(
            color: unread ? colors.cardPink : colors.cardWhite,
            borderRadius: BorderRadius.circular(AppRadii.card - 8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: unread ? colors.cardWhite : colors.iconTile,
                  borderRadius: BorderRadius.circular(AppRadii.iconTile),
                ),
                child: Center(
                  child: SvgPicture.asset(iconAsset, width: 26, height: 26),
                ),
              ),
              const SizedBox(width: AppSpacing.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.rowTitle.copyWith(
                        color: colors.textBlack,
                        fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      body,
                      style: AppTextStyles.body.copyWith(
                        color: colors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space8),
                    Text(
                      timeLabel,
                      style: AppTextStyles.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (unread)
                Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.space8,
                    top: AppSpacing.space4,
                  ),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors.brand,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
