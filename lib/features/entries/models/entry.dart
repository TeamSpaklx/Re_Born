import 'emotion.dart';

/// 분석 상태 (SPEC F-05). done은 지수·인사이트 저장까지 끝난 뒤에 기록한다.
enum AnalysisStatus { pending, done, failed }

/// 규칙 기반 분석 결과 (분석 방식은 항상 rule).
class EntryAnalysis {
  const EntryAnalysis({required this.keywords, required this.analyzedAt});

  final List<String> keywords;
  final DateTime analyzedAt;
}

/// 감정·행동 기록 한 건 (SPEC F-03, 테이블 `entries`).
class Entry {
  const Entry({
    required this.id,
    required this.body,
    required this.emotion,
    required this.intensity,
    required this.score,
    required this.createdAt,
    this.personId,
    this.analysisStatus = AnalysisStatus.pending,
    this.analysis,
  });

  final String id;

  /// 본문 1~2000자.
  final String body;

  /// 기록 대상 인물. 없으면 null.
  final String? personId;
  final Emotion emotion;

  /// 강도 1~3.
  final int intensity;

  /// −3~+3 (극성 × 강도).
  final int score;
  final DateTime createdAt;
  final AnalysisStatus analysisStatus;
  final EntryAnalysis? analysis;

  Entry copyWith({
    String? body,
    Object? personId = _keep,
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
      personId: identical(personId, _keep)
          ? this.personId
          : personId as String?,
      emotion: emotion ?? this.emotion,
      intensity: intensity ?? this.intensity,
      score: score ?? this.score,
      createdAt: createdAt ?? this.createdAt,
      analysisStatus: analysisStatus ?? this.analysisStatus,
      analysis: analysis ?? this.analysis,
    );
  }

  static const _keep = Object();
}
