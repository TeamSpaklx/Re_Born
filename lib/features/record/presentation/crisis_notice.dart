import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/widgets/app_bottom_sheet.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/cta_button.dart';

/// 위기 표현이 감지되었을 때 보여 주는 안내 (SPEC F-13). 부드러운 말투의 시트로, 닫거나 확인하면 저장이 그대로 이어진다.
/// 상담 연락처는 출시 전에 공식 기관 안내로 다시 확인해야 한다(SPEC 11장 12번).
Future<void> showCrisisNotice(BuildContext context) {
  return showAppBottomSheet<void>(
    context,
    title: '마음이 많이 힘드신 것 같아요',
    message: '혼자 견디지 않아도 괜찮아요. 가까운 사람이나 전문 상담 기관에 도움을 요청해 보세요.',
    builder: (context) => const _CrisisContacts(),
  );
}

class _CrisisContacts extends StatelessWidget {
  const _CrisisContacts();

  static const _contacts = [
    ('자살예방 상담전화', '109', '24시간'),
    ('정신건강 위기상담전화', '1577-0199', '24시간'),
    ('청소년 상담전화', '1388', '24시간'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard.pink(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space20,
            vertical: AppSpacing.space8,
          ),
          child: Column(
            children: [
              for (final (name, number, hours) in _contacts)
                Semantics(
                  container: true,
                  label: '$name $number, $hours',
                  excludeSemantics: true,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.space12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: AppTextStyles.rowTitle.copyWith(
                                  color: colors.textBlack,
                                ),
                              ),
                              Text(
                                hours,
                                style: AppTextStyles.caption.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          number,
                          style: AppTextStyles.sectionTitle.copyWith(
                            color: colors.brand,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space12),
        Text(
          '리본은 의료·상담 서비스가 아니에요.',
          style: AppTextStyles.caption.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.space16),
        CtaButton(
          label: '확인했어요',
          height: 52,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
