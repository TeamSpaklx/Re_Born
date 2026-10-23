import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/app_assets.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import 'character_avatar.dart';
import 'pressable.dart';

/// 프로필 행: 둥근 아바타 + 이름 + 보조 문구 + 화살표 (전체 탭 맨 위, 인물 목록).
/// [avatar]가 없으면 회색 원 + 사람 아이콘.
class ProfileRow extends StatelessWidget {
  const ProfileRow({
    super.key,
    required this.title,
    this.subtitle,
    this.avatar,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? avatar;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space12),
      child: Row(
        children: [
          ClipOval(
            child: SizedBox(
              width: ComponentLayout.profileAvatarSize,
              height: ComponentLayout.profileAvatarSize,
              child:
                  avatar ??
                  const CharacterAvatar(
                    seed: 'me',
                    size: ComponentLayout.profileAvatarSize,
                  ),
            ),
          ),
          const SizedBox(width: AppSpacing.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.actionTitle.copyWith(
                    color: colors.textBlack,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (onTap != null) SvgPicture.asset(AppAssets.chevronSignal),
        ],
      ),
    );
    if (onTap == null) return row;
    return Semantics(
      button: true,
      label: subtitle == null ? title : '$title, $subtitle',
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(onTap: onTap, child: row),
    );
  }
}
