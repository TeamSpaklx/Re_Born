import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';
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

/// 화면 아래(탭 바 위)에 잠깐 떴다 사라지는 안내. Reborn 토스트: 어두운 둥근 상자 + 흰 글자,
/// 아래에서 올라오며 나타나고 약 3초 뒤 사라진다(새 토스트가 오면 이전 것은 바로 바뀐다).
/// 머티리얼 `SnackBar`를 대신한다. 터치는 아래 화면으로 그대로 통과한다.
void showAppToast(BuildContext context, String message) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;
  _activeToast?.remove();
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _AppToast(
      message: message,
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
  const _AppToast({required this.message, required this.onDone});

  final String message;
  final VoidCallback onDone;

  @override
  State<_AppToast> createState() => _AppToastState();
}

class _AppToastState extends State<_AppToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

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
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final ms =
                _controller.value * ComponentLayout.toastTotal.inMilliseconds;
            final fade = ComponentLayout.toastFade.inMilliseconds;
            final total = ComponentLayout.toastTotal.inMilliseconds;
            final enter = (ms / fade).clamp(0.0, 1.0);
            final exit = ((total - ms) / fade).clamp(0.0, 1.0);
            return Opacity(
              opacity: enter < exit ? enter : exit,
              child: Transform.translate(
                offset: Offset(
                  0,
                  (1 - enter) * ComponentLayout.toastRiseOffset,
                ),
                child: child,
              ),
            );
          },
          child: Align(
            child: Semantics(
              liveRegion: true,
              child: DefaultTextStyle.merge(
                style: const TextStyle(decoration: TextDecoration.none),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ComponentLayout.toastPaddingH,
                    vertical: ComponentLayout.toastPaddingV,
                  ),
                  decoration: BoxDecoration(
                    color: colors.toastFill,
                    borderRadius: AppRadii.toastBorderRadius,
                  ),
                  child: Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(color: colors.onCta),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
