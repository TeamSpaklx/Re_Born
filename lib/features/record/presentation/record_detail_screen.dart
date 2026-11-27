import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/korean_date.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_dialogs.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../entries/models/entry.dart';
import '../../entries/models/intensity_level.dart';
import '../../entries/presentation/entries_providers.dart';
import '../../entries/presentation/widgets/emotion_chip.dart';
import '../../entries/presentation/widgets/emotion_face.dart';
import '../../entries/presentation/widgets/entry_card.dart';
import '../../ai_comment/presentation/ai_feedback_card.dart';

/// 기록 상세 (F-03): 감정 캐릭터와 강도, 본문, 분석 결과. 수정·삭제(삭제하면 그 인물의 지수를 다시 계산한다).
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

    if (entry == null) {
      return const PageScaffold(
        title: '기록',
        body: Center(child: EmptyState(message: '기록을 찾을 수 없어요')),
      );
    }

    final tint = emotionColor(entry.emotion, colors);

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
          AppSpacing.space8,
          AppSpacing.pageMargin,
          AppSpacing.space40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.space20),
              decoration: BoxDecoration(
                color: Color.alphaBlend(
                  tint.withValues(alpha: 0.16),
                  colors.cardWhite,
                ),
                borderRadius: AppRadii.cardBorderRadius,
              ),
              child: Row(
                children: [
                  EmotionFace(emotion: entry.emotion, size: 64),
                  const SizedBox(width: AppSpacing.space16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              entry.emotion.label,
                              style: AppTextStyles.sectionTitle.copyWith(
                                color: colors.textBlack,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.space8),
                            IntensityDots(level: entry.intensity),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${formatKoreanDate(entry.createdAt)} · ${formatKoreanTime(entry.createdAt)}',
                          style: AppTextStyles.body.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space24),
            Text(
              entry.body,
              style: AppTextStyles.recordCardSubtitle.copyWith(
                color: colors.textBlack,
                height: 1.7,
              ),
            ),
            const SizedBox(height: AppSpacing.space32),
            AiFeedbackCard(entry: entry),
            const SizedBox(height: AppSpacing.space16),
            _AnalysisSection(entry: entry),
          ],
        ),
      ),
    );
  }
}

/// 앱 안 규칙 분석 결과: 감정 점수(−5~+5)와 본문에서 찾은 감정 단어.
class _AnalysisSection extends StatelessWidget {
  const _AnalysisSection({required this.entry});

  final Entry entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final analysis = entry.analysis;
    if (analysis == null) return const SizedBox.shrink();
    final keywords = analysis.keywords;
    final level = IntensityLevel.of(entry.intensity);

    return AppCard.white(
      padding: const EdgeInsets.all(AppSpacing.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '감정 데이터',
            style: AppTextStyles.groupTitle.copyWith(color: colors.textBlack),
          ),
          if (level != null) ...[
            const SizedBox(height: AppSpacing.space12),
            Row(
              children: [
                Text(
                  '강도',
                  style: AppTextStyles.body.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${level.value}단계 · ${level.label}',
                  key: const Key('entry-level'),
                  style: AppTextStyles.body.copyWith(color: colors.textBlack),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                level.description,
                style: AppTextStyles.caption.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.space12),
          Row(
            children: [
              Text(
                '감정 점수',
                style: AppTextStyles.body.copyWith(color: colors.textSecondary),
              ),
              const Spacer(),
              Text(
                '${entry.score > 0 ? '+' : ''}${entry.score}',
                key: const Key('entry-score'),
                style: AppTextStyles.sectionTitle.copyWith(
                  color: entry.score < 0 ? colors.danger : colors.brand,
                ),
              ),
            ],
          ),
          if (keywords.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.space16),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final k in keywords)
                  _Chip(k, colors.chip, colors.textSecondary),
              ],
            ),
          ],
        ],
      ),
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
