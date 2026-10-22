import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/features/people/models/person.dart';
import 'package:reborn_app/features/people/models/person_validator.dart';
import 'package:reborn_app/features/people/models/relation_type.dart';

void main() {
  Person p(String id, String name) => Person(
    id: id,
    name: name,
    relationType: RelationType.friend,
    createdAt: DateTime(2026),
  );

  test('T-07·T-08: 빈 이름, 21자, 중복 이름은 거부한다', () {
    final existing = [p('1', '하은')];
    expect(PersonValidator.validateName('', existing: existing), isNotNull);
    expect(
      PersonValidator.validateName('가' * 21, existing: existing),
      isNotNull,
    );
    expect(PersonValidator.validateName('하은', existing: existing), isNotNull);
    expect(PersonValidator.validateName('지민', existing: existing), isNull);
  });

  test('수정할 때는 자기 자신과의 같은 이름은 괜찮다', () {
    final existing = [p('1', '하은')];
    expect(
      PersonValidator.validateName('하은', existing: existing, editingId: '1'),
      isNull,
    );
  });

  test('인물 5명을 넘으면 더 추가할 수 없다', () {
    final five = [for (var i = 0; i < 5; i++) p('$i', '이름$i')];
    expect(PersonValidator.validateCanAdd(five), isNotNull);
    expect(PersonValidator.validateCanAdd(five.take(4).toList()), isNull);
  });
}
