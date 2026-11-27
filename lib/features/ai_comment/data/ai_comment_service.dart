import '../../entries/models/entry.dart';
import '../models/ai_feedback.dart';

/// 일기를 AI로 분석해 코멘트와 행동 제안을 받아 오는 곳.
///
/// **교체 지점.** 지금은 [FakeAiCommentService]가 앱 안 문장 풀에서 고른다.
/// 백엔드가 API(예: Supabase Edge Function)를 만들면 그 API를 부르는 구현으로 바꾼다.
/// 외부 AI API 키는 서버에만 두고 앱 코드에는 넣지 않는다.
abstract interface class AiCommentService {
  /// 실패하면 예외를 던진다. 기록은 `failed`가 되고 "다시 분석"으로 재시도한다.
  Future<AiFeedback> analyze(Entry entry, {required CommentTone tone});
}
