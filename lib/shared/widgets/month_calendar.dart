import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/app_assets.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_motion.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/utils/app_haptics.dart';
import '../../core/utils/dates.dart';

/// 월 달력: 위에 "2026년 10월"과 이전·다음 달 버튼, 요일 줄, 날짜 격자. 날짜 아래에 [markerFor]가 돌려주는
/// 작은 표시(감정 캐릭터 등)를 놓는다. 선택한 날은 브랜드 핑크 원, 오늘은 핑크 글자.
/// (docs/DESIGN_SYSTEM.md 7.6, 기록 탭)
class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    super.key,
    required this.month,
    required this.selected,
    required this.today,
    required this.onSelected,
    required this.onMonthChanged,
    this.markerFor,
  });

  /// 보여 줄 달(아무 날짜나 넣으면 그 달).
  final DateTime month;
  final DateTime selected;
  final DateTime today;
  final ValueChanged<DateTime> onSelected;
  final ValueChanged<DateTime> onMonthChanged;
  final Widget? Function(DateTime day)? markerFor;

  static const _weekdays = ['일', '월', '화', '수', '목', '금', '토'];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final first = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = first.weekday % 7; // 일요일 시작.
    final rows = ((leading + daysInMonth) / 7).ceil();
    final canGoNext = DateTime(
      month.year,
      month.month + 1,
    ).isBefore(DateTime(today.year, today.month + 1));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _MonthButton(
              label: '이전 달',
              flipped: true,
              onTap: () =>
                  onMonthChanged(DateTime(month.year, month.month - 1)),
            ),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  '${month.year}년 ${month.month}월',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: colors.textBlack,
                  ),
                ),
              ),
            ),
            _MonthButton(
              label: '다음 달',
              enabled: canGoNext,
              onTap: () =>
                  onMonthChanged(DateTime(month.year, month.month + 1)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space8),
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: SizedBox(
                  height: 28,
                  child: Center(
                    child: Text(
                      _weekdays[i],
                      style: AppTextStyles.body.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        for (var r = 0; r < rows; r++)
          Row(
            children: [
              for (var c = 0; c < 7; c++)
                Expanded(
                  child: _cell(context, r * 7 + c - leading + 1, daysInMonth),
                ),
            ],
          ),
      ],
    );
  }

  Widget _cell(BuildContext context, int day, int daysInMonth) {
    const height = 58.0;
    if (day < 1 || day > daysInMonth) return const SizedBox(height: height);
    final colors = context.colors;
    final date = DateTime(month.year, month.month, day);
    final isSelected = dateOnly(date) == dateOnly(selected);
    final isToday = dateOnly(date) == dateOnly(today);
    final isFuture = date.isAfter(dateOnly(today));
    final marker = markerFor?.call(date);

    return Semantics(
      button: true,
      selected: isSelected,
      label: '${date.month}월 $day일${isToday ? ', 오늘' : ''}',
      excludeSemantics: true,
      onTap: isFuture ? null : () => onSelected(date),
      child: GestureDetector(
        key: Key('day-${date.year}-${date.month}-$day'),
        behavior: HitTestBehavior.opaque,
        onTap: isFuture
            ? null
            : () {
                AppHaptics.selection();
                onSelected(date);
              },
        child: SizedBox(
          height: height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: AppMotion.fast,
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? colors.brand : Colors.transparent,
                ),
                child: Text(
                  '$day',
                  style: AppTextStyles.body.copyWith(
                    color: isSelected
                        ? colors.onCta
                        : isFuture
                        ? colors.textSecondary.withValues(alpha: 0.4)
                        : isToday
                        ? colors.brand
                        : colors.textBlack,
                    fontWeight: isToday || isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(height: 20, child: marker),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthButton extends StatelessWidget {
  const _MonthButton({
    required this.label,
    required this.onTap,
    this.flipped = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onTap;
  final bool flipped;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      onTap: enabled ? onTap : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: SizedBox(
          width: AppSpacing.minTouchTarget,
          height: AppSpacing.minTouchTarget,
          child: Center(
            child: Opacity(
              opacity: enabled ? 1 : 0.3,
              child: Transform.rotate(
                angle: flipped ? math.pi : 0,
                child: SvgPicture.asset(
                  AppAssets.chevronSignal,
                  colorFilter: ColorFilter.mode(
                    colors.textBlack,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
