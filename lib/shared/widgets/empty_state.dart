import 'package:flutter/material.dart';

import '../../app/theme/app_assets.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import 'cta_button.dart';

/// 비어 있을 때의 안내: (마스코트) + 제목 한 줄 + 설명 + (버튼).
/// 예: "아직 기록이 없어요" / "첫 마음을 남겨 볼까요?" / [감정 기록하기].
/// 마스코트는 [showMascot]으로 켠다(여우원숭이, 장식이라 스크린 리더는 읽지 않는다).
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.hint,
    this.showMascot = false,
    this.actionLabel,
    this.onAction,
  });

  /// 제목(한 줄).
  final String message;

  /// 설명.
  final String? hint;
  final bool showMascot;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.space48,
        horizontal: AppSpacing.space24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showMascot) ...[
            Image.asset(
              AppAssets.mascotLemur,
              width: ComponentLayout.stateMascotSize,
              height: ComponentLayout.stateMascotSize,
              excludeFromSemantics: true,
            ),
            const SizedBox(height: AppSpacing.space16),
          ],
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.recordCardTitleBefore.copyWith(
              color: colors.textBlack,
            ),
          ),
          if (hint != null) ...[
            const SizedBox(height: AppSpacing.space8),
            Text(
              hint!,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: colors.textSecondary),
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.space24),
            SizedBox(
              width: ComponentLayout.stateButtonWidth,
              child: CtaButton(
                label: actionLabel!,
                height: 48,
                variant: CtaVariant.soft,
                onPressed: onAction,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 불러오기·저장 실패 안내: 무엇이 안 됐는지 + "다시 시도". 오류 내용(기술 문구)은 보이지 않는다.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.onRetry,
    this.message = '불러오지 못했어요',
    this.hint = '잠시 뒤에 다시 시도해 주세요.',
    this.showMascot = false,
  });

  final VoidCallback onRetry;
  final String message;
  final String? hint;
  final bool showMascot;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      message: message,
      hint: hint,
      showMascot: showMascot,
      actionLabel: '다시 시도',
      onAction: onRetry,
    );
  }
}
