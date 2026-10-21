import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/korean_date.dart';
import '../../../../shared/widgets/centered_line.dart';

/// 날짜와 인사말 ("9월 13일 목요일 / 규리님, 오늘도 즐거운 하루 보내세요!").
class HomeGreeting extends StatelessWidget {
  const HomeGreeting({super.key, required this.today, required this.nickname});

  final DateTime today;
  final String nickname;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageMargin),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Figma 날짜 상자 높이 17. 글꼴 줄 높이와 상관없이 고정한다.
            CenteredLine(
              height: HomeLayout.dateHeight,
              child: Text(
                formatKoreanDate(today),
                style: AppTextStyles.date.copyWith(color: colors.textDate),
              ),
            ),
            const SizedBox(height: HomeLayout.dateToGreeting),
            // Figma처럼 "즐거운" 뒤에서 줄을 바꾼다.
            Text(
              '$nickname님, 오늘도 즐거운\n하루 보내세요!',
              style: AppTextStyles.greeting.copyWith(color: colors.textBlack),
            ),
          ],
        ),
      ),
    );
  }
}
