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
  const ActionSuggestionCard({
    super.key,
    required this.suggestion,
    required this.onTap,
    required this.onAdd,
  });

  final ActionSuggestion suggestion;

  /// 카드를 누르면 인사이트 상세로.
  final VoidCallback onTap;

  /// 오른쪽 원을 누르면 체크리스트에 담는다(이미 담았으면 눌러도 그대로).
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AppCard.white(
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
            Semantics(
              button: true,
              checked: suggestion.added,
              label: '체크리스트에 담기',
              excludeSemantics: true,
              onTap: onAdd,
              child: GestureDetector(
                key: const Key('suggestion-add'),
                behavior: HitTestBehavior.opaque,
                onTap: onAdd,
                child: SizedBox(
                  width: 36,
                  height: 44,
                  child: Center(
                    child: suggestion.added
                        ? Container(
                            width: HomeLayout.radioSize,
                            height: HomeLayout.radioSize,
                            decoration: BoxDecoration(
                              color: colors.brand,
                              shape: BoxShape.circle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: SvgPicture.asset(
                                AppAssets.check,
                                colorFilter: ColorFilter.mode(
                                  colors.onCta,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          )
                        : SvgPicture.asset(AppAssets.radioCircle),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
