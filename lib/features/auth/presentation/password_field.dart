import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme/app_assets.dart';

import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/pressable.dart';
import '../../../shared/widgets/app_text_field.dart';

/// 비밀번호 입력창: 오른쪽 "보기/숨기기"로 글자를 보일지 정한다.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    this.fieldKey,
    this.hint,
    this.helperText,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String label;
  final Key? fieldKey;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      fieldKey: widget.fieldKey,
      controller: widget.controller,
      label: widget.label,
      hint: widget.hint,
      helperText: widget.helperText,
      errorText: widget.errorText,
      obscureText: _hidden,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      suffix: Semantics(
        button: true,
        label: _hidden ? '비밀번호 보기' : '비밀번호 숨기기',
        excludeSemantics: true,
        onTap: () => setState(() => _hidden = !_hidden),
        child: Pressable(
          onTap: () => setState(() => _hidden = !_hidden),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: SvgPicture.asset(
                _hidden ? AppAssets.ixEye : AppAssets.ixEyeOff,
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(
                  context.colors.textSecondary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
