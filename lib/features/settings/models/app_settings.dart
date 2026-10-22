/// 동의 상태 (SPEC F-01·F-11, 테이블 `consents` 또는 `profiles`).
class Consents {
  const Consents({
    this.privacy = true,
    this.aiAnalysis = true,
    this.analytics = false,
  });

  final bool privacy;
  final bool aiAnalysis;
  final bool analytics;

  Consents copyWith({bool? privacy, bool? aiAnalysis, bool? analytics}) {
    return Consents(
      privacy: privacy ?? this.privacy,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
      analytics: analytics ?? this.analytics,
    );
  }
}

/// 사용자 설정 (SPEC 사용자 문서: 닉네임, 동의).
class AppSettings {
  const AppSettings({required this.nickname, this.consents = const Consents()});

  final String nickname;
  final Consents consents;

  AppSettings copyWith({String? nickname, Consents? consents}) {
    return AppSettings(
      nickname: nickname ?? this.nickname,
      consents: consents ?? this.consents,
    );
  }
}
