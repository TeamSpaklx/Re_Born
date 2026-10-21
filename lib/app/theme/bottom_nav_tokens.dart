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

  /// iOS 26+ 네이티브 탭 바는 시스템이 알약을 플랫폼 뷰 좌우에서 이만큼 안쪽에 그린다
  /// (iOS 26.5, 27.0 시뮬레이터에서 측정: 뷰 폭 396 → 알약 폭 354). 알약 폭을 [width]로
  /// 맞추려고 플랫폼 뷰를 양쪽으로 이만큼 더 넓게 만든다. 알약 높이는 시스템이 약 62로 정한다.
  static const nativeSideInset = 21.0;

  /// 네이티브 탭 바 라벨 글꼴의 PostScript 이름(`AppAssets.pretendardBold` 파일).
  static const nativeLabelFontName = 'Pretendard-Bold';

  /// 탭 바 뒤에서 내용이 흰색으로 흐려지는 구간의 높이 (Scroll Edge Effect, 추정).
  static const scrollEdgeFadeHeight = 120.0;

  /// iOS 점진 블러의 최대 강도. Figma 변수 `Scroll Edge Effect/Blur Radius` = 10.
  static const scrollEdgeBlurSigma = 10.0;

  /// 배경색 베일의 최대 불투명도(영역 45% 지점)와 화면 맨 아래 불투명도 (추정값).
  /// 맨 아래까지 완전히 가리지 않아 내용이 흐리게 비쳐 보인다.
  static const scrollEdgeVeilPeak = 0.7;
  static const scrollEdgeVeilEnd = 0.4;

  /// 점진 블러를 나누는 띠 개수 (추정값. 많을수록 부드럽지만 BackdropFilter가 늘어난다).
  static const scrollEdgeBlurBands = 8;

  /// 스크롤 화면 맨 아래 여백: 탭 바 아래 34 + 탭 바 64 + 마지막 카드와의 간격 50.
  static const scrollBottomPadding = 148.0;
}
