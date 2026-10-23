import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/korean_date.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/centered_line.dart';
import '../../../shared/widgets/cta_button.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/tab_page_scaffold.dart';
import '../../entries/models/entry.dart';
import '../../entries/presentation/entries_providers.dart';
import '../../entries/presentation/widgets/entry_card.dart';
import '../../people/presentation/people_providers.dart';

/// 기록 탭 (F-03). **임시 디자인**: Figma에 이 화면이 없어 홈의 카드·버튼 값으로 조합했다.
/// 위쪽에 "감정 기록하기", 아래에 날짜별 기록 목록.
class RecordScreen extends ConsumerWidget {
  const RecordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(entriesProvider);
    final people = ref.watch(peopleProvider).value ?? const [];
    final names = {for (final p in people) p.id: p.name};

    return TabPageScaffold(
      title: '기록',
      children: [
        const SizedBox(height: HomeLayout.headerToDate),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageMargin,
          ),
          child: AppCard.pink(
            padding: const EdgeInsets.all(AppSpacing.recordCardPadding),
            child: CtaButton(
              label: '감정 기록하기',
              height: HomeLayout.ctaButtonHeightBefore,
              onPressed: () => context.push(AppRoutes.recordNew),
            ),
          ),
        ),
        const SizedBox(height: 24),
        entries.when(
          data: (list) => list.isEmpty
              ? const EmptyState(
                  message: '아직 기록이 없어요',
                  hint: '오늘의 마음을 한 줄로 남겨 보세요.',
                )
              : _EntryList(entries: list, names: names),
          loading: () => const SizedBox.shrink(),
          error: (e, st) =>
              EmptyState(message: '불러오지 못했어요', hint: '잠시 뒤 다시 시도해 주세요.'),
        ),
      ],
    );
  }
}

class _EntryList extends StatelessWidget {
  const _EntryList({required this.entries, required this.names});

  final List<Entry> entries;
  final Map<String, String> names;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final groups = <DateTime, List<Entry>>{};
    for (final e in entries) {
      groups.putIfAbsent(dateOnly(e.createdAt), () => []).add(e);
    }
    final days = groups.keys.toList()..sort((a, b) => b.compareTo(a));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final day in days) ...[
            CenteredLine(
              height: 24,
              child: Text(
                formatKoreanDate(day),
                style: AppTextStyles.date.copyWith(color: colors.textDate),
              ),
            ),
            const SizedBox(height: 8),
            for (final entry in groups[day]!) ...[
              SizedBox(
                width: double.infinity,
                child: EntryCard(
                  entry: entry,
                  personName: names[entry.personId],
                  onTap: () => context.push(AppRoutes.recordDetail(entry.id)),
                ),
              ),
              const SizedBox(height: AppSpacing.actionCardGap),
            ],
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
