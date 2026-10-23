import 'package:flutter/material.dart';

import '../../../../app/theme/app_assets.dart';
import '../../models/emotion.dart';

/// 감정 캐릭터(여우원숭이): 달력·선택 격자·기록 카드·상세 어디서나 같은 위젯을 쓴다.
/// 장식이므로 스크린 리더는 읽지 않는다(감정 이름은 옆 글자가 읽는다).
class EmotionFace extends StatelessWidget {
  const EmotionFace({super.key, required this.emotion, this.size = 40});

  final Emotion emotion;
  final double size;

  /// 감정별 이미지 경로.
  static String assetOf(Emotion emotion) => switch (emotion) {
    Emotion.joy => AppAssets.emotionJoy,
    Emotion.sadness => AppAssets.emotionSadness,
    Emotion.neutral => AppAssets.emotionNeutral,
    Emotion.anger => AppAssets.emotionAnger,
    Emotion.anxiety => AppAssets.emotionAnxiety,
    Emotion.love => AppAssets.emotionLove,
    Emotion.excited => AppAssets.emotionExcited,
  };

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Image.asset(
        assetOf(emotion),
        width: size,
        height: size,
        fit: BoxFit.contain,
        // 큰 원본을 작은 크기로 그리므로 디코딩 크기를 제한한다.
        cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).ceil(),
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}
