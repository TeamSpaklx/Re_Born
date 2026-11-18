import 'package:flutter/material.dart';
import 'package:flutter/physics.dart' show SpringSimulation;
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/app_assets.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_motion.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import 'pressable.dart';

/// 아래에서 올라오는 시트 (Figma 바텀시트 `834:1374`, 화면 예시 `828:115`).
///
/// 화면 좌우 24를 띄운 흰 카드(모서리 34)가 홈 인디케이터 바로 위에 떠 있다. 맨 위 손잡이, 굵은 제목(+ 설명),
/// 그 아래 [builder]의 내용. 시트 안 행동 목록은 [SheetActionRow](아이콘 + 글자), 선택 목록은 [SheetOptionRow]를 쓴다.
///
/// 토스처럼 시트 **어디를 잡아도** 손가락을 따라 움직인다. 놓았을 때 높이의 25% 넘게 내렸거나 아래로 빠르게
/// 튕기면 닫히고, 아니면 스프링으로 제자리에 돌아온다. 위로 끌면 저항이 붙어 조금만 늘어난다. 끌어내리는 만큼
/// 뒤 가림막(검정 50%)이 옅어지고, 가림막을 누르거나 뒤로 가기를 해도 닫힌다. 내용이 길어 스크롤되면 맨 위에서
/// 더 끌어내릴 때 시트가 내려간다. 닫을 때 값은 `Navigator.pop(context, 값)`.
/// 머티리얼 `showModalBottomSheet`+`ListTile` 대신 쓴다.
Future<T?> showAppBottomSheet<T>(
  BuildContext context, {
  String? title,
  String? message,
  required WidgetBuilder builder,
}) {
  // 탭 화면 안에서 열어도 하단 탭 바 위로 올라오도록 가장 바깥 Navigator에 올린다.
  return Navigator.of(context, rootNavigator: true).push<T>(
    _AppSheetRoute<T>(
      builder: (context) => _AppBottomSheet(
        title: title,
        message: message,
        child: Builder(builder: builder),
      ),
    ),
  );
}

/// 가림막·끌기를 시트가 직접 그리도록 비워 둔 팝업 라우트(투명, 바깥 누르기는 시트의 가림막이 처리).
class _AppSheetRoute<T> extends PopupRoute<T> {
  _AppSheetRoute({required this.builder});

  final WidgetBuilder builder;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => AppMotion.normal;

  @override
  Duration get reverseTransitionDuration => AppMotion.fast;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => builder(context);
}

class _AppBottomSheet extends StatefulWidget {
  const _AppBottomSheet({this.title, this.message, required this.child});

  final String? title;
  final String? message;
  final Widget child;

  @override
  State<_AppBottomSheet> createState() => _AppBottomSheetState();
}

class _AppBottomSheetState extends State<_AppBottomSheet>
    with SingleTickerProviderStateMixin {
  /// 시트가 손가락에 끌려 아래로 밀린 거리(위로 끌면 음수). 놓으면 스프링으로 0에 돌아온다.
  late final AnimationController _drag = AnimationController.unbounded(
    vsync: this,
  );
  final _cardKey = GlobalKey();
  late final ScrollPhysics _scrollPhysics = _SheetScrollPhysics(
    onUserOffset: _consumeScroll,
  );
  bool _closing = false;

  @override
  void dispose() {
    _drag.dispose();
    super.dispose();
  }

  /// 카드 높이. 첫 프레임처럼 아직 모르면 화면 높이로 본다(그래도 화면 밖에서 시작한다).
  double get _cardHeight {
    final box = _cardKey.currentContext?.findRenderObject() as RenderBox?;
    return (box != null && box.hasSize)
        ? box.size.height
        : MediaQuery.sizeOf(context).height;
  }

  /// 위로 끈 거리는 고무줄처럼 점점 덜 따라오게(최대 [ComponentLayout.sheetOverDrag]) 줄인다.
  static double _visible(double offset) {
    if (offset >= 0) return offset;
    const max = ComponentLayout.sheetOverDrag;
    return -max * (1 - 1 / (1 + -offset / max));
  }

  void _dragBy(double delta) {
    if (_closing) return;
    _drag.value += delta;
  }

  /// 손을 뗐을 때: 충분히 내렸거나 아래로 빠르게 튕겼으면 닫고, 아니면 스프링으로 제자리.
  void _release(double velocity) {
    if (_closing) return;
    final offset = _drag.value;
    final farEnough =
        offset > _cardHeight * ComponentLayout.sheetDismissFraction;
    final flung =
        offset >= 0 && velocity > ComponentLayout.sheetDismissVelocity;
    if (farEnough || flung) {
      _close();
      return;
    }
    if (offset == 0) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _drag.value = 0;
      return;
    }
    _drag.animateWith(
      SpringSimulation(AppMotion.sheetSpring, offset, 0, velocity),
    );
  }

  void _close() {
    if (_closing) return;
    _closing = true;
    _drag.stop();
    // 라우트가 닫히며 지금 끌린 위치에서 이어서 내려간다.
    Navigator.of(context).pop();
  }

  /// 내용 스크롤 뷰가 받은 손가락 이동을 시트가 먼저 쓴다: 시트가 내려가 있거나, 맨 위에서 아래로 끌 때.
  /// 쓰고 남은 이동만 스크롤에 돌려준다(손가락 아래 방향이 양수).
  double _consumeScroll(double delta, bool atTop) {
    if (_closing) return 0;
    final offset = _drag.value;
    if (offset > 0 || (atTop && delta > 0)) {
      _drag.stop();
      final next = offset + delta;
      if (next < 0) {
        _drag.value = 0;
        return next;
      }
      _drag.value = next;
      return 0;
    }
    return delta;
  }

  bool _onScrollNotification(ScrollNotification n) {
    if (n is ScrollStartNotification && n.dragDetails != null) {
      _drag.stop();
    } else if (n is ScrollEndNotification && _drag.value != 0) {
      _release(n.dragDetails?.primaryVelocity ?? 0);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final media = MediaQuery.of(context);
    final safeBottom = media.viewPadding.bottom;
    final bottomGap = safeBottom > ComponentLayout.sheetMinBottomGap
        ? safeBottom
        : ComponentLayout.sheetMinBottomGap;
    final route = CurvedAnimation(
      parent: ModalRoute.of(context)!.animation!,
      curve: AppMotion.enter,
      reverseCurve: AppMotion.exit,
    );

    final card = Container(
      key: _cardKey,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.cardWhite,
        borderRadius: AppRadii.sheetBorderRadius,
        boxShadow: AppShadows.sheet,
      ),
      padding: const EdgeInsets.fromLTRB(
        ComponentLayout.sheetPaddingH,
        ComponentLayout.sheetPaddingTop,
        ComponentLayout.sheetPaddingH,
        ComponentLayout.sheetPaddingBottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: ComponentLayout.sheetHandleWidth,
              height: ComponentLayout.sheetHandleHeight,
              decoration: BoxDecoration(
                color: colors.sheetHandle,
                borderRadius: BorderRadius.circular(
                  ComponentLayout.sheetHandleRadius,
                ),
              ),
            ),
          ),
          const SizedBox(height: ComponentLayout.sheetHandleGap),
          if (widget.title != null || widget.message != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ComponentLayout.sheetHeaderPaddingH,
                0,
                ComponentLayout.sheetHeaderPaddingH,
                ComponentLayout.sheetHeaderGap,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.title != null)
                    Semantics(
                      header: true,
                      child: Text(
                        widget.title!,
                        style: AppTextStyles.sheetTitle.copyWith(
                          color: colors.sheetTitle,
                        ),
                      ),
                    ),
                  if (widget.message != null) ...[
                    const SizedBox(height: AppSpacing.space4),
                    Text(
                      widget.message!,
                      style: AppTextStyles.body.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          Flexible(
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScrollNotification,
              child: SingleChildScrollView(
                physics: _scrollPhysics,
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );

    return DefaultTextStyle.merge(
      style: const TextStyle(decoration: TextDecoration.none),
      child: AnimatedBuilder(
        animation: Listenable.merge([route, _drag]),
        builder: (context, child) {
          final height = _cardHeight;
          final pulled = (_drag.value / height).clamp(0.0, 1.0);
          final slide = (1 - route.value) * (height + bottomGap);
          return Stack(
            children: [
              Positioned.fill(
                child: Semantics(
                  label: '닫기',
                  button: true,
                  onTap: _close,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _close,
                    child: ColoredBox(
                      color: colors.scrim.withValues(
                        alpha: colors.scrim.a * route.value * (1 - pulled),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: ComponentLayout.sheetMargin,
                right: ComponentLayout.sheetMargin,
                bottom: bottomGap + media.viewInsets.bottom,
                child: Transform.translate(
                  offset: Offset(0, _visible(_drag.value) + slide),
                  child: child,
                ),
              ),
            ],
          );
        },
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight:
                media.size.height * ComponentLayout.sheetMaxHeightFraction -
                bottomGap -
                media.viewInsets.bottom,
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragStart: (_) => _drag.stop(),
            onVerticalDragUpdate: (d) => _dragBy(d.delta.dy),
            onVerticalDragEnd: (d) => _release(d.primaryVelocity ?? 0),
            onVerticalDragCancel: () => _release(0),
            // 입력창(TextField) 등은 머티리얼 조상이 필요하다. 색·그림자는 없는 투명 머티리얼.
            child: Material(type: MaterialType.transparency, child: card),
          ),
        ),
      ),
    );
  }
}

/// 시트 안 내용 스크롤: iOS에서도 바운스 없이(시트가 대신 내려가도록) 멈추고,
/// 손가락 이동을 먼저 시트에 넘겨 쓰고 남은 만큼만 스크롤한다.
class _SheetScrollPhysics extends ClampingScrollPhysics {
  const _SheetScrollPhysics({required this.onUserOffset, super.parent});

  /// (손가락 이동, 맨 위인지) → 스크롤에 쓸 남은 이동.
  final double Function(double delta, bool atTop) onUserOffset;

  @override
  _SheetScrollPhysics applyTo(ScrollPhysics? ancestor) => _SheetScrollPhysics(
    onUserOffset: onUserOffset,
    parent: buildParent(ancestor),
  );

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    final rest = onUserOffset(
      offset,
      position.pixels <= position.minScrollExtent,
    );
    return super.applyPhysicsToUserOffset(position, rest);
  }
}

/// 바텀시트 안의 행동 행 (Figma `763:51`): 높이 56, 왼쪽 아이콘 24 + 글자 16 Medium. 누르면 [onTap].
class SheetActionRow extends StatelessWidget {
  const SheetActionRow({
    super.key,
    required this.iconAsset,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  /// 한 가지 색 SVG. 행 글자색과 같은 색을 입힌다.
  final String iconAsset;
  final String label;
  final VoidCallback onTap;

  /// 되돌릴 수 없는 행동("기본 캐릭터로 되돌리기")이면 아이콘·글자를 위험 색으로 (Figma에 없음, 추정).
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final iconColor = destructive ? colors.danger : colors.sheetTitle;
    final textColor = destructive ? colors.danger : colors.sheetRowText;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: SizedBox(
          height: ComponentLayout.sheetOptionHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ComponentLayout.sheetHeaderPaddingH,
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  iconAsset,
                  width: ComponentLayout.sheetIconSize,
                  height: ComponentLayout.sheetIconSize,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
                const SizedBox(width: ComponentLayout.sheetIconGap),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.sheetRow.copyWith(color: textColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 바텀시트 안의 선택 행: 제목(+ 보조 문구) + 선택되면 오른쪽에 체크. 누르면 [onTap].
/// 높이·글자는 [SheetActionRow]와 같다(Figma `763:51`). 선택 상태는 Figma에 없어 브랜드 핑크 글자·체크로 표시(추정).
class SheetOptionRow extends StatelessWidget {
  const SheetOptionRow({
    super.key,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.selected = false,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: subtitle == null ? title : '$title, $subtitle',
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: ComponentLayout.sheetOptionHeight,
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ComponentLayout.sheetHeaderPaddingH,
                    vertical: AppSpacing.space12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.sheetRow.copyWith(
                          color: selected ? colors.brand : colors.sheetRowText,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: AppTextStyles.caption.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (selected)
                Padding(
                  padding: const EdgeInsets.only(
                    right: ComponentLayout.sheetHeaderPaddingH,
                  ),
                  child: SvgPicture.asset(
                    AppAssets.check,
                    width: 20,
                    colorFilter: ColorFilter.mode(
                      colors.brand,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
