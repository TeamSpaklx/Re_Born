import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/data_providers.dart';
import '../../../app/data_revision.dart';
import '../models/index_point.dart';
import '../models/insight.dart';

/// 한 인물의 지수 이력(날짜 오름차순).
final indexHistoryProvider = FutureProvider.family<List<IndexPoint>, String>((
  ref,
  personId,
) {
  ref.watch(dataRevisionProvider);
  return ref.watch(indexHistoryRepositoryProvider).list(personId);
});

/// 한 인물의 인사이트(최근 것이 먼저).
final insightsForPersonProvider = FutureProvider.family<List<Insight>, String>((
  ref,
  personId,
) {
  ref.watch(dataRevisionProvider);
  return ref.watch(insightsRepositoryProvider).list(personId: personId);
});
