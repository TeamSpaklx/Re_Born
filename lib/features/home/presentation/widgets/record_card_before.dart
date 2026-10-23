import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/centered_line.dart';
import '../../../../shared/widgets/cta_button.dart';

/// 오늘 아직 기록하지 않았을 때의 카드 (Figma `UnWrite` Before 수정안: 흰색 + 테두리 1px, 높이 172).
class RecordCardBefore extends StatelessWidget {
  const RecordCardBefore({super.key, required this.onRecord});

  final VoidCallback onRecord;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard.outlined(
      height: HomeLayout.recordCardHeightBefore,
      // 위 1px 빈 줄, 아래 21 (docs/DESIGN_SYSTEM.md 5.2).
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.recordCardPadding,
        1,
        AppSpacing.recordCardPadding,
        21,
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  child: CenteredLine(
                    height: 20,
                    child: Text(
                      '아직 오늘의 마음을 기록하지 않았어요',
                      style: AppTextStyles.recordCardTitleBefore.copyWith(
                        color: colors.textBlack,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 30,
                  child: CenteredLine(
                    height: 20,
                    child: Text(
                      '1분만 천천히 돌아볼까요?',
                      style: AppTextStyles.recordCardSubtitle.copyWith(
                        color: colors.recordCardSubtitle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          CtaButton(
            label: '감정 기록하기',
            height: HomeLayout.ctaButtonHeightBefore,
            soft: true,
            onPressed: onRecord,
          ),
        ],
      ),
    );
  }
}
