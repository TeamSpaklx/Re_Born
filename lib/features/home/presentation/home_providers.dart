import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/fake_home_repository.dart';
import '../data/home_repository.dart';
import '../models/home_summary.dart';

/// 홈 데이터 출처. 백엔드가 준비되면 여기 한 줄만 `SupabaseHomeRepository(...)`로 바꾼다.
final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => const FakeHomeRepository(),
);

/// 오늘 날짜. 테스트에서 고정 날짜로 바꿀 수 있다.
final todayProvider = Provider<DateTime>((ref) => DateTime.now());

/// 홈 화면 데이터. 실패하면 자동 재시도 없이 오류 화면의 "다시 시도"로 다시 부른다.
final homeSummaryProvider = FutureProvider<HomeSummary>(
  (ref) =>
      ref.watch(homeRepositoryProvider).fetchHome(ref.watch(todayProvider)),
  retry: (retryCount, error) => null,
);
