import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/app/app.dart';
import 'package:reborn_app/app/data_providers.dart';
import 'package:reborn_app/app/router.dart';
import 'package:reborn_app/core/providers/clock_provider.dart';
import 'package:reborn_app/features/insights/data/in_memory_insights_repository.dart';
import 'package:reborn_app/features/insights/presentation/insight_detail_screen.dart';
import 'package:reborn_app/features/notifications/models/app_notification.dart';
import 'package:reborn_app/features/notifications/presentation/notifications_providers.dart';
import 'package:reborn_app/features/settings/presentation/settings_providers.dart';

import '../../helpers/fakes.dart';

final fixedNow = DateTime(2026, 10, 22, 12);

void main() {
  late FakeNotificationService service;

  setUp(() => service = FakeNotificationService());

  Future<ProviderContainer> pumpAt(
    WidgetTester tester,
    String location, {
    bool noInsights = false,
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
          if (noInsights)
            insightsRepositoryProvider.overrideWithValue(
              InMemoryInsightsRepository(),
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

  testWidgets('홈 벨에 읽지 않은 알림이 있으면 점이 붙고, 누르면 알림 목록이 열린다', (tester) async {
    final c = await pumpAt(tester, AppRoutes.today);
    expect(c.read(unreadNotificationCountProvider), 1);
    expect(find.bySemanticsLabel('알림, 읽지 않은 알림 1개'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('알림, 읽지 않은 알림 1개'));
    await tester.pumpAndSettle();
    expect(find.text('알림 설정'), findsOneWidget);
    expect(find.text('새 알림'), findsOneWidget);
    expect(find.textContaining('관계를 살펴보세요'), findsOneWidget);
  });

  testWidgets('알림을 누르면 인사이트가 열리고 읽음 처리되어 점이 사라진다', (tester) async {
    final c = await pumpAt(tester, AppRoutes.notifications);
    await tester.tap(find.textContaining('관계를 살펴보세요'));
    await tester.pumpAndSettle();
    expect(find.byType(InsightDetailScreen), findsOneWidget);

    await c.read(notificationsProvider.future);
    await tester.pump();
    expect(c.read(unreadNotificationCountProvider), 0);
  });

  testWidgets('안 읽음 탭: 읽지 않은 알림이 없으면 빈 상태', (tester) async {
    final c = await pumpAt(tester, AppRoutes.notifications);
    final insights = await c.read(insightsRepositoryProvider).list();
    await c.read(insightsRepositoryProvider).markRead(insights.first.id);
    c.invalidate(notificationsProvider);
    await tester.tap(find.text('안 읽음'));
    await tester.pumpAndSettle();

    expect(find.text('읽지 않은 알림이 없어요'), findsOneWidget);
  });

  testWidgets('인사이트가 없으면 빈 상태 안내', (tester) async {
    await pumpAt(tester, AppRoutes.notifications, noInsights: true);
    expect(find.text('아직 알림이 없어요'), findsOneWidget);
  });

  testWidgets('알림 설정: 리마인드를 켜면 시간 행이 생기고, 인사이트 알림을 끄면 목록이 비어진다', (
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
          )).notifications.copyWith(insight: false),
        );
    expect(await c.read(notificationsProvider.future), isEmpty);
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
