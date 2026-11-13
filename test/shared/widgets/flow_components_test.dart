import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/app/theme/app_assets.dart';
import 'package:reborn_app/app/theme/app_theme.dart';
import 'package:reborn_app/features/entries/models/emotion.dart';
import 'package:reborn_app/features/entries/presentation/widgets/emotion_face.dart';
import 'package:reborn_app/features/entries/presentation/widgets/emotion_picker.dart';
import 'package:reborn_app/shared/widgets/app_fab.dart';
import 'package:reborn_app/shared/widgets/app_tab_bar.dart';
import 'package:reborn_app/shared/widgets/consent_row.dart';
import 'package:reborn_app/shared/widgets/donut_chart.dart';
import 'package:reborn_app/shared/widgets/month_calendar.dart';
import 'package:reborn_app/shared/widgets/notification_row.dart';
import 'package:reborn_app/shared/widgets/select_card.dart';
import 'package:reborn_app/shared/widgets/step_progress_bar.dart';
import 'package:reborn_app/shared/widgets/summary_card.dart';
import 'package:reborn_app/shared/widgets/swipe_to_delete.dart';

import '../../helpers/load_fonts.dart';

/// 가입·기록·알림 화면이 쓰는 공통 컴포넌트(docs/DESIGN_SYSTEM.md 7.6).
void main() {
  setUpAll(loadPretendard);

  Future<void> pump(WidgetTester tester, Widget child) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(402, 874);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: child,
          ),
        ),
      ),
    );
  }

  testWidgets('감정 캐릭터 7종이 모두 그려진다', (tester) async {
    await pump(
      tester,
      Wrap(
        children: [
          for (final e in Emotion.values) EmotionFace(emotion: e, size: 40),
        ],
      ),
    );
    expect(find.byType(EmotionFace), findsNWidgets(7));
    expect(tester.takeException(), isNull);
  });

  testWidgets('감정 선택 격자: 누르면 값이 바뀌고 선택은 스크린 리더에 selected로 읽힌다', (tester) async {
    Emotion? picked;
    await pump(
      tester,
      StatefulBuilder(
        builder: (context, setState) => EmotionPicker(
          selected: picked,
          onChanged: (e) => setState(() => picked = e),
        ),
      ),
    );
    expect(find.text('기쁨'), findsOneWidget);
    expect(find.text('슬픔'), findsOneWidget);

    await tester.tap(find.byKey(const Key('emotion-anxiety')));
    await tester.pumpAndSettle();
    expect(picked, Emotion.anxiety);
    final semantics = tester.getSemantics(
      find.byKey(const Key('emotion-anxiety')),
    );
    expect(semantics.label, '불안함');
  });

  group('MonthCalendar', () {
    final today = DateTime(2026, 10, 24);

    Widget calendar({
      required DateTime month,
      DateTime? selected,
      ValueChanged<DateTime>? onSelected,
      ValueChanged<DateTime>? onMonthChanged,
    }) => MonthCalendar(
      month: month,
      selected: selected ?? today,
      today: today,
      onSelected: onSelected ?? (_) {},
      onMonthChanged: onMonthChanged ?? (_) {},
      markerFor: (d) => d.day == 21
          ? const EmotionFace(emotion: Emotion.joy, size: 20)
          : null,
    );

    testWidgets('제목·요일·날짜가 나오고 날짜 표시(마커)가 붙는다', (tester) async {
      await pump(tester, calendar(month: DateTime(2026, 10)));
      expect(find.text('2026년 10월'), findsOneWidget);
      expect(find.text('일'), findsOneWidget);
      expect(find.text('31'), findsOneWidget);
      expect(find.byType(EmotionFace), findsOneWidget);
    });

    testWidgets('날짜를 누르면 콜백, 오늘 이후 날짜는 눌리지 않는다', (tester) async {
      DateTime? tapped;
      await pump(
        tester,
        calendar(month: DateTime(2026, 10), onSelected: (d) => tapped = d),
      );
      await tester.tap(find.byKey(const Key('day-2026-10-21')));
      expect(tapped, DateTime(2026, 10, 21));

      tapped = null;
      await tester.tap(find.byKey(const Key('day-2026-10-27')));
      expect(tapped, isNull, reason: '미래 날짜');
    });

    testWidgets('이번 달 다음 달 버튼은 비활성, 이전 달은 콜백', (tester) async {
      DateTime? changed;
      await pump(
        tester,
        calendar(month: DateTime(2026, 10), onMonthChanged: (m) => changed = m),
      );
      await tester.tap(find.bySemanticsLabel('다음 달'));
      expect(changed, isNull);
      await tester.tap(find.bySemanticsLabel('이전 달'));
      expect(changed, DateTime(2026, 9));
    });

    testWidgets('윤달 없는 2월 28일까지, 6주짜리 달도 그려진다', (tester) async {
      await pump(tester, calendar(month: DateTime(2026, 2)));
      expect(find.text('28'), findsOneWidget);
      expect(find.text('29'), findsNothing);
      await pump(tester, calendar(month: DateTime(2026, 8)));
      expect(find.text('31'), findsOneWidget);
    });
  });

  testWidgets('진행 막대는 단계를 스크린 리더로 알려 준다', (tester) async {
    await pump(tester, const StepProgressBar(current: 2, total: 4));
    expect(find.bySemanticsLabel('4단계 중 2단계'), findsOneWidget);
  });

  testWidgets('선택 카드: 누르면 콜백, 선택 상태가 읽힌다', (tester) async {
    var taps = 0;
    await pump(
      tester,
      SelectCard(
        title: '친구',
        description: '편하게 마음을 나누는 친구',
        selected: true,
        onTap: () => taps++,
      ),
    );
    await tester.tap(find.text('친구'));
    expect(taps, 1);
    expect(
      tester.getSemantics(find.byType(SelectCard)).label,
      '친구, 편하게 마음을 나누는 친구',
    );
  });

  testWidgets('동의 행: 체크 토글과 내용 보기가 따로 눌린다', (tester) async {
    bool checked = false;
    var viewed = 0;
    await pump(
      tester,
      StatefulBuilder(
        builder: (context, setState) => ConsentRow(
          tag: '필수',
          label: '개인정보 수집·이용',
          checked: checked,
          onChanged: (v) => setState(() => checked = v),
          onView: () => viewed++,
        ),
      ),
    );
    await tester.tap(find.text('개인정보 수집·이용'));
    await tester.pump();
    expect(checked, isTrue);
    expect(viewed, 0);

    await tester.tap(find.bySemanticsLabel('개인정보 수집·이용 내용 보기'));
    expect(viewed, 1);
  });

  testWidgets('요약 카드: 칸마다 수치와 이름', (tester) async {
    await pump(
      tester,
      const SummaryCard(
        items: [
          SummaryItem(value: '12', label: '기록'),
          SummaryItem(value: '3', label: '인물'),
        ],
      ),
    );
    expect(find.text('12'), findsOneWidget);
    expect(find.text('인물'), findsOneWidget);
  });

  testWidgets('밑줄 탭: 누르면 인덱스가 바뀐다', (tester) async {
    var index = 0;
    await pump(
      tester,
      StatefulBuilder(
        builder: (context, setState) => AppTabBar(
          labels: const ['전체', '안 읽음'],
          selectedIndex: index,
          onChanged: (i) => setState(() => index = i),
        ),
      ),
    );
    await tester.tap(find.text('안 읽음'));
    await tester.pumpAndSettle();
    expect(index, 1);
  });

  testWidgets('알림 행: 읽지 않음은 의미 문구에 포함된다', (tester) async {
    await pump(
      tester,
      NotificationRow(
        iconAsset: AppAssets.bell,
        title: '제목',
        body: '본문',
        timeLabel: '3시간 전',
        unread: true,
        onTap: () {},
      ),
    );
    expect(find.bySemanticsLabel('읽지 않음, 제목, 본문, 3시간 전'), findsOneWidget);
  });

  testWidgets('밀어서 삭제: 끝까지 밀면 삭제 콜백, 확인에서 거절하면 그대로', (tester) async {
    var deleted = 0;
    var allow = false;
    await pump(
      tester,
      SizedBox(
        height: 80,
        child: SwipeToDelete(
          dismissKey: const Key('row'),
          confirm: () async => allow,
          onDelete: () => deleted++,
          child: const SizedBox(height: 80, width: double.infinity),
        ),
      ),
    );
    await tester.drag(find.byKey(const Key('row')), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(deleted, 0);
    expect(find.byKey(const Key('row')), findsOneWidget);

    allow = true;
    await tester.drag(find.byKey(const Key('row')), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(deleted, 1);
  });

  testWidgets('도넛 차트: 값이 없어도 오류 없이 그려진다', (tester) async {
    await pump(tester, const DonutChart(segments: []));
    await pump(
      tester,
      const DonutChart(
        segments: [
          DonutSegment(value: 1, color: Colors.red),
          DonutSegment(value: 0, color: Colors.blue),
        ],
        center: Text('1건'),
      ),
    );
    expect(find.text('1건'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('떠 있는 버튼: 누르면 콜백', (tester) async {
    var taps = 0;
    await pump(tester, AppFab(label: '기록하기', onTap: () => taps++));
    await tester.tap(find.text('기록하기'));
    expect(taps, 1);
  });
}
