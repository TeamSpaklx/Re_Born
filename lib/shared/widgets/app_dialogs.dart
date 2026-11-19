import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/theme/bottom_nav_tokens.dart';
import 'pressable.dart';

/// 모달 버튼의 모양: 주요(브랜드 핑크) / 보조(연한 회색) / 위험(연한 빨강 + 빨간 글자).
enum AppDialogButtonKind { primary, secondary, destructive }

/// 모달 창 아래 버튼 하나. 누르면 [value]를 돌려주며 닫힌다(null이면 바깥을 눌러 닫은 것과 같다).
class AppDialogAction<T> {
  const AppDialogAction({
    required this.label,
    required this.value,
    this.kind = AppDialogButtonKind.secondary,
  });

  final String label;
  final T? value;
  final AppDialogButtonKind kind;
}

/// Reborn 모달 창 (Figma에 없음, 토스 화면의 구조를 참고해 Reborn 색·모서리로 만든 추정 디자인).
/// 흰 둥근 창에 왼쪽 정렬 제목·설명, 아래에 버튼. 버튼이 2개 이하면 가로로 나란히, 3개 이상이면 세로로 쌓는다.
/// 머티리얼 `AlertDialog`/`Dialog`+`TextButton`을 대신한다.
Future<T?> showAppDialog<T>(
  BuildContext context, {
  required String title,
  required String message,
  required List<AppDialogAction<T>> actions,
}) {
  final colors = context.colors;
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: '닫기',
    barrierColor: colors.scrim,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondary) => SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ComponentLayout.dialogMargin,
          ),
          child: _AppDialog<T>(
            title: title,
            message: message,
            actions: actions,
          ),
        ),
      ),
    ),
    transitionBuilder: (context, animation, secondary, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _AppDialog<T> extends StatelessWidget {
  const _AppDialog({
    required this.title,
    required this.message,
    required this.actions,
  });

  final String title;
  final String message;
  final List<AppDialogAction<T>> actions;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Widget button(AppDialogAction<T> action) => _DialogButton(
      label: action.label,
      kind: action.kind,
      onTap: () => Navigator.of(context).pop(action.value),
    );

    final Widget buttons = actions.length <= 2
        ? Row(
            children: [
              for (var i = 0; i < actions.length; i++) ...[
                if (i > 0)
                  const SizedBox(width: ComponentLayout.dialogButtonGap),
                Expanded(child: button(actions[i])),
              ],
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < actions.length; i++) ...[
                if (i > 0)
                  const SizedBox(height: ComponentLayout.dialogButtonGap),
                button(actions[i]),
              ],
            ],
          );

    // 이 창은 Navigator 위의 일반 라우트라서 글자 기본 스타일(밑줄 등)을 직접 지운다.
    return DefaultTextStyle.merge(
      style: const TextStyle(decoration: TextDecoration.none),
      child: Semantics(
        scopesRoute: true,
        explicitChildNodes: true,
        namesRoute: true,
        label: title,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(ComponentLayout.dialogPadding),
          decoration: BoxDecoration(
            color: colors.cardWhite,
            borderRadius: AppRadii.dialogBorderRadius,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.sectionTitle.copyWith(
                  color: colors.textBlack,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: AppTextStyles.body.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: 24),
              buttons,
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.kind,
    required this.onTap,
  });

  final String label;
  final AppDialogButtonKind kind;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (fill, text) = switch (kind) {
      AppDialogButtonKind.primary => (colors.brand, colors.onCta),
      AppDialogButtonKind.secondary => (colors.chip, colors.textStrong),
      AppDialogButtonKind.destructive => (colors.dangerTile, colors.danger),
    };
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: Container(
          height: ComponentLayout.dialogButtonHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: AppRadii.buttonBorderRadius,
          ),
          child: Text(
            label,
            style: AppTextStyles.buttonLarge.copyWith(color: text),
          ),
        ),
      ),
    );
  }
}

/// 확인 모달. 확인을 누르면 true, 취소·바깥을 누르면 false.
/// [cancelLabel]이 null이면 확인 버튼만 있다. 삭제·로그아웃처럼 되돌릴 수 없는 동작은 [destructive]로 빨갛게 보인다.
Future<bool> showAppConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = '확인',
  String? cancelLabel = '취소',
  bool destructive = false,
}) async {
  final result = await showAppDialog<bool>(
    context,
    title: title,
    message: message,
    actions: [
      if (cancelLabel != null)
        AppDialogAction(label: cancelLabel, value: false),
      AppDialogAction(
        label: confirmLabel,
        value: true,
        kind: destructive
            ? AppDialogButtonKind.destructive
            : AppDialogButtonKind.primary,
      ),
    ],
  );
  return result ?? false;
}

OverlayEntry? _activeToast;

/// 화면 아래(탭 바 위)에 잠깐 떴다 사라지는 안내 (Figma 토스트 `834:2088`).
///
/// 흰 알약에 문구와 오른쪽 '확인'. [success]가 true면(저장·완료 같은 성공 알림) 왼쪽에 분홍 체크 원을 붙이고,
/// 오류·권한·안내 문구는 체크 없이 띄운다. 아래에서 올라오며 나타나고 약 3초 뒤 사라지며,
/// '확인'을 누르면 바로 사라진다. 새 토스트가 오면 이전 것은 바로 바뀐다.
/// 머티리얼 `SnackBar`를 대신한다. 토스트 바깥 터치는 아래 화면으로 그대로 통과한다.
void showAppToast(
  BuildContext context,
  String message, {
  bool success = false,
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;
  _activeToast?.remove();
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _AppToast(
      message: message,
      success: success,
      onDone: () {
        if (_activeToast == entry) _activeToast = null;
        entry.remove();
      },
    ),
  );
  _activeToast = entry;
  overlay.insert(entry);
}

class _AppToast extends StatefulWidget {
  const _AppToast({
    required this.message,
    required this.success,
    required this.onDone,
  });

  final String message;
  final bool success;
  final VoidCallback onDone;

  @override
  State<_AppToast> createState() => _AppToastState();
}

class _AppToastState extends State<_AppToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static final _totalMs = ComponentLayout.toastTotal.inMilliseconds;
  static final _fadeMs = ComponentLayout.toastFade.inMilliseconds;

  @override
  void initState() {
    super.initState();
    // 시간 흐름(나타남 → 머묾 → 사라짐)을 컨트롤러 하나로 만든다. 별도 타이머가 없어서
    // 화면이 먼저 사라져도 남는 것이 없다.
    _controller =
        AnimationController(vsync: this, duration: ComponentLayout.toastTotal)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) widget.onDone();
          })
          ..forward();
  }

  /// '확인': 머무는 시간을 건너뛰고 사라지는 구간부터 이어서 재생한다.
  void _dismiss() {
    final exitStart = (_totalMs - _fadeMs) / _totalMs;
    if (_controller.value < exitStart) {
      _controller
        ..value = exitStart
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottom =
        (MediaQuery.paddingOf(context).bottom > BottomNavTokens.bottomOffset
            ? MediaQuery.paddingOf(context).bottom
            : BottomNavTokens.bottomOffset) +
        BottomNavTokens.height +
        ComponentLayout.toastGapAboveNav;

    return Positioned(
      left: AppSpacing.pageMargin,
      right: AppSpacing.pageMargin,
      bottom: bottom,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final ms = _controller.value * _totalMs;
          final enter = (ms / _fadeMs).clamp(0.0, 1.0);
          final exit = ((_totalMs - ms) / _fadeMs).clamp(0.0, 1.0);
          return Opacity(
            opacity: enter < exit ? enter : exit,
            child: Transform.translate(
              offset: Offset(0, (1 - enter) * ComponentLayout.toastRiseOffset),
              child: child,
            ),
          );
        },
        child: Semantics(
          liveRegion: true,
          container: true,
          child: DefaultTextStyle.merge(
            style: const TextStyle(decoration: TextDecoration.none),
            child: Container(
              constraints: const BoxConstraints(
                minHeight: ComponentLayout.toastHeight,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: ComponentLayout.toastPaddingH,
              ),
              decoration: BoxDecoration(
                color: colors.cardWhite,
                borderRadius: AppRadii.pillBorderRadius,
                border: Border.all(
                  color: colors.toastBorder,
                  width: ComponentLayout.toastBorderWidth,
                ),
                boxShadow: AppShadows.toast,
              ),
              child: Row(
                children: [
                  if (widget.success) ...[
                    ExcludeSemantics(
                      child: Container(
                        width: ComponentLayout.toastCheckSize,
                        height: ComponentLayout.toastCheckSize,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colors.toastCheckFill,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '✓',
                          style: AppTextStyles.toastCheck.copyWith(
                            color: colors.toastAccent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: ComponentLayout.toastGap),
                  ],
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.space8,
                      ),
                      child: Text(
                        widget.message,
                        style: AppTextStyles.toastMessage.copyWith(
                          color: colors.toastText,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: ComponentLayout.toastGap),
                  Semantics(
                    container: true,
                    button: true,
                    label: '확인',
                    excludeSemantics: true,
                    onTap: _dismiss,
                    child: Pressable(
                      onTap: _dismiss,
                      child: SizedBox(
                        width: ComponentLayout.toastActionWidth,
                        height: AppSpacing.minTouchTarget,
                        child: Center(
                          child: Text(
                            '확인',
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.visible,
                            style: AppTextStyles.toastAction.copyWith(
                              color: colors.toastAccent,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
