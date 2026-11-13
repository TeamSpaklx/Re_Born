import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/korean_date.dart';
import '../../../../shared/widgets/centered_line.dart';
import '../../models/greeting_pool.dart';

/// 날짜와 인사말 ("9월 13일 목요일 / 규리님, 오늘도 즐거운 하루 보내세요!"). 인사말은 실행마다 풀에서 하나가 뽑힌다.
class HomeGreeting extends ConsumerWidget {
  const HomeGreeting({super.key, required this.today, required this.nickname});

  final DateTime today;
  final String nickname;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            // 문구는 앱을 켤 때 한 번 뽑은 것(GreetingPool). 두 줄로 나뉘게 줄바꿈이 들어 있다.
            Text(
              GreetingPool.format(ref.watch(greetingIndexProvider), nickname),
              style: AppTextStyles.homeGreeting.copyWith(
                color: colors.textBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
