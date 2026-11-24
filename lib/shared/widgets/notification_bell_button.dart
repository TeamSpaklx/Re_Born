import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/app_assets.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import 'pressable.dart';

/// 알림 종 버튼 (Figma NotiIcon `828:959`): 회색 10% 원(44) 안에 종(24).
/// 읽지 않은 알림이 있으면([unreadCount] > 0) 오른쪽 위에 분홍 점이 있는 종(`828:960`)으로 바뀐다.
class NotificationBellButton extends StatelessWidget {
  const NotificationBellButton({
    super.key,
    required this.onTap,
    this.unreadCount = 0,
  });

  final VoidCallback? onTap;

  /// 읽지 않은 알림 수. 점 표시와 접근성 라벨에 쓴다.
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final unread = unreadCount > 0;
    return Semantics(
      button: true,
      label: unread ? '알림, 읽지 않은 알림 $unreadCount개' : '알림',
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: Container(
          width: ComponentLayout.bellButtonSize,
          height: ComponentLayout.bellButtonSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.colors.bellButton,
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(
            unread ? AppAssets.bellUnread : AppAssets.bell,
            theme: SvgTheme(currentColor: context.colors.textBlack),
            width: ComponentLayout.bellIconSize,
            height: ComponentLayout.bellIconSize,
          ),
        ),
      ),
    );
  }
}
