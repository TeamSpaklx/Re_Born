import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/app_assets.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_text_button.dart';

/// 탭 위로 쌓이는 전체 화면(작성·상세 등)의 공통 틀: 뒤로 가기 + 제목 + 오른쪽 동작.
/// - [largeTitle]: 제목을 위 바 가운데 대신 바 아래에 크고 굵게(26) 놓는다(토스식 큰 제목 화면).
/// - [subtitle]: 큰 제목 아래 보조 설명(회색).
/// - [progress]: 바 아래·제목 위에 놓는 진행 표시(보통 [StepProgressBar]).
/// - [showBack]: false면 뒤로 가기 버튼을 그리지 않는다(로그인처럼 돌아갈 곳이 없는 화면).
/// - [bottom]: 화면 맨 아래에 고정되는 영역(보통 [BottomCtaBar]).
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
    this.largeTitle = false,
    this.subtitle,
    this.progress,
    this.showBack = true,
    this.bottom,
  });

  final String title;
  final Widget body;
  final List<Widget> actions;
  final bool largeTitle;
  final String? subtitle;
  final Widget? progress;
  final bool showBack;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageMargin - 8,
                ),
                child: Row(
                  children: [
                    if (!showBack)
                      const SizedBox(width: 8)
                    else
                      Semantics(
                        button: true,
                        label: '뒤로',
                        excludeSemantics: true,
                        onTap: () => Navigator.of(context).maybePop(),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => Navigator.of(context).maybePop(),
                          child: SizedBox(
                            width: 44,
                            height: 44,
                            child: Center(
                              child: Transform.rotate(
                                angle: math.pi,
                                child: SvgPicture.asset(
                                  AppAssets.chevronSignal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: largeTitle
                          ? const SizedBox.shrink()
                          : Text(
                              title,
                              style: AppTextStyles.sectionTitle.copyWith(
                                color: colors.textBlack,
                              ),
                            ),
                    ),
                    ...actions,
                  ],
                ),
              ),
            ),
            if (progress != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageMargin,
                ),
                child: progress,
              ),
            if (largeTitle)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageMargin,
                    AppSpacing.space16,
                    AppSpacing.pageMargin,
                    AppSpacing.space16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          title,
                          style: AppTextStyles.greeting.copyWith(
                            color: colors.textBlack,
                            height: 1.3,
                          ),
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppSpacing.space8),
                        Text(
                          subtitle!,
                          style: AppTextStyles.recordCardSubtitle.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            Expanded(child: body),
            ?bottom,
          ],
        ),
      ),
    );
  }
}

/// [PageScaffold] 오른쪽 위에 놓는 글자 버튼 ("수정", "삭제" 등).
class PageAction extends StatelessWidget {
  const PageAction({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppTextButton(
      label: label,
      color: context.colors.textStrong,
      onTap: onTap,
    );
  }
}
