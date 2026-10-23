import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../entries/presentation/widgets/emotion_chip.dart';
import '../../../entries/models/emotion.dart';
import '../../../people/models/person.dart';
import '../../../people/models/relation_type.dart';

/// 인물 아바타: 관계 유형별 파스텔 색 원 + 이름 첫 글자(사진 대신).
class PersonAvatar extends StatelessWidget {
  const PersonAvatar({super.key, required this.person, this.size = 52});

  final Person person;
  final double size;

  static Color colorFor(RelationType type, AppColors colors) {
    final emotion = switch (type) {
      RelationType.friend => Emotion.excitement,
      RelationType.family => Emotion.gratitude,
      RelationType.teacher => Emotion.calm,
      RelationType.coworker => Emotion.hurt,
      RelationType.other => Emotion.anxiety,
    };
    return emotionColor(emotion, colors);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final name = person.name.trim();
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colorFor(person.relationType, colors),
          shape: BoxShape.circle,
        ),
        child: Text(
          name.isEmpty ? '?' : name.characters.first,
          style: AppTextStyles.sectionTitle.copyWith(
            color: colors.textStrong,
            fontSize: size * 0.4,
            height: 1,
          ),
        ),
      ),
    );
  }
}
