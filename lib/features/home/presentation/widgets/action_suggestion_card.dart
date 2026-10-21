import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_assets.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/centered_line.dart';
import '../../models/action_suggestion.dart';

/// "오늘 해볼까요?" 카드 하나 (높이 90, docs/DESIGN_SYSTEM.md 5.6).
class ActionSuggestionCard extends StatelessWidget {
  const ActionSuggestionCard({super.key, required this.suggestion});

  final ActionSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard.white(
      height: HomeLayout.actionCardHeight,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Container(
            width: HomeLayout.iconTileSize,
            height: HomeLayout.iconTileSize,
            decoration: BoxDecoration(
              color: colors.iconTile,
              borderRadius: BorderRadius.circular(AppRadii.iconTile),
            ),
            child: Center(
              child: SvgPicture.asset(
                AppAssets.forum,
                width: HomeLayout.forumIconSize,
                height: HomeLayout.forumIconSize,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.actionTitle.copyWith(
                    color: colors.textBlack,
                  ),
                ),
                CenteredLine(
                  height: 16,
                  child: Text(
                    suggestion.reason,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.signalText.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SvgPicture.asset(AppAssets.radioCircle),
        ],
      ),
    );
  }
}
