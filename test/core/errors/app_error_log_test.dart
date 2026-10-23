import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/core/errors/app_error_log.dart';
import 'package:reborn_app/core/errors/error_handlers.dart';
import 'package:reborn_app/features/analysis/analysis_service.dart';
import 'package:reborn_app/features/entries/data/in_memory_entries_repository.dart';
import 'package:reborn_app/features/entries/models/emotion.dart';
import 'package:reborn_app/features/entries/models/entry.dart';
import 'package:reborn_app/features/insights/data/in_memory_insights_repository.dart';
import 'package:reborn_app/features/people/data/in_memory_people_repository.dart';

class _FailingEntries extends InMemoryEntriesRepository {
  @override
  Future<void> update(Entry entry) async {
    if (entry.analysis != null &&
        entry.analysisStatus == AnalysisStatus.pending) {
      throw StateError('저장 실패: 하은이가 고맙다는 말이 없어 서운했다');
    }
    return super.update(entry);
  }
}

void main() {
  final fixed = DateTime(2026, 10, 22, 12);

  test('본문이 섞일 수 있는 오류 메시지는 기록하지 않고 종류와 스택만 남긴다 (F-12)', () {
    final log = AppErrorLog(clock: () => fixed);

    log.record(StateError('하은이가 서운했다 (본문)'), StackTrace.current, where: 'test');

    final e = log.entries.single;
    expect(e.type, 'StateError');
    expect(e.where, 'test');
    expect(e.safeMessage, isNull);
    expect(e.time, fixed);
    expect(e.stack, isNotEmpty);
    expect('${e.type} ${e.where} ${e.stack}', isNot(contains('서운')));
  });

  test('AppException의 안전한 문구는 남긴다', () {
    final log = AppErrorLog();
    log.record(const AppException('네트워크가 끊겼어요'), null);
    expect(log.entries.single.safeMessage, '네트워크가 끊겼어요');
  });

  test('최근 50건만 남는다', () {
    final log = AppErrorLog();
    for (var i = 0; i < 60; i++) {
      log.record(StateError('$i'), null, where: 'w$i');
    }
    expect(log.entries, hasLength(AppErrorLog.maxEntries));
    expect(log.entries.first.where, 'w10');
    expect(log.entries.last.where, 'w59');
  });

  test('installErrorHandlers: 처리되지 않은 Flutter 오류가 기록에 남는다', () {
    final log = AppErrorLog();
    final originalOnError = FlutterError.onError;
    addTearDown(() => FlutterError.onError = originalOnError);
    installErrorHandlers(log);

    FlutterError.onError!(
      FlutterErrorDetails(
        exception: ArgumentError('x'),
        stack: StackTrace.current,
      ),
    );

    expect(log.entries.single.type, 'ArgumentError');
    expect(log.entries.single.where, 'flutter');
  });

  test('분석 중 오류는 기록에 남고 기록은 failed로 표시된다 (T-20, F-12)', () async {
    final log = AppErrorLog();
    final entries = _FailingEntries();
    final service = AnalysisService(
      entries: entries,
      people: InMemoryPeopleRepository(),
      indexHistory: InMemoryIndexHistoryRepository(),
      insights: InMemoryInsightsRepository(),
      clock: () => fixed,
      onError: (e, s) => log.record(e, s, where: 'analysis'),
    );

    final result = await service.saveEntry(
      body: '하은이가 고맙다는 말이 없어 서운했다',
      emotion: Emotion.hurt,
      intensity: 2,
    );

    expect(result.analysisStatus, AnalysisStatus.failed);
    expect(log.entries.single.where, 'analysis');
    expect(log.entries.single.safeMessage, isNull);
    expect(log.entries.single.stack, isNot(contains('하은')));
  });

  testWidgets('AppErrorFallback은 안내 문구를 보여 준다', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AppErrorFallback()));
    expect(find.textContaining('화면을 불러오지 못했어요'), findsOneWidget);
  });
}
