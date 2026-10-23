import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

/// 글자 입력창. 임시 디자인: 흰 카드 + 테두리 2px(홈 카드 값), 포커스 시 `brand` 테두리.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.hint,
    this.errorText,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.fieldKey,
  });

  final TextEditingController controller;
  final String? hint;
  final String? errorText;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final Key? fieldKey;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.button),
      borderSide: BorderSide(color: color, width: AppSpacing.cardBorderWidth),
    );

    return TextField(
      key: fieldKey,
      controller: controller,
      maxLength: maxLength,
      maxLines: maxLines,
      minLines: minLines,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      cursorColor: colors.brand,
      style: AppTextStyles.body.copyWith(color: colors.textBlack),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body.copyWith(
          color: colors.textSecondary.withValues(alpha: 0.6),
        ),
        errorText: errorText,
        errorStyle: AppTextStyles.caption.copyWith(color: colors.brand),
        counterStyle: AppTextStyles.caption.copyWith(
          color: colors.textSecondary,
        ),
        filled: true,
        fillColor: colors.cardWhite,
        contentPadding: const EdgeInsets.all(16),
        enabledBorder: border(colors.cardBorder),
        focusedBorder: border(colors.brand),
        errorBorder: border(colors.brand),
        focusedErrorBorder: border(colors.brand),
      ),
    );
  }
}
