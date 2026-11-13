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

/// 알림 설정 (SPEC F-10, 확장 범위). 앱 안에서 보여 주는 알림 목록의 종류를 켜고 끈다.
class NotificationPrefs {
  const NotificationPrefs({
    this.insight = true,
    this.reminder = false,
    this.reminderTime = '21:00',
  });

  /// 새 인사이트가 생기면 알린다.
  final bool insight;

  /// 기록을 남기도록 정해진 시각에 알린다.
  final bool reminder;

  /// "HH:mm".
  final String reminderTime;

  NotificationPrefs copyWith({
    bool? insight,
    bool? reminder,
    String? reminderTime,
  }) {
    return NotificationPrefs(
      insight: insight ?? this.insight,
      reminder: reminder ?? this.reminder,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}

/// 사용자 설정 (SPEC 사용자 문서: 닉네임, 동의, 알림).
class AppSettings {
  const AppSettings({
    required this.nickname,
    this.consents = const Consents(),
    this.notifications = const NotificationPrefs(),
    this.profileImagePath,
  });

  final String nickname;

  /// 프로필 사진 파일 경로. 없으면 기본 캐릭터. 지금은 메모리 저장이라 앱을 다시 켜면 사라진다.
  final String? profileImagePath;
  final Consents consents;
  final NotificationPrefs notifications;

  AppSettings copyWith({
    String? nickname,
    Consents? consents,
    NotificationPrefs? notifications,
    String? profileImagePath,
    bool clearProfileImage = false,
  }) {
    return AppSettings(
      nickname: nickname ?? this.nickname,
      consents: consents ?? this.consents,
      notifications: notifications ?? this.notifications,
      profileImagePath: clearProfileImage
          ? null
          : (profileImagePath ?? this.profileImagePath),
    );
  }
}
