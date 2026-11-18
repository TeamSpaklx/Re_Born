import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/app_assets.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_text_button.dart';
import 'pressable.dart';

/// 탭 위로 쌓이는 전체 화면(작성·상세 등)의 공통 틀: 뒤로 가기 + 제목 + 오른쪽 동작.
/// - [largeTitle]: 제목을 위 바 가운데 대신 바 아래에 크고 굵게(26) 놓는다(토스식 큰 제목 화면).
/// - [centerTitle]: 높이 44 바의 가운데에 제목(22 Bold)을 둔다
///   (Figma 알림 `834:1149`). 오른쪽에는 보통 [PageIconAction]을 놓는다. 뒤로 버튼은 두 바 모두 [PageBackButton].
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
    this.centerTitle = false,
    this.subtitle,
    this.progress,
    this.showBack = true,
    this.bottom,
  });

  final String title;
  final Widget body;
  final List<Widget> actions;
  final bool largeTitle;
  final bool centerTitle;
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
            if (centerTitle)
              _CenterTitleBar(
                title: title,
                showBack: showBack,
                actions: actions,
              )
            else
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
                        const PageBackButton(),
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
            if (largeTitle && !centerTitle)
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

/// 가운데 제목 바 (Figma 알림 `834:1149`): 높이 44, 왼쪽 뒤로([PageBackButton]), 가운데 제목 22 Bold, 오른쪽 아이콘 동작.
class _CenterTitleBar extends StatelessWidget {
  const _CenterTitleBar({
    required this.title,
    required this.showBack,
    required this.actions,
  });

  final String title;
  final bool showBack;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // 아이콘(24)이 화면 끝에서 24 떨어지도록, 44 터치 영역의 바깥 여백은 24 − (44 − 24) / 2.
    const edge =
        AppSpacing.pageMargin -
        (AppSpacing.minTouchTarget - ComponentLayout.topBarIconSize) / 2;
    return SizedBox(
      height: ComponentLayout.centerTitleBarHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: AppTextStyles.pageTitle.copyWith(color: colors.textBlack),
            ),
          ),
          Padding(
            // 뒤로 버튼은 기본 바와 같은 자리(왼쪽 16)에 둔다.
            padding: const EdgeInsets.only(
              left: AppSpacing.pageMargin - 8,
              right: edge,
            ),
            child: Row(
              children: [
                if (showBack) const PageBackButton(),
                const Spacer(),
                ...actions,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// [PageScaffold] 위 바에 놓는 아이콘 버튼(아이콘 24, 터치 영역 44). 예: 알림 화면의 설정 톱니.
class PageIconAction extends StatelessWidget {
  const PageIconAction({
    super.key,
    required this.iconAsset,
    required this.label,
    required this.onTap,
  });

  /// 한 가지 색 SVG.
  final String iconAsset;

  /// 화면 낭독기가 읽을 이름.
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: SizedBox(
          width: AppSpacing.minTouchTarget,
          height: AppSpacing.minTouchTarget,
          child: Center(
            child: SvgPicture.asset(
              iconAsset,
              width: ComponentLayout.topBarIconSize,
              height: ComponentLayout.topBarIconSize,
              colorFilter: ColorFilter.mode(
                context.colors.textBlack,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 모든 상단 바의 뒤로 가기: 회색 꺾쇠(`chevronSignal`, #4C535F 80%)를 왼쪽으로 돌려 44 터치 영역 가운데에 둔다.
/// [PageScaffold]의 기본 바와 가운데 제목 바가 같은 버튼을 쓴다.
class PageBackButton extends StatelessWidget {
  const PageBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    void back() => Navigator.of(context).maybePop();
    return Semantics(
      button: true,
      label: '뒤로',
      excludeSemantics: true,
      onTap: back,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: back,
        child: SizedBox(
          width: AppSpacing.minTouchTarget,
          height: AppSpacing.minTouchTarget,
          child: Center(
            child: Transform.rotate(
              angle: math.pi,
              child: SvgPicture.asset(AppAssets.chevronSignal),
            ),
          ),
        ),
      ),
    );
  }
}
