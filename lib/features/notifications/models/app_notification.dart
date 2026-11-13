/// 알림 종류. 지금은 인사이트 도착뿐이다(F-10 MVP 범위: 인사이트 도착 알림).
enum NotificationKind { insightNegative, insightRecovery }

/// 앱 안 알림 목록의 한 건. 인사이트에서 만들어지며 [insightId]로 상세에 연결된다.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.read,
    required this.insightId,
  });

  final String id;
  final NotificationKind kind;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;
  final String insightId;
}

/// "방금 전", "3시간 전", "2일 전", "10월 3일" 같은 상대 시각 글자.
String formatRelativeTime(DateTime time, DateTime now) {
  final diff = now.difference(time);
  if (diff.inMinutes < 1) return '방금 전';
  if (diff.inHours < 1) return '${diff.inMinutes}분 전';
  if (diff.inDays < 1) return '${diff.inHours}시간 전';
  if (diff.inDays < 7) return '${diff.inDays}일 전';
  return '${time.month}월 ${time.day}일';
}
