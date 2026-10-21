import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_assets.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/centered_line.dart';
import '../../models/weekly_emotion_flow.dart';

/// "이번 주 감정 흐름" 그래프 카드 (높이 180). 좌표는 테두리 안쪽 기준(docs/DESIGN_SYSTEM.md 5.5).
/// 폭이 디자인(안쪽 350)과 다르면 가로 좌표만 같은 비율로 늘리고 줄인다.
class WeeklyEmotionCard extends StatelessWidget {
  const WeeklyEmotionCard({super.key, required this.flow});

  final WeeklyEmotionFlow flow;

  static const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  static const _emojiLeft = 212.0;
  static const _emojiTop = 26.0;
  static const _emojiHeight = 22.0;
  static const _barCount = 6;

  // Figma에서 막대·요일 라벨 좌표는 테두리(2px) 바깥 기준이고, 제목·격자·설명은 안쪽 기준이다.
  static const _borderInset = AppSpacing.cardBorderWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard.white(
      height: HomeLayout.graphCardHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final s = constraints.maxWidth / GraphLayout.designInnerWidth;
          return Stack(
            children: [
              Positioned(
                left: 18 * s,
                top: 12,
                child: Row(
                  children: [
                    Text(
                      '이번 주 감정 흐름',
                      style: AppTextStyles.graphTitle.copyWith(
                        color: colors.textBlack,
                      ),
                    ),
                    const SizedBox(width: 2),
                    SvgPicture.asset(AppAssets.chevronGraph),
                  ],
                ),
              ),
              Positioned(
                left: 18 * s,
                top: 40,
                child: CenteredLine(
                  height: 16,
                  child: Text(
                    '✦ ${flow.month}월',
                    style: AppTextStyles.graphMonth.copyWith(
                      color: colors.textStrong,
                    ),
                  ),
                ),
              ),
              for (final y in GraphLayout.gridLineYs)
                Positioned(
                  left: GraphLayout.gridLeft * s,
                  top: y,
                  width: GraphLayout.gridWidth * s,
                  height: 1,
                  child: ColoredBox(color: colors.gridLine),
                ),
              for (var i = 0; i < _barCount; i++)
                if (flow.days[i] != null)
                  Positioned(
                    left: (GraphLayout.barLefts[i] - _borderInset) * s,
                    top:
                        GraphLayout.barBottomY -
                        _borderInset -
                        flow.days[i]! * GraphLayout.maxBarHeight,
                    width: GraphLayout.barWidth * s,
                    height: flow.days[i]! * GraphLayout.maxBarHeight,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.brand,
                        borderRadius: AppRadii.graphBarBorderRadius,
                      ),
                    ),
                  ),
              for (var i = 0; i < _weekdays.length; i++)
                Positioned(
                  left: (GraphLayout.weekdayLabelLefts[i] - _borderInset) * s,
                  top: GraphLayout.weekdayLabelY - _borderInset - 10,
                  child: CenteredLine(
                    height: 20,
                    child: Text(
                      _weekdays[i],
                      style: AppTextStyles.weekday.copyWith(
                        color: colors.textStrong,
                      ),
                    ),
                  ),
                ),
              if (flow.peakEmoji != null)
                Positioned(
                  left: _emojiLeft * s,
                  top: _emojiTop,
                  child: CenteredLine(
                    height: _emojiHeight,
                    child: Text(
                      flow.peakEmoji!,
                      style: AppTextStyles.graphEmoji.copyWith(
                        color: colors.emoji,
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: 18 * s,
                top: GraphLayout.captionY - 12,
                child: CenteredLine(height: 24, child: _caption(colors)),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 설명 문장. 강조 부분만 굵게 + 밑줄.
  Widget _caption(AppColors colors) {
    final base = AppTextStyles.graphCaption.copyWith(
      color: colors.textGraphCaption,
    );
    final emphasis = flow.summaryEmphasis;
    final at = emphasis == null ? -1 : flow.summary.indexOf(emphasis);
    if (at < 0) return Text(flow.summary, style: base);
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: flow.summary.substring(0, at)),
          TextSpan(
            text: emphasis,
            style: AppTextStyles.graphCaptionEmphasis.copyWith(
              color: colors.textGraphCaption,
            ),
          ),
          TextSpan(text: flow.summary.substring(at + emphasis!.length)),
        ],
      ),
    );
  }
}
