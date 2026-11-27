import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_card.dart';

/// 요약 카드의 수치 한 칸.
class SummaryItem {
  const SummaryItem({required this.value, required this.label});

  final String value;
  final String label;
}

/// 요약 카드: 흰 카드 안에 큰 수치와 이름을 2~3칸으로 나눠 보여 준다(전체 탭 상단, 관계 탭, 인사이트 상세).
/// 수치는 "누르는 것"도 "감정 데이터"도 아니라서 분홍 대신 검정으로 쓴다(분홍 역할 규칙, DESIGN_SYSTEM).
class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key, required this.items});

  /// 2~3칸.
  final List<SummaryItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard.white(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space20),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0)
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: colors.cardBorder,
                ),
              Expanded(
                child: Semantics(
                  container: true,
                  label: '${items[i].label} ${items[i].value}',
                  excludeSemantics: true,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        items[i].value,
                        style: AppTextStyles.greeting.copyWith(
                          color: colors.textBlack,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[i].label,
                        style: AppTextStyles.body.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
