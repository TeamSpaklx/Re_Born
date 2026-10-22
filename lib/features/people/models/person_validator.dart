import 'person.dart';

/// 인물 입력 검사 (SPEC F-02, T-07·T-08). 문제가 없으면 null, 있으면 안내 문구를 돌려준다.
abstract final class PersonValidator {
  static const maxNameLength = 20;

  /// 인물 수 제안값(5명).
  static const maxPeople = 5;

  /// [existing]에는 지금 저장된 인물들을, 수정할 때는 [editingId]에 자기 자신을 넣는다.
  static String? validateName(
    String name, {
    required List<Person> existing,
    String? editingId,
  }) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '이름을 입력해 주세요.';
    if (trimmed.length > maxNameLength) {
      return '이름은 $maxNameLength자 이내로 입력해 주세요.';
    }
    final duplicated = existing.any(
      (p) => p.id != editingId && p.name.trim() == trimmed,
    );
    if (duplicated) return '이미 있는 이름이에요.';
    return null;
  }

  /// 새 인물을 더할 수 있는지(5명 제안). 불가하면 안내 문구.
  static String? validateCanAdd(List<Person> existing) {
    if (existing.length >= maxPeople) {
      return '인물은 최대 $maxPeople명까지 등록할 수 있어요.';
    }
    return null;
  }
}
