import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/app_assets.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_text_button.dart';

/// 탭 위로 쌓이는 전체 화면(작성·상세 등)의 공통 틀: 뒤로 가기 + 제목 + 오른쪽 동작. 임시 디자인.
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
  });

  final String title;
  final Widget body;
  final List<Widget> actions;

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
                              child: SvgPicture.asset(AppAssets.chevronSignal),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
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
            Expanded(child: body),
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
