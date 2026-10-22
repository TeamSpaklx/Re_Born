/// 위기 표현 점검 (SPEC F-13, P-12). 앱 안 키워드 목록과 비교만 하고, 감지 여부는 저장하지 않는다.
/// 감지되어도 기록 저장은 그대로 진행한다. 키워드 범위는 보수적으로 두고,
/// 안내 연락처와 최종 목록은 **출시 전에 공식 기관 안내로 확인**해야 한다(SPEC 11장 12번).
abstract final class CrisisChecker {
  static const keywords = [
    '죽고 싶',
    '죽고싶',
    '자살',
    '자해',
    '사라지고 싶',
    '살기 싫',
    '목숨을 끊',
  ];

  static bool containsCrisisExpression(String body) {
    final text = body.replaceAll(RegExp(r'\s+'), ' ');
    return keywords.any(text.contains);
  }
}
