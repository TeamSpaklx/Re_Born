import '../models/person.dart';
import '../models/relation_type.dart';

/// 인물 저장소 (테이블 `people`). 백엔드가 Supabase로 구현하고 provider 한 줄로 교체한다.
/// 모든 읽기·쓰기는 로그인한 사용자 본인의 행만 대상이다(RLS).
abstract interface class PeopleRepository {
  Future<List<Person>> list();

  /// id는 저장소가 정한다.
  Future<Person> create({
    required String name,
    required RelationType relationType,
    String? memo,
  });

  Future<void> update(Person person);

  Future<void> delete(String id);

  /// 사용자의 모든 인물 삭제(설정의 데이터 삭제).
  Future<void> deleteAll();
}
