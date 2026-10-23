import 'package:flutter/material.dart';

import '../../app/theme/app_assets.dart';
import '../../app/theme/app_colors.dart';

/// 임시 프로필 이미지: 감정 캐릭터 7종 중 [seed]로 하나를 고정 배정해 동그란 아바타로 그린다.
/// 같은 [seed]는 앱을 다시 켜도 같은 캐릭터다(인물 id, 사용자 구분 글자 등).
class CharacterAvatar extends StatelessWidget {
  const CharacterAvatar({
    super.key,
    required this.seed,
    this.size = 48,
    this.borderColor,
  });

  final String seed;
  final double size;
  final Color? borderColor;

  /// [seed] 글자 코드의 합으로 캐릭터를 고른다.
  static String assetFor(String seed) {
    final sum = seed.codeUnits.fold<int>(0, (a, b) => a + b);
    return AppAssets.emotionImages[sum % AppAssets.emotionImages.length];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.only(top: size * 0.1),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colors.avatar,
          shape: BoxShape.circle,
          border: borderColor == null
              ? null
              : Border.all(color: borderColor!, width: 2),
        ),
        child: Image.asset(
          assetFor(seed),
          fit: BoxFit.contain,
          alignment: Alignment.bottomCenter,
          cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).ceil(),
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}
