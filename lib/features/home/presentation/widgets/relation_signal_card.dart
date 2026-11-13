import 'package:flutter/material.dart';
import '../../../../shared/widgets/character_avatar.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_assets.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/centered_line.dart';
import '../../models/relation_signal.dart';

/// "최근 관계 신호" 카드 하나 (높이 104). 좌표는 테두리 안쪽 기준(docs/DESIGN_HOME.md 5.4).
class RelationSignalCard extends StatelessWidget {
  const RelationSignalCard({
    super.key,
    required this.signal,
    required this.onTap,
  });

  final RelationSignal signal;

  /// 카드를 누르면 그 인사이트 상세로.
  final VoidCallback onTap;

  static const _textLeft = 85.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AppCard.white(
        height: HomeLayout.signalCardHeight,
        child: Stack(
          children: [
            Positioned(
              left: 18,
              top: 26,
              width: HomeLayout.avatarSize,
              height: HomeLayout.avatarSize,
              child: CharacterAvatar(
                seed: signal.personId,
                size: HomeLayout.avatarSize,
              ),
            ),
            Positioned(
              left: _textLeft,
              top: 18,
              child: Text(
                signal.personName,
                style: AppTextStyles.sectionTitle.copyWith(
                  color: colors.textBlack,
                ),
              ),
            ),
            // 칩은 이름 글자 폭과 상관없이 이름 왼쪽에서 41 떨어진 자리(Figma)에 둔다.
            Positioned(
              left: _textLeft + 41,
              top: 23,
              width: 38,
              height: 22,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.chip,
                  borderRadius: AppRadii.pillBorderRadius,
                ),
                child: Center(
                  child: CenteredLine(
                    height: 22,
                    alignment: Alignment.center,
                    child: Text(
                      signal.relationType.label,
                      style: AppTextStyles.chipLabel.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: _textLeft,
              top: 49,
              child: CenteredLine(
                height: 16,
                child: Text(
                  signal.message,
                  style: AppTextStyles.signalText.copyWith(
                    color: colors.textStrong,
                  ),
                ),
              ),
            ),
            Positioned(
              left: _textLeft,
              top: 64,
              child: CenteredLine(
                height: 24,
                child: Text(
                  '마지막 기록 ${signal.daysSinceLastRecord}일 전',
                  style: AppTextStyles.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 18,
              top: 40,
              child: SvgPicture.asset(AppAssets.chevronSignal),
            ),
          ],
        ),
      ),
    );
  }
}
