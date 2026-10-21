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

  /// 항목 4개를 균등 분할하는 좌우 안쪽 여백 (354 기준: 항목 중심이 Figma와 ±1.5px 안에서 일치).
  static const columnInset = 7.0;

  /// Android 블러 배경 (추정값, Figma 시안 없음, 확인 필요).
  static const androidBlurSigma = 20.0;

  /// iOS 배경 블러 (추정값). Flutter에는 iOS 26 Liquid Glass를 그리는 기능이 없어
  /// Figma 값(반투명 흰색 + 테두리 + 그림자)에 약한 블러만 더한다. 흰 배경 위에서는
  /// Figma와 차이가 보이지 않는다.
  static const iosBlurSigma = 8.0;

  /// 탭 바 뒤에서 내용이 흰색으로 흐려지는 구간의 높이 (Scroll Edge Effect, 추정).
  static const scrollEdgeFadeHeight = 185.0;

  /// 스크롤 화면 맨 아래 여백: 탭 바 아래 34 + 탭 바 64 + 마지막 카드와의 간격 50.
  static const scrollBottomPadding = 148.0;
}
