import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

/// 글자 입력창: 흰 둥근 상자 + 얇은 테두리, 포커스는 브랜드 핑크, 오류는 빨강 + 아래 문구.
/// [label]이 있으면 위에 작은 제목이 붙는다. (docs/DESIGN_SYSTEM.md 7장 입력)
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.onChanged,
    this.onSubmitted,
    this.fieldKey,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.enabled = true,
    this.autofocus = false,
    this.suffix,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;

  /// 오류가 없을 때 아래에 보이는 도움말.
  final String? helperText;
  final String? errorText;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Key? fieldKey;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool enabled;
  final bool autofocus;

  /// 입력창 오른쪽 끝에 놓는 것(예: 비밀번호 보기 버튼).
  final Widget? suffix;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.button),
      borderSide: BorderSide(
        color: color,
        width: ComponentLayout.inputBorderWidth,
      ),
    );

    final field = TextField(
      key: fieldKey,
      controller: controller,
      maxLength: maxLength,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      enabled: enabled,
      autofocus: autofocus,
      inputFormatters: inputFormatters,
      cursorColor: colors.brand,
      style: AppTextStyles.buttonLarge.copyWith(
        color: enabled ? colors.textBlack : colors.textSecondary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.buttonLarge.copyWith(
          color: colors.textSecondary.withValues(alpha: 0.6),
        ),
        helperText: errorText == null ? helperText : null,
        helperStyle: AppTextStyles.caption.copyWith(
          color: colors.textSecondary,
        ),
        errorText: errorText,
        errorStyle: AppTextStyles.caption.copyWith(color: colors.danger),
        counterStyle: AppTextStyles.caption.copyWith(
          color: colors.textSecondary,
        ),
        suffixIcon: suffix,
        filled: true,
        fillColor: enabled ? colors.cardWhite : colors.chip,
        contentPadding: const EdgeInsets.all(ComponentLayout.inputPadding),
        enabledBorder: border(colors.cardBorder),
        disabledBorder: border(colors.cardBorder),
        focusedBorder: border(colors.brand),
        errorBorder: border(colors.danger),
        focusedErrorBorder: border(colors.danger),
      ),
    );

    if (label == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label!,
          style: AppTextStyles.sectionLabel.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.space8),
        field,
      ],
    );
  }
}
