import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show CustomSemanticsAction;
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/app_assets.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/utils/app_haptics.dart';

/// 오른쪽에서 왼쪽으로 밀어 지우는 행: 밀면 빨간 배경에 휴지통이 드러나고, 끝까지 밀면 [onDelete]가 불린다.
/// 접근성: 스크린 리더에는 "삭제" 동작이 따로 붙는다. [confirm]이 false를 돌려주면 제자리로 돌아온다.
class SwipeToDelete extends StatelessWidget {
  const SwipeToDelete({
    super.key,
    required this.dismissKey,
    required this.onDelete,
    required this.child,
    this.confirm,
  });

  final Key dismissKey;
  final VoidCallback onDelete;
  final Future<bool> Function()? confirm;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      customSemanticsActions: {
        const CustomSemanticsAction(label: '삭제'): onDelete,
      },
      child: Dismissible(
        key: dismissKey,
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) async {
          AppHaptics.tap();
          return confirm == null ? true : await confirm!();
        },
        onDismissed: (_) => onDelete(),
        background: const SizedBox.shrink(),
        secondaryBackground: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppSpacing.space24),
          decoration: BoxDecoration(
            color: colors.dangerTile,
            borderRadius: BorderRadius.circular(AppRadii.card - 8),
          ),
          child: SvgPicture.asset(
            AppAssets.trash,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(colors.danger, BlendMode.srcIn),
          ),
        ),
        child: child,
      ),
    );
  }
}
