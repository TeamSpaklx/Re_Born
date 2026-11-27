import '../../ai_comment/models/ai_feedback.dart';
import 'emotion.dart';

/// 분석 상태 (SPEC F-05). done은 AI 코멘트까지 받은 뒤에 기록한다.
enum AnalysisStatus { pending, done, failed }

/// 분석 결과: 앱 안 규칙 분석(키워드) + AI 코멘트·행동 제안.
class EntryAnalysis {
  const EntryAnalysis({
    required this.keywords,
    required this.analyzedAt,
    this.feedback,
  });

  final List<String> keywords;
  final DateTime analyzedAt;

  /// AI 코멘트. 아직 받기 전이거나 실패하면 null.
  final AiFeedback? feedback;

  EntryAnalysis withFeedback(AiFeedback feedback) => EntryAnalysis(
    keywords: keywords,
    analyzedAt: analyzedAt,
    feedback: feedback,
  );
}

/// 일기 한 건 (SPEC F-03, 테이블 `entries`).
class Entry {
  const Entry({
    required this.id,
    required this.body,
    required this.emotion,
    required this.intensity,
    required this.score,
    required this.createdAt,
    this.analysisStatus = AnalysisStatus.pending,
    this.analysis,
  });

  final String id;

  /// 본문 1~2000자.
  final String body;
  final Emotion emotion;

  /// 강도 1~5 ([IntensityLevel] 기준표).
  final int intensity;

  /// −5~+5 (극성 × 강도).
  final int score;
  final DateTime createdAt;
  final AnalysisStatus analysisStatus;
  final EntryAnalysis? analysis;

  /// AI 코멘트(있으면).
  AiFeedback? get feedback => analysis?.feedback;

  Entry copyWith({
    String? body,
    Emotion? emotion,
    int? intensity,
    int? score,
    DateTime? createdAt,
    AnalysisStatus? analysisStatus,
    EntryAnalysis? analysis,
  }) {
    return Entry(
      id: id,
      body: body ?? this.body,
      emotion: emotion ?? this.emotion,
      intensity: intensity ?? this.intensity,
      score: score ?? this.score,
      createdAt: createdAt ?? this.createdAt,
      analysisStatus: analysisStatus ?? this.analysisStatus,
      analysis: analysis ?? this.analysis,
    );
  }
}
