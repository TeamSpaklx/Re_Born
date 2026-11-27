import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/app/app.dart';
import 'package:reborn_app/app/data_providers.dart';
import 'package:reborn_app/app/router.dart';
import 'package:reborn_app/core/providers/clock_provider.dart';
import 'package:reborn_app/features/entries/data/in_memory_entries_repository.dart';
import 'package:reborn_app/features/record/presentation/record_detail_screen.dart';
import 'package:reborn_app/features/notifications/models/app_notification.dart';
import 'package:reborn_app/features/notifications/presentation/notifications_providers.dart';
import 'package:reborn_app/features/settings/presentation/settings_providers.dart';
import 'package:reborn_app/shared/widgets/empty_state.dart';
import 'package:reborn_app/shared/widgets/notification_bell_button.dart';
import 'package:reborn_app/app/theme/app_assets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reborn_app/features/notifications/presentation/notification_settings_screen.dart';

import '../../helpers/fakes.dart';

final fixedNow = DateTime(2026, 10, 22, 12);

void main() {
  late FakeNotificationService service;

  setUp(() => service = FakeNotificationService());

  Future<ProviderContainer> pumpAt(
    WidgetTester tester,
    String location, {
    bool noEntries = false,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(402, 1000);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clockProvider.overrideWithValue(() => fixedNow),
          notificationServiceProvider.overrideWithValue(service),
          initialLocationProvider.overrideWithValue(location),
          if (noEntries)
            entriesRepositoryProvider.overrideWithValue(
              InMemoryEntriesRepository(),
            ),
        ],
        child: const RebornApp(),
      ),
    );
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
  }

  test('상대 시각 글자', () {
    final now = DateTime(2026, 10, 22, 12);
    expect(formatRelativeTime(now, now), '방금 전');
    expect(
      formatRelativeTime(now.subtract(const Duration(minutes: 5)), now),
      '5분 전',
    );
    expect(
      formatRelativeTime(now.subtract(const Duration(hours: 3)), now),
      '3시간 전',
    );
    expect(
      formatRelativeTime(now.subtract(const Duration(days: 2)), now),
      '2일 전',
    );
    expect(formatRelativeTime(DateTime(2026, 10, 3), now), '10월 3일');
  });

  testWidgets('홈 벨은 Figma 아이콘을 유지하고, 읽지 않은 수를 알리며 알림 목록을 연다', (tester) async {
    final c = await pumpAt(tester, AppRoutes.today);
    expect(c.read(unreadNotificationCountProvider), 1);
    expect(find.bySemanticsLabel('알림, 읽지 않은 알림 1개'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('알림, 읽지 않은 알림 1개'));
    await tester.pumpAndSettle();
    expect(find.text('알림'), findsWidgets);
    expect(find.byKey(const Key('notification-settings')), findsOneWidget);
    expect(find.text('새 알림'), findsOneWidget);
    expect(find.text('AI 코멘트가 도착했어요'), findsWidgets);
    expect(find.text('지난 알림'), findsOneWidget, reason: '하루 지난 코멘트는 읽은 것으로');
  });

  testWidgets('홈 벨: 안 읽은 알림이 있으면 분홍 점 종(Figma 828:960)을 쓴다', (tester) async {
    await pumpAt(tester, AppRoutes.today);
    final svg = tester.widget<SvgPicture>(
      find.descendant(
        of: find.byType(NotificationBellButton),
        matching: find.byType(SvgPicture),
      ),
    );
    expect((svg.bytesLoader as SvgAssetLoader).assetName, AppAssets.bellUnread);
  });

  testWidgets('알림 화면: 가운데 제목, 전체/안 읽음 세그먼트, 톱니를 누르면 알림 설정', (tester) async {
    await pumpAt(tester, AppRoutes.notifications);
    expect(find.text('전체'), findsOneWidget);
    expect(find.text('안 읽음'), findsOneWidget);
    final title = tester.getCenter(find.text('알림').first);
    expect(title.dx, closeTo(402 / 2, 1));

    await tester.tap(find.byKey(const Key('notification-settings')));
    await tester.pumpAndSettle();
    expect(find.byType(NotificationSettingsScreen), findsOneWidget);
  });

  testWidgets('알림을 누르면 그 일기 상세가 열리고 읽음 처리되어 점이 사라진다', (tester) async {
    final c = await pumpAt(tester, AppRoutes.notifications);
    await tester.tap(find.text('AI 코멘트가 도착했어요').first);
    await tester.pumpAndSettle();
    expect(find.byType(RecordDetailScreen), findsOneWidget);

    await c.read(notificationsProvider.future);
    await tester.pump();
    expect(c.read(unreadNotificationCountProvider), 0);
  });

  testWidgets('안 읽음 탭: 읽지 않은 알림이 없으면 빈 상태', (tester) async {
    final c = await pumpAt(tester, AppRoutes.notifications);
    final list = await c.read(notificationsProvider.future);
    for (final n in list.where((n) => !n.read)) {
      c.read(readNotificationsProvider.notifier).markRead(n.id);
    }
    await tester.tap(find.text('안 읽음'));
    await tester.pumpAndSettle();

    expect(find.text('받은 알림이 없습니다'), findsOneWidget);
  });

  testWidgets('AI 코멘트가 붙은 일기가 없으면 빈 상태 안내', (tester) async {
    await pumpAt(tester, AppRoutes.notifications, noEntries: true);
    expect(find.text('받은 알림이 없습니다'), findsOneWidget);
    expect(find.byType(QuietEmptyState), findsOneWidget);
  });

  testWidgets('알림 설정: 리마인드를 켜면 시간 행이 생기고, AI 코멘트 알림을 끄면 목록이 비어진다', (
    tester,
  ) async {
    final c = await pumpAt(tester, AppRoutes.notificationSettings);
    expect(find.byKey(const Key('notify-time')), findsNothing);

    await tester.tap(
      find
          .descendant(
            of: find.byKey(const Key('notify-reminder')),
            matching: find.byType(GestureDetector),
          )
          .first,
    );
    await tester.pumpAndSettle();
    final prefs = (await c.read(settingsProvider.future)).notifications;
    expect(prefs.reminder, isTrue);
    expect(service.permissionRequests, 1);
    expect(service.scheduled, [(21, 0)]);
    expect(find.byKey(const Key('notify-time')), findsOneWidget);

    await tester.tap(find.byKey(const Key('notify-time')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('오후 8시'));
    await tester.pumpAndSettle();
    expect(
      (await c.read(settingsProvider.future)).notifications.reminderTime,
      '20:00',
    );
    expect(service.scheduled.last, (20, 0), reason: '시간을 바꾸면 다시 예약');

    await c
        .read(settingsActionsProvider)
        .saveNotifications(
          (await c.read(
            settingsProvider.future,
          )).notifications.copyWith(aiComment: false),
        );
    expect(await c.read(notificationsProvider.future), isEmpty);
  });

  testWidgets('디버그 테스트 알림: 바로·10초 뒤 항목이 권한을 확인하고 알림을 요청한다', (tester) async {
    await pumpAt(tester, AppRoutes.notificationSettings);

    await tester.tap(find.byKey(const Key('notify-test-now')));
    await tester.pumpAndSettle();
    expect(service.permissionRequests, 1);
    expect(service.testNotifications, [Duration.zero]);

    await tester.tap(find.byKey(const Key('notify-test-delayed')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(service.testNotifications.last, const Duration(seconds: 10));
    expect(find.textContaining('10초 뒤에 알림이 와요'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('디버그 테스트 알림: OS 권한이 거부되면 보내지 않고 안내한다', (tester) async {
    service.allowed = false;
    await pumpAt(tester, AppRoutes.notificationSettings);

    await tester.tap(find.byKey(const Key('notify-test-now')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(service.testNotifications, isEmpty);
    expect(find.textContaining('알림 권한이 꺼져 있어요'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('OS 권한이 거부되면 리마인드를 켜지 못하고 안내한다', (tester) async {
    service.allowed = false;
    final c = await pumpAt(tester, AppRoutes.notificationSettings);
    await tester.tap(
      find
          .descendant(
            of: find.byKey(const Key('notify-reminder')),
            matching: find.byType(GestureDetector),
          )
          .first,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('알림 권한이 꺼져 있어요'), findsOneWidget);
    expect(
      (await c.read(settingsProvider.future)).notifications.reminder,
      isFalse,
    );
    expect(service.scheduled, isEmpty);
    await tester.pump(const Duration(seconds: 4));
  });
}
