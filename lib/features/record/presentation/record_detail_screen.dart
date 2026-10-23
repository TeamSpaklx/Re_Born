import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/korean_date.dart';
import '../../../shared/widgets/app_dialogs.dart';
import '../../../shared/widgets/cta_button.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../entries/models/entry.dart';
import '../../entries/presentation/entries_providers.dart';
import '../../people/presentation/people_providers.dart';

/// 기록 상세 (F-03). **임시 디자인**. 수정·삭제(삭제하면 그 인물의 지수를 다시 계산한다).
class RecordDetailScreen extends ConsumerWidget {
  const RecordDetailScreen({super.key, required this.entryId});

  final String entryId;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final ok = await showAppConfirmDialog(
      context,
      title: '기록을 삭제할까요?',
      message: '삭제하면 되돌릴 수 없어요.',
      confirmLabel: '삭제',
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    final router = GoRouter.of(context);
    await ref.read(recordActionsProvider).delete(entryId);
    router.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final entry = ref.watch(entryProvider(entryId)).value;
    final people = ref.watch(peopleProvider).value ?? const [];

    if (entry == null) {
      return const PageScaffold(
        title: '기록',
        body: Center(child: EmptyState(message: '기록을 찾을 수 없어요')),
      );
    }

    final personName = people
        .where((p) => p.id == entry.personId)
        .map((p) => p.name)
        .firstOrNull;
    final time =
        '${entry.createdAt.hour.toString().padLeft(2, '0')}:${entry.createdAt.minute.toString().padLeft(2, '0')}';

    return PageScaffold(
      title: '기록',
      actions: [
        PageAction(
          label: '수정',
          onTap: () => context.push(AppRoutes.recordEdit(entry.id)),
        ),
        PageAction(label: '삭제', onTap: () => _delete(context, ref)),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageMargin,
          8,
          AppSpacing.pageMargin,
          40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${formatKoreanDate(entry.createdAt)} $time',
              style: AppTextStyles.date.copyWith(color: colors.textDate),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _Chip(
                  '${entry.emotion.label} ${entry.intensity}',
                  colors.brand,
                  colors.onCta,
                ),
                if (personName != null)
                  _Chip(personName, colors.chip, colors.textSecondary),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              entry.body,
              style: AppTextStyles.recordCardTitleBefore.copyWith(
                color: colors.textBlack,
                fontWeight: FontWeight.w500,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            _AnalysisSection(entry: entry),
          ],
        ),
      ),
    );
  }
}

class _AnalysisSection extends ConsumerWidget {
  const _AnalysisSection({required this.entry});

  final Entry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final keywords = entry.analysis?.keywords ?? const [];

    String status;
    switch (entry.analysisStatus) {
      case AnalysisStatus.pending:
        status = '분석 중이에요';
      case AnalysisStatus.done:
        status = '분석을 마쳤어요 · 점수 ${entry.score}';
      case AnalysisStatus.failed:
        status = '분석하지 못했어요';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          status,
          style: AppTextStyles.body.copyWith(color: colors.textSecondary),
        ),
        if (keywords.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final k in keywords)
                _Chip(k, colors.chip, colors.textSecondary),
            ],
          ),
        ],
        if (entry.analysisStatus == AnalysisStatus.failed) ...[
          const SizedBox(height: 16),
          CtaButton(
            label: '다시 분석',
            height: 48,
            onPressed: () =>
                ref.read(recordActionsProvider).retryAnalysis(entry.id),
          ),
        ],
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label, this.color, this.textColor);

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadii.pillBorderRadius,
      ),
      child: Text(
        label,
        style: AppTextStyles.chipLabel.copyWith(color: textColor, height: 1.3),
      ),
    );
  }
}
