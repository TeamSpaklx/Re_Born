import 'package:flutter/widgets.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/widgets/app_bottom_sheet.dart';
import '../../../shared/widgets/pressable.dart';
import 'consent_texts.dart';

/// "[action]은 개인정보 보호 정책 및 서비스 약관에 동의하는 것으로 간주됩니다." (SPEC F-01)
/// 별도 동의 화면 대신 이 안내로 동의를 받는다. 두 문서는 각각 열 수 있는 링크다(밑줄은 추정 스타일).
/// 링크는 글자 인식기 대신 문장 안에 넣은 작은 탭 위젯이라, 탭과 스크린 리더 "링크"가 확실히 잡힌다.
class LegalNotice extends StatelessWidget {
  const LegalNotice({super.key, required this.action});

  /// 문장 앞머리: "로그인은" / "가입은".
  final String action;

  void _open(BuildContext context, String title, String body) {
    final colors = context.colors;
    showAppBottomSheet<void>(
      context,
      title: title,
      builder: (context) => Text(
        body,
        style: AppTextStyles.body.copyWith(
          color: colors.textSecondary,
          height: 1.6,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.loginLegal.copyWith(
      color: context.colors.loginLegalText,
    );
    InlineSpan link(String label, String title, String body) => WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: Semantics(
        link: true,
        label: label,
        excludeSemantics: true,
        onTap: () => _open(context, title, body),
        child: Pressable(
          key: Key('login-legal-$title'),
          onTap: () => _open(context, title, body),
          child: Text(
            label,
            style: style.copyWith(decoration: TextDecoration.underline),
          ),
        ),
      ),
    );
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: '$action '),
          link('개인정보 보호 정책', ConsentTexts.privacyTitle, ConsentTexts.privacy),
          const TextSpan(text: ' 및 '),
          link('서비스 약관', ConsentTexts.termsTitle, ConsentTexts.terms),
          const TextSpan(text: '에\n동의하는 것으로 간주됩니다.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
