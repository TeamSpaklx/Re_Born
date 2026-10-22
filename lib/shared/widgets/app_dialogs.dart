import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';
import '../../app/theme/app_text_styles.dart';

/// 확인 팝업. 확인을 누르면 true, 취소·바깥을 누르면 false. 임시 디자인.
Future<bool> showAppConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = '확인',
  String? cancelLabel = '취소',
}) async {
  final colors = context.colors;
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: colors.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadii.cardBorderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.sectionTitle.copyWith(
                color: colors.textBlack,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.body.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (cancelLabel != null)
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      cancelLabel,
                      style: AppTextStyles.button.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    confirmLabel,
                    style: AppTextStyles.button.copyWith(color: colors.brand),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}

/// 화면 아래에 잠깐 뜨는 안내.
void showAppSnackBar(BuildContext context, String message) {
  final colors = context.colors;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 120),
        backgroundColor: colors.textStrong,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.pillBorderRadius),
        content: Text(
          message,
          style: AppTextStyles.body.copyWith(color: colors.onCta),
        ),
      ),
    );
}
