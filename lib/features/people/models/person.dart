import 'relation_type.dart';

/// 기록과 관계 지수를 묶는 단위 (SPEC F-02, 테이블 `people`).
class Person {
  const Person({
    required this.id,
    required this.name,
    required this.relationType,
    required this.createdAt,
    this.memo,
  });

  final String id;

  /// 이름(별칭) 1~20자.
  final String name;
  final RelationType relationType;
  final String? memo;
  final DateTime createdAt;

  Person copyWith({String? name, RelationType? relationType, String? memo}) {
    return Person(
      id: id,
      name: name ?? this.name,
      relationType: relationType ?? this.relationType,
      memo: memo ?? this.memo,
      createdAt: createdAt,
    );
  }
}
