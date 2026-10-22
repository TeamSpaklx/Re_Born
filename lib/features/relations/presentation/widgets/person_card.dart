import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_assets.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../people/presentation/people_providers.dart';

/// 인물 목록의 카드 한 장: 아바타, 이름·관계 칩, 마지막 기록, 오른쪽에 지수. **임시 디자인**(신호 카드 모양).
class PersonCard extends StatelessWidget {
  const PersonCard({super.key, required this.summary, required this.onTap});

  final PersonSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final person = summary.person;
    final last = summary.daysSinceLastRecord;

    return Semantics(
      button: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AppCard.white(
          height: HomeLayout.signalCardHeight,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              Container(
                width: HomeLayout.avatarSize,
                height: HomeLayout.avatarSize,
                decoration: BoxDecoration(
                  color: colors.avatar,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    AppAssets.person,
                    width: HomeLayout.personIconSize,
                    height: HomeLayout.personIconSize,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            person.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.sectionTitle.copyWith(
                              color: colors.textBlack,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.chip,
                            borderRadius: AppRadii.pillBorderRadius,
                          ),
                          child: Text(
                            person.relationType.label,
                            style: AppTextStyles.chipLabel.copyWith(
                              color: colors.textSecondary,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      last == null ? '아직 기록이 없어요' : '마지막 기록 $last일 전',
                      style: AppTextStyles.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    summary.index == null ? '데이터 부족' : '${summary.index}',
                    style:
                        (summary.index == null
                                ? AppTextStyles.body
                                : AppTextStyles.attendanceUnit)
                            .copyWith(
                              color: summary.index == null
                                  ? colors.textSecondary
                                  : colors.brand,
                            ),
                  ),
                  if (summary.index != null)
                    Text(
                      '관계 지수',
                      style: AppTextStyles.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
