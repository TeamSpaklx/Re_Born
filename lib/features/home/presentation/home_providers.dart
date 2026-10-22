import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/data_providers.dart';
import '../../../app/data_revision.dart';
import '../../../core/providers/clock_provider.dart';
import '../../analysis/home_summary_builder.dart';
import '../models/home_summary.dart';

/// 홈 화면 데이터. 저장소들에서 읽어 앱이 조립한다(`buildHomeSummary`).
/// 기록·체크리스트 등이 바뀌면([dataRevisionProvider]) 다시 만든다.
/// 실패하면 자동 재시도 없이 오류 화면의 "다시 시도"로 다시 부른다.
final homeSummaryProvider = FutureProvider<HomeSummary>((ref) async {
  ref.watch(dataRevisionProvider);
  final now = ref.watch(clockProvider)();
  final settings = await ref.watch(settingsRepositoryProvider).get();
  final entries = await ref.watch(entriesRepositoryProvider).list();
  final people = await ref.watch(peopleRepositoryProvider).list();
  final insights = await ref.watch(insightsRepositoryProvider).list();
  final todos = await ref.watch(todosRepositoryProvider).list();
  return buildHomeSummary(
    nickname: settings.nickname,
    now: now,
    entries: entries,
    people: people,
    insights: insights,
    todos: todos,
  );
}, retry: (retryCount, error) => null);
