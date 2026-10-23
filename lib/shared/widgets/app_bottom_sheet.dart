import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/app_assets.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_motion.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import 'pressable.dart';

/// 아래에서 올라오는 시트. 위쪽 모서리 28, 맨 위에 작은 핸들, 큰 제목 + 설명, 그 아래 [builder]의 내용.
/// 아래로 끌거나 바깥을 누르면 닫힌다(가림막 `scrim`). 시트 안 선택 목록에는 [SheetOptionRow]를 쓴다.
/// 머티리얼 `showModalBottomSheet`+`ListTile` 대신 쓴다. 닫을 때 값은 `Navigator.pop(context, 값)`.
Future<T?> showAppBottomSheet<T>(
  BuildContext context, {
  String? title,
  String? message,
  required WidgetBuilder builder,
}) {
  final colors = context.colors;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: colors.scrim,
    sheetAnimationStyle: AnimationStyle(
      duration: AppMotion.normal,
      reverseDuration: AppMotion.fast,
      curve: AppMotion.enter,
      reverseCurve: AppMotion.exit,
    ),
    builder: (context) => _AppBottomSheet(
      title: title,
      message: message,
      child: Builder(builder: builder),
    ),
  );
}

class _AppBottomSheet extends StatelessWidget {
  const _AppBottomSheet({this.title, this.message, required this.child});

  final String? title;
  final String? message;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final media = MediaQuery.of(context);
    return DefaultTextStyle.merge(
      style: const TextStyle(decoration: TextDecoration.none),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: media.size.height * ComponentLayout.sheetMaxHeightFraction,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: colors.cardWhite,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadii.dialog),
            ),
            boxShadow: AppShadows.overlay,
          ),
          padding: EdgeInsets.fromLTRB(
            AppSpacing.pageMargin,
            AppSpacing.space12,
            AppSpacing.pageMargin,
            AppSpacing.space24 + media.viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: ComponentLayout.sheetHandleWidth,
                  height: ComponentLayout.sheetHandleHeight,
                  decoration: BoxDecoration(
                    color: colors.toggleOff,
                    borderRadius: AppRadii.pillBorderRadius,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space20),
              if (title != null)
                Text(
                  title!,
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: colors.textBlack,
                  ),
                ),
              if (message != null) ...[
                const SizedBox(height: AppSpacing.space4),
                Text(
                  message!,
                  style: AppTextStyles.body.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
              if (title != null || message != null)
                const SizedBox(height: AppSpacing.space16),
              Flexible(child: SingleChildScrollView(child: child)),
            ],
          ),
        ),
      ),
    );
  }
}

/// 바텀시트 안의 선택 행: 제목(+ 보조 문구) + 선택되면 오른쪽에 체크. 누르면 [onTap].
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
                    vertical: AppSpacing.space12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.rowTitle.copyWith(
                          color: selected ? colors.brand : colors.textBlack,
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
                SvgPicture.asset(
                  AppAssets.check,
                  width: 20,
                  colorFilter: ColorFilter.mode(colors.brand, BlendMode.srcIn),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
