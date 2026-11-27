import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 한 가지 색으로 칠해지는 SVG 아이콘. 파일에 박힌 색(밝은 배경 전제) 대신 [color]를 입혀서
/// 라이트·다크에서 모두 보이게 한다. 두 색 이상인 아이콘에는 쓰지 않는다.
class TintedSvg extends StatelessWidget {
  const TintedSvg(
    this.asset, {
    super.key,
    required this.color,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  final String asset;
  final Color color;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: width,
      height: height,
      fit: fit,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
