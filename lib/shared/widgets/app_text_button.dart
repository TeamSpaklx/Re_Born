import 'package:flutter/material.dart';

import '../../app/theme/app_text_styles.dart';
import 'pressable.dart';

/// 글자만 있는 버튼 ("수정", "인물 추가" 등). 머티리얼 `TextButton`을 대신한다(번짐 효과 없음).
class AppTextButton extends StatelessWidget {
  const AppTextButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              widthFactor: 1,
              child: Text(
                label,
                style: AppTextStyles.button.copyWith(color: color),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
