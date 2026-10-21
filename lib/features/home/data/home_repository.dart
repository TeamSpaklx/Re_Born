import '../models/home_summary.dart';

/// 홈 화면 데이터를 가져오는 곳. 화면은 이 인터페이스만 본다.
/// 지금은 [FakeHomeRepository], 백엔드가 `SupabaseHomeRepository`를 만들면 provider 한 줄만 바꾼다.
abstract interface class HomeRepository {
  /// [today] 기준의 홈 데이터. 실패하면 예외를 던진다.
  Future<HomeSummary> fetchHome(DateTime today);
}
