import '../models/index_point.dart';
import '../models/insight.dart';

/// 인사이트 저장소 (테이블 `insights`). 본인 행만 접근(RLS).
abstract interface class InsightsRepository {
  /// 최근 것이 먼저. [personId]를 주면 그 인물 것만.
  Future<List<Insight>> list({String? personId});

  Future<Insight?> get(String id);

  /// 이미 만들어진 인사이트를 저장한다(id는 앱이 정함).
  Future<void> save(Insight insight);

  Future<void> markRead(String id);

  Future<void> deleteForPerson(String personId);

  Future<void> deleteAll();
}

/// 관계 지수 일별 이력 저장소 (테이블 `index_history`, 인물·날짜가 유일 키).
abstract interface class IndexHistoryRepository {
  /// 날짜 오름차순. [from]을 주면 그 날짜 이후만.
  Future<List<IndexPoint>> list(String personId, {DateTime? from});

  /// 같은 인물·날짜가 있으면 덮어쓴다.
  Future<void> upsert(IndexPoint point);

  /// 그 인물의 그날 지수를 지운다("데이터 부족"이 되었을 때).
  Future<void> delete(String personId, DateTime date);

  Future<void> deleteForPerson(String personId);

  Future<void> deleteAll();
}
