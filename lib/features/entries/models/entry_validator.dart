import 'intensity_level.dart';

/// 기록 입력 검사 (SPEC F-03, T-11·T-12). 문제가 없으면 null, 있으면 안내 문구.
abstract final class EntryValidator {
  static const maxBodyLength = 2000;

  static String? validateBody(String body) {
    if (body.trim().isEmpty) return '내용을 입력해 주세요.';
    if (body.length > maxBodyLength) {
      return '내용은 $maxBodyLength자 이내로 입력해 주세요.';
    }
    return null;
  }

  /// 강도는 1~5단계 기준표([IntensityLevel]) 중 하나여야 한다.
  static String? validateIntensity(int? intensity) {
    if (IntensityLevel.of(intensity) == null) {
      return '강도를 선택해 주세요.';
    }
    return null;
  }

  /// 미래 날짜는 쓸 수 없다.
  static String? validateCreatedAt(DateTime createdAt, DateTime now) {
    if (createdAt.isAfter(now)) return '미래 날짜는 선택할 수 없어요.';
    return null;
  }
}
