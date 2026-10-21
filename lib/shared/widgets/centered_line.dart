import 'package:flutter/material.dart';

/// 고정 높이 상자 안에서 글자를 세로 가운데에 놓는다.
/// Figma는 줄 높이(예: 32)가 상자(예: 16)보다 커도 글자를 상자 가운데에 맞추는데,
/// Flutter의 [Text]는 상자 위쪽부터 놓이므로 넘치는 만큼 위아래로 똑같이 나눈다.
class CenteredLine extends StatelessWidget {
  const CenteredLine({
    super.key,
    required this.height,
    required this.child,
    this.alignment = Alignment.centerLeft,
  });

  final double height;
  final Widget child;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      // 가로가 정해져 있지 않은 자리(Positioned의 left만 준 경우)에서는 글자 폭만큼만 차지한다.
      child: IntrinsicWidth(
        child: OverflowBox(
          alignment: alignment,
          minHeight: 0,
          maxHeight: _maxChildHeight,
          child: child,
        ),
      ),
    );
  }

  /// 자식이 상자보다 커도 되는 한계(줄 높이 32 같은 값을 충분히 담는 유한한 값).
  static const _maxChildHeight = 200.0;
}
