import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_assets.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/centered_line.dart';
import '../../../../shared/widgets/pressable.dart';
import '../../models/weekly_emotion_flow.dart';

/// "이번 주 감정 흐름" 그래프 카드 (높이 180). 좌표는 테두리 안쪽 기준(docs/DESIGN_HOME.md 5.5).
/// 폭이 디자인(안쪽 350)과 다르면 가로 좌표만 같은 비율로 늘리고 줄인다.
class WeeklyEmotionCard extends StatelessWidget {
  const WeeklyEmotionCard({super.key, required this.flow, this.onTitleTap});

  final WeeklyEmotionFlow flow;

  /// 제목("이번 주 감정 흐름 >")을 눌렀을 때. 터치 영역은 높이 44.
  final VoidCallback? onTitleTap;

  static const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  static const _barCount = 6;

  /// 막대 색: 값이 낮을수록 진하고 높을수록 연하다(구간은 [GraphLayout.barStrongMax]·[GraphLayout.barMidMax]).
  static Color barColor(double value, AppColors colors) {
    if (value <= GraphLayout.barStrongMax) return colors.barStrong;
    if (value <= GraphLayout.barMidMax) return colors.barMid;
    return colors.barLight;
  }

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
                left: 18 * s - 8,
                top: -2,
                child: Semantics(
                  button: onTitleTap != null,
                  label: '이번 주 감정 흐름, 기록 보기',
                  excludeSemantics: true,
                  onTap: onTitleTap,
                  child: Pressable(
                    onTap: onTitleTap,
                    child: SizedBox(
                      height: 44,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
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
                    ),
                  ),
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
              // 수정안은 막대가 서는 바닥선 하나만 보인다(위쪽 격자선 3개는 Figma에서 숨김).
              Positioned(
                left: GraphLayout.gridLeft * s,
                top: GraphLayout.baselineY,
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
                        color: barColor(flow.days[i]!, colors),
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
