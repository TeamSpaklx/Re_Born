import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// 디자인이 없는 화면의 자리 표시: 흰 배경의 빈 화면.
/// 디자인이 나와 화면을 만들 때 이 위젯을 실제 화면으로 바꾼다.
class BlankScreen extends StatelessWidget {
  const BlankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: context.colors.background);
  }
}
