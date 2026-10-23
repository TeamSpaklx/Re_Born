import 'package:flutter/material.dart';

import '../../../../app/theme/app_assets.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/centered_line.dart';
import '../../../../shared/widgets/cta_button.dart';

/// 오늘 아직 기록하지 않았을 때의 카드 (Figma `UnWrite` Before 최신 안: 흰색 + 테두리 1px, 높이 268,
/// 버튼 뒤에서 여우원숭이가 얼굴을 내민다, docs/DESIGN_HOME.md 5.2).
class RecordCardBefore extends StatelessWidget {
  const RecordCardBefore({super.key, required this.onRecord});

  final VoidCallback onRecord;

  // 카드 바깥 위쪽 기준: 제목 27, 부제 57, 일러스트 96, 버튼 194(52), 아래 22.
  static const _topToTitle = 27.0;
  static const _titleToSubtitle = 10.0;
  static const _subtitleToMascot = 19.0;
  static const _textLineHeight = 20.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard.outlined(
      height: HomeLayout.recordCardHeightBefore,
      // 테두리 1px 안쪽에서 20 → 바깥 기준 21.
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.recordCardPadding + AppSpacing.cardOutlineWidth,
        _topToTitle,
        AppSpacing.recordCardPadding + AppSpacing.cardOutlineWidth,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CenteredLine(
            height: _textLineHeight,
            child: Text(
              '아직 오늘의 마음을 기록하지 않았어요',
              style: AppTextStyles.recordCardTitleBefore.copyWith(
                color: colors.textBlack,
              ),
            ),
          ),
          const SizedBox(height: _titleToSubtitle),
          CenteredLine(
            height: _textLineHeight,
            child: Text(
              '1분만 천천히 돌아볼까요?',
              style: AppTextStyles.recordCardSubtitle.copyWith(
                color: colors.recordCardSubtitle,
              ),
            ),
          ),
          const SizedBox(height: _subtitleToMascot),
          // 이미지는 정사각이고 아래쪽이 잘려, 버튼 뒤에서 위쪽 98px만 보인다.
          Align(
            child: SizedBox(
              width: HomeLayout.mascotWidth,
              height: HomeLayout.mascotHeight,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.topCenter,
                  minHeight: HomeLayout.mascotImageHeight,
                  maxHeight: HomeLayout.mascotImageHeight,
                  child: Image.asset(
                    AppAssets.mascotLemur,
                    width: HomeLayout.mascotWidth,
                    height: HomeLayout.mascotImageHeight,
                    fit: BoxFit.fill,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
            ),
          ),
          CtaButton(
            label: '감정 기록하기',
            height: HomeLayout.ctaButtonHeightBefore,
            variant: CtaVariant.soft,
            onPressed: onRecord,
          ),
        ],
      ),
    );
  }
}
