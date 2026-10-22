/// 인사이트 유형 (SPEC F-07).
enum InsightType { negativeTrend, recovery }

/// 인사이트의 근거 수치. 화면에는 이 계산값만 쓴다.
class InsightEvidence {
  const InsightEvidence({
    required this.indexFrom,
    required this.indexTo,
    this.negCount,
  });

  /// 비교 시점의 지수와 지금 지수.
  final int indexFrom;
  final int indexTo;

  /// 부정 추세일 때 최근 10일의 부정 기록 수.
  final int? negCount;
}

/// 인사이트 카드 (SPEC F-07, 테이블 `insights`).
class Insight {
  const Insight({
    required this.id,
    required this.type,
    required this.personId,
    required this.message,
    required this.evidence,
    required this.createdAt,
    this.read = false,
  });

  final String id;
  final InsightType type;
  final String personId;

  /// 홈 신호 카드에 쓰는 짧은 문구 (계산 가능한 사실만).
  final String message;
  final InsightEvidence evidence;
  final DateTime createdAt;
  final bool read;

  Insight copyWith({bool? read}) {
    return Insight(
      id: id,
      type: type,
      personId: personId,
      message: message,
      evidence: evidence,
      createdAt: createdAt,
      read: read ?? this.read,
    );
  }
}
