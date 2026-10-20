/// 하단 탭 바 치수. Figma `ButtonNavigator[Liquid Glass]`(289:1158)에서 읽은 값이며
/// 출처는 docs/DESIGN_SYSTEM.md.
///
/// iOS는 Figma 값 그대로(반투명 흰색 + 테두리 + 그림자), Android는 같은 치수에
/// 배경 블러를 더한다. Android 값은 Figma에 없어 추정이다.
abstract final class BottomNavTokens {
  static const width = 354.0;
  static const height = 64.0;

  /// 화면 아래(홈 인디케이터 위)에서 떨어진 거리.
  static const bottomOffset = 34.0;

  static const borderWidth = 1.0;
  static const shadowOffsetY = 4.0;
  static const shadowBlur = 25.0;
  static const shadowSpread = 4.0;

  static const itemWidth = 68.0;
  static const itemGap = 17.0;
  static const iconSize = 28.0;
  static const menusTop = 12.0;
  static const menusHeight = 40.0;

  static const selectionWidth = 92.0;
  static const selectionHeight = 56.0;

  /// 선택 알약의 왼쪽 x (투데이, 관계, 기록, 전체).
  static const selectionLefts = [5.0, 89.0, 174.0, 258.0];

  /// 탭 라벨 (Figma 노드 이름은 홈/관계/기록/마이지만 화면 글자는 아래와 같다).
  static const labels = ['투데이', '관계', '기록', '전체'];

  /// Android 블러 배경 (추정값, Figma 시안 없음, 확인 필요).
  static const androidBlurSigma = 20.0;
}
