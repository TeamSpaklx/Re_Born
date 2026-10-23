import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/providers/clock_provider.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/korean_date.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_dialogs.dart';
import '../../../shared/widgets/app_fab.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/month_calendar.dart';
import '../../../shared/widgets/segmented_control.dart';
import '../../../shared/widgets/swipe_to_delete.dart';
import '../../../shared/widgets/tab_page_scaffold.dart';
import '../../entries/models/emotion.dart';
import '../../entries/models/entry.dart';
import '../../entries/presentation/entries_providers.dart';
import '../../entries/presentation/widgets/emotion_face.dart';
import '../../entries/presentation/widgets/emotion_picker.dart';
import '../../entries/presentation/widgets/entry_card.dart';
import '../../people/presentation/people_providers.dart';

/// 기록 탭 (F-03): 달력으로 날짜를 골라 그날의 기록을 보거나, 날짜별 목록으로 훑는다.
/// 달력의 날짜 아래에는 그날 마지막 기록의 감정 캐릭터가 붙고, 위에는 이번 달 감정 비율이 있다.
/// 카드는 밀어서 지울 수 있다(확인 팝업). 오른쪽 아래 "기록하기"가 작성 화면을 연다.
class RecordScreen extends ConsumerStatefulWidget {
  const RecordScreen({super.key});

  @override
  ConsumerState<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends ConsumerState<RecordScreen> {
  int _view = 0; // 0 달력, 1 목록
  DateTime? _month;
  DateTime? _selected;

  Future<bool> _confirmDelete() => showAppConfirmDialog(
    context,
    title: '기록을 삭제할까요?',
    message: '삭제하면 되돌릴 수 없어요.',
    confirmLabel: '삭제',
    destructive: true,
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final now = ref.watch(clockProvider)();
    final today = dateOnly(now);
    final month = _month ?? DateTime(today.year, today.month);
    final selected = _selected ?? today;
    final entries = ref.watch(entriesProvider);
    final people = ref.watch(peopleProvider).value ?? const [];
    final names = {for (final p in people) p.id: p.name};

    Widget cardFor(Entry entry) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.actionCardGap),
      child: SwipeToDelete(
        dismissKey: Key('entry-${entry.id}'),
        confirm: _confirmDelete,
        onDelete: () => ref.read(recordActionsProvider).delete(entry.id),
        child: EntryCard(
          entry: entry,
          personName: names[entry.personId],
          onTap: () => context.push(AppRoutes.recordDetail(entry.id)),
        ),
      ),
    );

    return TabPageScaffold(
      title: '기록',
      floating: AppFab(
        label: '기록하기',
        onTap: () => context.push(AppRoutes.recordNew),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageMargin,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.space8),
              SegmentedControl(
                labels: const ['달력', '목록'],
                selectedIndex: _view,
                onChanged: (i) => setState(() => _view = i),
              ),
              const SizedBox(height: AppSpacing.space16),
              entries.when(
                data: (list) {
                  if (list.isEmpty) {
                    return EmptyState(
                      message: '아직 기록이 없어요',
                      hint: '오늘의 마음을 한 줄로 남겨 보세요.',
                      showMascot: true,
                      actionLabel: '첫 기록 남기기',
                      onAction: () => context.push(AppRoutes.recordNew),
                    );
                  }
                  final byDay = <DateTime, List<Entry>>{};
                  for (final e in list) {
                    byDay.putIfAbsent(dateOnly(e.createdAt), () => []).add(e);
                  }
                  if (_view == 1) {
                    final days = byDay.keys.toList()
                      ..sort((a, b) => b.compareTo(a));
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final day in days) ...[
                          Padding(
                            padding: const EdgeInsets.only(
                              top: AppSpacing.space12,
                              bottom: AppSpacing.space8,
                            ),
                            child: Semantics(
                              header: true,
                              child: Text(
                                formatKoreanDate(day),
                                style: AppTextStyles.sectionLabel.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          for (final entry in byDay[day]!) cardFor(entry),
                        ],
                      ],
                    );
                  }

                  final counts = <Emotion, int>{};
                  for (final e in list) {
                    if (e.createdAt.year == month.year &&
                        e.createdAt.month == month.month) {
                      counts[e.emotion] = (counts[e.emotion] ?? 0) + 1;
                    }
                  }
                  final dayEntries = byDay[selected] ?? const <Entry>[];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppCard.white(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.space12,
                          AppSpacing.space8,
                          AppSpacing.space12,
                          AppSpacing.space12,
                        ),
                        child: MonthCalendar(
                          month: month,
                          selected: selected,
                          today: today,
                          onSelected: (d) => setState(() => _selected = d),
                          onMonthChanged: (m) => setState(() => _month = m),
                          markerFor: (day) {
                            final dayList = byDay[dateOnly(day)];
                            if (dayList == null) return null;
                            return EmotionFace(
                              emotion: dayList.first.emotion,
                              size: 20,
                            );
                          },
                        ),
                      ),
                      if (counts.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.space16),
                        AppCard.white(
                          padding: const EdgeInsets.all(AppSpacing.space20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${month.month}월의 마음',
                                style: AppTextStyles.groupTitle.copyWith(
                                  color: colors.textBlack,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.space12),
                              EmotionRatioBar(counts: counts),
                            ],
                          ),
                        ),
                      ],
                      Padding(
                        padding: const EdgeInsets.only(
                          top: AppSpacing.space24,
                          bottom: AppSpacing.space12,
                        ),
                        child: Semantics(
                          header: true,
                          child: Text(
                            formatKoreanDate(selected),
                            style: AppTextStyles.sectionTitle.copyWith(
                              color: colors.textBlack,
                            ),
                          ),
                        ),
                      ),
                      if (dayEntries.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.space24,
                          ),
                          child: Text(
                            selected == today
                                ? '오늘은 아직 기록이 없어요.'
                                : '이날은 남긴 기록이 없어요.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        )
                      else
                        for (final entry in dayEntries) cardFor(entry),
                    ],
                  );
                },
                loading: () => const SizedBox(height: 200),
                error: (e, st) =>
                    ErrorState(onRetry: () => ref.invalidate(entriesProvider)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
