import 'package:flutter/material.dart';

import '../../../../shared/widgets/character_avatar.dart';
import '../../../people/models/person.dart';

/// 인물 아바타: 감정 캐릭터를 임시 프로필로 쓴다(인물 id로 고정 배정). 사진 기능이 생기면 교체.
class PersonAvatar extends StatelessWidget {
  const PersonAvatar({super.key, required this.person, this.size = 52});

  final Person person;
  final double size;

  @override
  Widget build(BuildContext context) => CharacterAvatar(
    seed: person.id.isEmpty ? person.name : person.id,
    size: size,
  );
}
