import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_assets.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../../../shared/widgets/pressable.dart';

/// 섹션 제목 줄. 오른쪽에 "전체 보기 >"가 있거나("최근 관계 신호"),
/// 제목 옆에 화살표가 붙는다("오늘 해볼까요? >", Before 디자인).
class SectionTitleRow extends StatelessWidget {
  const SectionTitleRow({
    super.key,
    required this.title,
    this.onSeeAll,
    this.trailingChevron = false,
    this.onTitleTap,
  });

  final String title;

  /// 있으면 오른쪽 끝에 "전체 보기 >"를 보여 주고 누르면 호출한다.
  final VoidCallback? onSeeAll;

  /// 제목 바로 옆에 화살표(20)를 붙인다.
  final bool trailingChevron;

  /// 있으면 제목(과 화살표) 전체가 눌린다("오늘 해볼까요? >" → 체크리스트). 터치 영역 높이는 줄 높이(32, 디자인 고정)다.
  final VoidCallback? onTitleTap;

  static const _chevronGap = 3.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final titleText = Text(
      title,
      style: AppTextStyles.sectionTitle.copyWith(color: colors.textBlack),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageMargin),
      child: SizedBox(
        height: HomeLayout.sectionTitleHeight,
        child: Row(
          children: [
            if (onTitleTap != null)
              Semantics(
                button: true,
                label: title,
                excludeSemantics: true,
                onTap: onTitleTap,
                child: Pressable(
                  onTap: () {
                    AppHaptics.tap();
                    onTitleTap!();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      titleText,
                      if (trailingChevron) ...[
                        const SizedBox(width: _chevronGap),
                        SvgPicture.asset(AppAssets.chevronSection),
                      ],
                    ],
                  ),
                ),
              )
            else ...[
              titleText,
              if (trailingChevron) ...[
                const SizedBox(width: _chevronGap),
                SvgPicture.asset(AppAssets.chevronSection),
              ],
            ],
            const Spacer(),
            if (onSeeAll != null)
              Semantics(
                button: true,
                label: '전체 보기',
                excludeSemantics: true,
                onTap: onSeeAll,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    AppHaptics.tap();
                    onSeeAll!();
                  },
                  child: Row(
                    children: [
                      Text(
                        '전체 보기',
                        style: AppTextStyles.seeAll.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      SvgPicture.asset(AppAssets.chevronSeeAll),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
