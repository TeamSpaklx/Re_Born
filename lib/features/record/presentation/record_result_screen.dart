import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/bottom_cta_bar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../../ai_comment/presentation/ai_feedback_card.dart';
import '../../entries/models/intensity_level.dart';
import '../../entries/presentation/entries_providers.dart';
import '../../entries/presentation/widgets/emotion_face.dart';

/// 일기를 저장한 직후 화면: 고른 감정·강도 요약과 AI 코멘트(받는 중 → 도착), 행동 제안.
/// 제안은 바로 체크리스트에 담을 수 있다. "확인"을 누르면 원래 탭으로 돌아간다.
class RecordResultScreen extends ConsumerWidget {
  const RecordResultScreen({super.key, required this.entryId});

  final String entryId;

  void _close(BuildContext context) {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
    } else {
      router.go(AppRoutes.record);
    }
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
    final level = IntensityLevel.of(entry.intensity);

    return PageScaffold(
      title: '오늘의 마음을\n기록했어요',
      largeTitle: true,
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
            AppCard.white(
              padding: const EdgeInsets.all(AppSpacing.space16),
              child: Row(
                children: [
                  EmotionFace(emotion: entry.emotion, size: 48),
                  const SizedBox(width: AppSpacing.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.emotion.label,
                          style: AppTextStyles.groupTitle.copyWith(
                            color: colors.textBlack,
                          ),
                        ),
                        if (level != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            '강도 ${level.value}단계 · ${level.label}',
                            key: const Key('result-level'),
                            style: AppTextStyles.body.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space16),
            AiFeedbackCard(entry: entry),
          ],
        ),
      ),
      bottom: BottomCtaBar(label: '확인', onPressed: () => _close(context)),
    );
  }
}
