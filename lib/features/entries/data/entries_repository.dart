import '../models/emotion.dart';
import '../models/entry.dart';

/// 기록 저장소 (테이블 `entries`). 본인 행만 접근(RLS).
abstract interface class EntriesRepository {
  /// 최근 기록이 먼저 오도록 돌려준다. [personId]를 주면 그 인물 기록만.
  Future<List<Entry>> list({String? personId});

  Future<Entry?> get(String id);

  /// 새 기록을 `pending` 상태로 저장하고 id를 붙여 돌려준다.
  Future<Entry> create({
    required String body,
    required Emotion emotion,
    required int intensity,
    required int score,
    required DateTime createdAt,
    String? personId,
  });

  /// 본문·인물·감정·강도·점수·분석 상태·분석 결과를 갱신한다.
  Future<void> update(Entry entry);

  Future<void> delete(String id);

  Future<void> deleteAll();
}
