import 'package:flutter/material.dart';

import '../../../app/theme/app_assets.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';

/// 앱 잠금 화면 (Figma 834:1480 잠금 상태, 834:2141 보안 실패).
///
/// 흰 배경 한가운데 로고(스플래시와 같은 크기·위치라 이어져 보인다). 시스템 인증 창은 이 위에 OS가 띄운다.
/// 인증에 실패하면 아래에 "인증에 실패하거나 비밀번호를 잊으셨나요?" 버튼이 나오고, 누르면 다시 인증한다
/// (기기 암호 허용).
class LockScreen extends StatelessWidget {
  const LockScreen({super.key, this.onRetry});

  /// null이면 버튼 없이 로고만(앱 전환 화면 덮개, 인증 중).
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: 'Re:Born 잠김',
      container: true,
      // 라우터(Material) 바깥에 그려져 기본 글자 스타일이 없으므로 직접 준다(노란 밑줄 방지).
      child: DefaultTextStyle(
        style: AppTextStyles.lockHelp.copyWith(color: colors.lockHelpText),
        child: ColoredBox(
          color: colors.splashBackground,
          child: Stack(
            children: [
              Center(
                child: Transform.translate(
                  offset: SplashLayout.logoOffset,
                  child: Image.asset(
                    AppAssets.logoMark,
                    width: SplashLayout.logoSize,
                    height: SplashLayout.logoSize,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
              if (onRetry != null)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: ComponentLayout.lockHelpBottom,
                      ),
                      child: _LockHelpButton(onTap: onRetry!),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 글자만 있는 버튼. 누르고 있으면 회색 알약 배경이 깔린다(Figma Pressed 834:2142).
class _LockHelpButton extends StatefulWidget {
  const _LockHelpButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_LockHelpButton> createState() => _LockHelpButtonState();
}

class _LockHelpButtonState extends State<_LockHelpButton> {
  bool _pressed = false;

  void _set(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      child: GestureDetector(
        key: const Key('lock-retry'),
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        onTap: widget.onTap,
        child: Container(
          width: ComponentLayout.lockHelpWidth,
          height: ComponentLayout.lockHelpHeight,
          alignment: Alignment.center,
          decoration: ShapeDecoration(
            color: _pressed
                ? colors.lockHelpPressed
                : colors.lockHelpPressed.withValues(alpha: 0),
            shape: const StadiumBorder(),
          ),
          child: Text(
            '인증에 실패하거나 비밀번호를 잊으셨나요?',
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.visible,
            style: AppTextStyles.lockHelp.copyWith(color: colors.lockHelpText),
          ),
        ),
      ),
    );
  }
}
