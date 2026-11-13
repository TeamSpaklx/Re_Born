import 'dart:io';

import 'package:flutter/material.dart';

import 'character_avatar.dart';

/// 사용자 본인의 프로필 이미지: 고른 사진이 있으면 사진, 없거나 읽지 못하면 기본 캐릭터.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, this.photoPath, this.size = 56});

  final String? photoPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fallback = CharacterAvatar(seed: 'me', size: size);
    final path = photoPath;
    if (path == null) return fallback;
    return ExcludeSemantics(
      child: ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: Image.file(
            File(path),
            fit: BoxFit.cover,
            cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).ceil(),
            errorBuilder: (context, error, stack) => fallback,
          ),
        ),
      ),
    );
  }
}
