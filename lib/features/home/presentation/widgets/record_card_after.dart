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
import '../../../../shared/widgets/cta_button.dart';
import '../../models/record_streak.dart';

/// 오늘 기록을 마쳤을 때의 핑크 카드 (Figma `UnWrite` After, docs/DESIGN_HOME.md 5.3).
/// 캐릭터 · 완료 문구 · 오늘 일기의 AI 코멘트 · "오늘 기록 보기" · (출석 체크 패널은 [HomeLayout.showAttendance]가 켜졌을 때만).
class RecordCardAfter extends StatelessWidget {
  const RecordCardAfter({
    super.key,
    required this.streak,
    required this.onViewToday,
    this.comment,
    this.commentPending = false,
  });

  final RecordStreak streak;
  final VoidCallback onViewToday;

  /// 오늘 일기의 AI 코멘트. 없으면 코멘트 말풍선을 그리지 않는다.
  final String? comment;

  /// 코멘트를 아직 받는 중이면 "코멘트를 쓰고 있어요"를 보여 준다.
  final bool commentPending;

  static const _avatarSize = 44.0;
  static const _gap = 22.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final longest = streak.longest < streak.current
        ? streak.current
        : streak.longest;

    return AppCard.pink(
      height: HomeLayout.recordCardHeightAfter,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.recordCardPadding,
        AppSpacing.recordCardPadding,
        AppSpacing.recordCardPadding,
        21,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: _avatarSize,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  child: CharacterAvatar(
                    seed: 'today-0',
                    size: _avatarSize,
                    borderColor: colors.cardWhite,
                  ),
                ),
                Positioned(
                  right: 0,
                  child: SvgPicture.asset(
                    AppAssets.sealCheck,
                    width: _avatarSize,
                    height: _avatarSize,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: _gap),
          Text.rich(
            TextSpan(
              style: AppTextStyles.recordCardTitleAfter.copyWith(
                color: colors.textBlack,
              ),
              children: [
                const TextSpan(text: '오늘도 기록 완료!\n'),
                TextSpan(
                  text: '${streak.current}',
                  style: TextStyle(color: colors.brand),
                ),
                const TextSpan(text: '일 연속 마음을 기록하고 있어요.'),
              ],
            ),
          ),
          if (comment != null || commentPending) ...[
            const SizedBox(height: AppSpacing.space16),
            _CommentBubble(comment: comment, pending: commentPending),
          ],
          const SizedBox(height: _gap),
          CtaButton(
            label: '오늘 기록 보기',
            height: HomeLayout.ctaButtonHeightAfter,
            onPressed: onViewToday,
          ),
          if (HomeLayout.showAttendance) ...[
            // Figma의 "출석 체크" 글자 위치에 맞추려고 제목 위 간격을 4 늘리고 아래를 4 줄였다(전체 높이 그대로).
            const SizedBox(height: _gap + 4),
            CenteredLine(
              height: 20,
              child: Row(
                children: [
                  Text(
                    '출석 체크',
                    style: AppTextStyles.attendanceTitle.copyWith(
                      color: colors.textBlack,
                    ),
                  ),
                  SvgPicture.asset(AppAssets.chevronAttendance),
                ],
              ),
            ),
            const SizedBox(height: _gap - 4),
            _AttendancePanel(streak: streak, longest: longest),
          ],
        ],
      ),
    );
  }
}

class _AttendancePanel extends StatelessWidget {
  const _AttendancePanel({required this.streak, required this.longest});

  final RecordStreak streak;
  final int longest;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final filled = streak.current.clamp(0, AttendanceLayout.pillCount);

    return Container(
      height: AttendanceLayout.panelHeight,
      decoration: BoxDecoration(
        color: colors.attendancePanel,
        borderRadius: BorderRadius.circular(AppRadii.attendancePanel),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 15,
            top: 21,
            child: CenteredLine(
              height: 24,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${streak.current}',
                      style: AppTextStyles.attendanceNumber.copyWith(
                        color: colors.brand,
                      ),
                    ),
                    TextSpan(
                      text: ' 일',
                      style: AppTextStyles.attendanceUnit.copyWith(
                        color: colors.textBlack,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 15,
            top: 55,
            child: CenteredLine(
              height: 20,
              child: Text(
                '최장 기록 $longest일 · ${streak.current}/$longest일',
                style: AppTextStyles.body.copyWith(
                  color: colors.onAttendancePanel,
                ),
              ),
            ),
          ),
          Positioned(
            left: 15,
            top: 86,
            child: Row(
              children: [
                for (var i = 0; i < AttendanceLayout.pillCount; i++) ...[
                  if (i > 0) const SizedBox(width: AttendanceLayout.pillGap),
                  Container(
                    key: ValueKey(
                      i < filled ? 'pill-filled-$i' : 'pill-empty-$i',
                    ),
                    width: AttendanceLayout.pillWidth,
                    height: AttendanceLayout.pillHeight,
                    decoration: BoxDecoration(
                      color: i < filled
                          ? colors.brand
                          : colors.cardWhite.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(
                        AppRadii.attendancePill,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 기록 완료 카드 안의 AI 코멘트 한 덩이(최대 2줄).
class _CommentBubble extends StatelessWidget {
  const _CommentBubble({required this.comment, required this.pending});

  final String? comment;
  final bool pending;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      key: const Key('home-ai-comment'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space16,
        vertical: AppSpacing.space12,
      ),
      decoration: BoxDecoration(
        color: colors.cardWhite,
        borderRadius: BorderRadius.circular(AppRadii.card - 8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI 코멘트',
            style: AppTextStyles.caption.copyWith(color: colors.brand),
          ),
          const SizedBox(height: 4),
          Text(
            pending && comment == null ? '오늘 일기를 읽고 코멘트를 쓰고 있어요…' : comment!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body.copyWith(
              color: pending && comment == null
                  ? colors.textSecondary
                  : colors.textStrong,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
