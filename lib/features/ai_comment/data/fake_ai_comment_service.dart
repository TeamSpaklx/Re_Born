import '../../entries/models/entry.dart';
import '../models/ai_feedback.dart';
import 'ai_comment_service.dart';

/// 백엔드 AI가 붙기 전까지 쓰는 가짜 AI. 감정의 방향(긍정·보통·부정), 강도 단계, 말투로
/// 앱 안 문장 풀에서 고른다. 같은 기록에는 항상 같은 코멘트가 나온다.
///
/// 강도 4~5의 부정 감정에도 차분한 문장만 쓴다. 위기 표현 안내는 저장할 때
/// `CrisisChecker`가 따로 보여 주므로 여기서는 겹쳐 말하지 않는다.
class FakeAiCommentService implements AiCommentService {
  const FakeAiCommentService({
    this.delay = const Duration(milliseconds: 800),
    required this.clock,
  });

  /// 실제 API처럼 잠깐 기다린다(결과 화면의 불러오는 모습을 보여 주려고).
  final Duration delay;
  final DateTime Function() clock;

  @override
  Future<AiFeedback> analyze(Entry entry, {required CommentTone tone}) async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    return FakeAiCommentService.compose(entry, tone: tone, now: clock());
  }

  /// 문장을 고르는 순수 함수(테스트용으로 따로 연다).
  static AiFeedback compose(
    Entry entry, {
    required CommentTone tone,
    required DateTime now,
  }) {
    final mood = switch (entry.emotion.polarity) {
      > 0 => _Mood.positive,
      < 0 => _Mood.negative,
      _ => _Mood.neutral,
    };
    final band = entry.intensity >= 4
        ? _Band.high
        : entry.intensity == 3
        ? _Band.mid
        : _Band.low;
    final seed = entry.body.codeUnits.fold<int>(0, (a, b) => a + b);
    final pool = _comments[(mood, band, tone)]!;
    final comment = pool[seed % pool.length];
    final ideas = _suggestions[(mood, band)]!;
    // 제안은 3개: 풀에서 seed 위치부터 이어서 고른다(풀이 3개라 순서만 달라진다).
    final picks = [
      for (var i = 0; i < 3; i++) ideas[(seed + i) % ideas.length],
    ];
    return AiFeedback(comment: comment, suggestions: picks, createdAt: now);
  }
}

enum _Mood { positive, neutral, negative }

enum _Band { low, mid, high }

const _comments = <(_Mood, _Band, CommentTone), List<String>>{
  // 긍정
  (_Mood.positive, _Band.low, CommentTone.warm): [
    '소소하지만 기분 좋은 하루였네요. 이런 순간들이 모여 마음을 단단하게 해 줘요.',
    '작은 기쁨을 알아차린 것만으로도 멋진 하루예요.',
  ],
  (_Mood.positive, _Band.mid, CommentTone.warm): [
    '오늘은 마음이 꽤 밝았네요! 무엇이 좋았는지 기억해 두면 힘든 날에 꺼내 볼 수 있어요.',
    '좋은 일이 있었군요. 그 기분을 충분히 누려도 괜찮아요.',
  ],
  (_Mood.positive, _Band.high, CommentTone.warm): [
    '정말 행복한 하루였네요! 이 감정을 오래 간직할 수 있게 사진이나 한 줄로 남겨 보는 건 어때요?',
    '마음이 가득 차오르는 하루였군요. 이 기쁨을 함께 나눌 사람이 떠오르나요?',
  ],
  (_Mood.positive, _Band.low, CommentTone.plain): [
    '가볍게 기분 좋은 하루였어요.',
    '작은 즐거움이 있었던 날이에요.',
  ],
  (_Mood.positive, _Band.mid, CommentTone.plain): [
    '긍정적인 감정이 뚜렷했던 하루예요. 무엇이 좋았는지 적어 두면 도움이 돼요.',
    '기분이 좋은 날이었어요. 이유를 기억해 두세요.',
  ],
  (_Mood.positive, _Band.high, CommentTone.plain): [
    '아주 기쁜 하루였어요. 이 경험을 기록으로 남겨 두세요.',
    '강한 긍정 감정을 느낀 날이에요. 누구와 나눌지 생각해 보세요.',
  ],
  // 보통
  (_Mood.neutral, _Band.low, CommentTone.warm): [
    '잔잔하게 흘러간 하루였네요. 평온한 날도 소중한 기록이에요.',
    '특별한 일 없이 무난한 하루였군요. 그런 날이 있어야 쉬어 갈 수 있어요.',
  ],
  (_Mood.neutral, _Band.mid, CommentTone.warm): [
    '마음이 조금 복잡했을 수도 있겠어요. 오늘 있었던 일을 천천히 떠올려 봐요.',
    '덤덤한 하루 속에서도 생각이 많았던 것 같아요.',
  ],
  (_Mood.neutral, _Band.high, CommentTone.warm): [
    '감정을 하나로 정하기 어려운 하루였나 봐요. 그럴 땐 잠시 멈추고 숨을 고르는 것도 좋아요.',
    '마음이 꽤 무거웠을 것 같아요. 오늘은 스스로에게 조금 너그러워져도 괜찮아요.',
  ],
  (_Mood.neutral, _Band.low, CommentTone.plain): [
    '평온한 하루였어요.',
    '무난하게 지나간 날이에요.',
  ],
  (_Mood.neutral, _Band.mid, CommentTone.plain): [
    '생각이 많았던 하루예요. 있었던 일을 정리해 보세요.',
    '감정이 뚜렷하지 않은 날이에요. 천천히 돌아보세요.',
  ],
  (_Mood.neutral, _Band.high, CommentTone.plain): [
    '감정을 정리하기 어려운 하루였어요. 잠시 쉬어 가세요.',
    '마음이 무거운 날이에요. 무리하지 마세요.',
  ],
  // 부정
  (_Mood.negative, _Band.low, CommentTone.warm): [
    '조금 신경 쓰이는 일이 있었네요. 그래도 잘 넘기고 있는 것 같아요.',
    '마음에 살짝 걸리는 일이 있었군요. 알아차린 것만으로도 충분해요.',
  ],
  (_Mood.negative, _Band.mid, CommentTone.warm): [
    '오늘은 조금 지쳐 보이네요. 내일은 잠시 휴식을 취하며 좋아하는 일을 해보는 건 어떨까요?',
    '마음이 쓰이는 하루였군요. 감정을 적어 낸 것만으로도 한 걸음 나아간 거예요.',
  ],
  (_Mood.negative, _Band.high, CommentTone.warm): [
    '많이 힘든 하루였을 것 같아요. 오늘은 해야 할 일보다 나를 돌보는 일을 먼저 해 보세요.',
    '감정이 크게 흔들린 날이네요. 혼자 버티지 말고 믿을 수 있는 사람에게 이야기해 보는 것도 좋아요.',
  ],
  (_Mood.negative, _Band.low, CommentTone.plain): [
    '가볍게 불편한 감정이 있었던 날이에요.',
    '조금 신경 쓰이는 일이 있었어요.',
  ],
  (_Mood.negative, _Band.mid, CommentTone.plain): [
    '지친 하루였어요. 내일은 쉬는 시간을 정해 두세요.',
    '부정적인 감정이 일상에 영향을 준 날이에요. 휴식을 챙기세요.',
  ],
  (_Mood.negative, _Band.high, CommentTone.plain): [
    '힘든 하루였어요. 오늘은 할 일을 줄이고 쉬세요.',
    '감정이 크게 흔들린 날이에요. 믿을 만한 사람과 이야기해 보세요.',
  ],
};

const _suggestions = <(_Mood, _Band), List<String>>{
  (_Mood.positive, _Band.low): [
    '오늘 좋았던 일 한 가지 더 적어 보기',
    '좋아하는 음악 한 곡 듣기',
    '고마운 사람에게 짧게 연락하기',
  ],
  (_Mood.positive, _Band.mid): [
    '좋았던 순간을 사진으로 남기기',
    '고마운 사람에게 고맙다고 말하기',
    '내일도 할 수 있는 작은 즐거움 정하기',
  ],
  (_Mood.positive, _Band.high): [
    '기쁜 일을 가까운 사람과 나누기',
    '오늘의 기분을 한 문장으로 남기기',
    '나에게 작은 선물 하기',
  ],
  (_Mood.neutral, _Band.low): [
    '10분 산책하기',
    '물 한 잔 마시고 스트레칭하기',
    '내일 하고 싶은 일 하나 적기',
  ],
  (_Mood.neutral, _Band.mid): [
    '오늘 있었던 일 세 가지 적어 보기',
    '좋아하는 차 한 잔 마시기',
    '잠들기 전 휴대폰 내려놓기',
  ],
  (_Mood.neutral, _Band.high): [
    '5분 동안 천천히 숨 고르기',
    '오늘은 일찍 잠자리에 들기',
    '머릿속 생각을 종이에 모두 적어 보기',
  ],
  (_Mood.negative, _Band.low): ['10분 산책하기', '좋아하는 간식 먹기', '신경 쓰인 일을 한 줄로 정리하기'],
  (_Mood.negative, _Band.mid): [
    '내일 30분 휴식 시간 정해 두기',
    '좋아하는 일 하나 하기',
    '따뜻한 물로 샤워하기',
  ],
  (_Mood.negative, _Band.high): [
    '믿을 수 있는 사람에게 연락하기',
    '오늘 할 일 하나만 남기고 미루기',
    '따뜻한 음료 마시며 쉬기',
  ],
};
