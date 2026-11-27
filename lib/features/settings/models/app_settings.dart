import '../../ai_comment/models/ai_feedback.dart';

/// 알림 설정 (SPEC F-10, 확장 범위). 앱 안에서 보여 주는 알림 목록의 종류를 켜고 끈다.
class NotificationPrefs {
  const NotificationPrefs({
    this.aiComment = true,
    this.reminder = false,
    this.reminderTime = '21:00',
  });

  /// 일기의 AI 코멘트가 도착하면 알린다.
  final bool aiComment;

  /// 기록을 남기도록 정해진 시각에 알린다.
  final bool reminder;

  /// "HH:mm".
  final String reminderTime;

  NotificationPrefs copyWith({
    bool? aiComment,
    bool? reminder,
    String? reminderTime,
  }) {
    return NotificationPrefs(
      aiComment: aiComment ?? this.aiComment,
      reminder: reminder ?? this.reminder,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}

/// 사용자 설정 (SPEC 사용자 문서: 닉네임, 알림, AI 코멘트 말투).
class AppSettings {
  const AppSettings({
    required this.nickname,
    this.notifications = const NotificationPrefs(),
    this.profileImagePath,
    this.commentTone = CommentTone.warm,
  });

  final String nickname;

  /// AI 코멘트 말투. 백엔드 API에 그대로 넘긴다.
  final CommentTone commentTone;

  /// 프로필 사진 파일 경로. 없으면 기본 캐릭터. 지금은 메모리 저장이라 앱을 다시 켜면 사라진다.
  final String? profileImagePath;
  final NotificationPrefs notifications;

  AppSettings copyWith({
    String? nickname,
    NotificationPrefs? notifications,
    String? profileImagePath,
    bool clearProfileImage = false,
    CommentTone? commentTone,
  }) {
    return AppSettings(
      nickname: nickname ?? this.nickname,
      notifications: notifications ?? this.notifications,
      profileImagePath: clearProfileImage
          ? null
          : (profileImagePath ?? this.profileImagePath),
      commentTone: commentTone ?? this.commentTone,
    );
  }
}
