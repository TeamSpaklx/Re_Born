import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/features/analysis/crisis_checker.dart';
import 'package:reborn_app/features/analysis/emotion_analyzer.dart';
import 'package:reborn_app/features/analysis/record_streak_calculator.dart';
import 'package:reborn_app/features/analysis/suggestion_pool.dart';
import 'package:reborn_app/features/entries/models/emotion.dart';
import 'package:reborn_app/features/entries/models/entry_validator.dart';
import 'package:reborn_app/features/insights/models/insight.dart';

void main() {
  group('감정 점수·분석 (T-10, T-18)', () {
    test('점수 = 극성 × 강도, 서운함 강도 2 → −2', () {
      expect(Emotion.hurt.scoreFor(2), -2);
      expect(Emotion.joy.scoreFor(3), 3);
      expect(Emotion.calm.scoreFor(3), 0);
    });

    test('같은 입력으로 두 번 분석해도 같은 점수·키워드', () {
      final now = DateTime(2026, 10, 22);
      final a = EmotionAnalyzer.analyze(
        body: '친구가 답장을 안 해서 서운했고 불안했다',
        emotion: Emotion.hurt,
        intensity: 2,
        now: now,
      );
      final b = EmotionAnalyzer.analyze(
        body: '친구가 답장을 안 해서 서운했고 불안했다',
        emotion: Emotion.hurt,
        intensity: 2,
        now: now,
      );
      expect(a.score, -2);
      expect(a.analysis.keywords, ['서운', '불안']);
      expect(b.analysis.keywords, a.analysis.keywords);
      expect(b.score, a.score);
    });
  });

  group('위기 표현 점검 (T-33)', () {
    test('위기 표현 문장만 감지한다', () {
      expect(
        CrisisChecker.containsCrisisExpression('요즘 너무 힘들어서 죽고 싶다'),
        isTrue,
      );
      expect(CrisisChecker.containsCrisisExpression('오늘 친구와 즐겁게 놀았다'), isFalse);
    });
  });

  group('제안 문구 (T-26)', () {
    test('모든 인사이트 유형에 제안이 1개 이상 있고 권유 표현이다', () {
      for (final type in InsightType.values) {
        final list = SuggestionPool.forInsight(type, '지민');
        expect(list, isNotEmpty);
        expect(list.any((s) => s.contains('지민')), isTrue);
      }
    });
  });

  group('연속 기록(출석 체크)', () {
    final today = DateTime(2026, 10, 22, 9);
    DateTime ago(int d) => DateTime(2026, 10, 22 - d, 20);

    test('오늘 기록이 없으면 어제부터 이어진 날 수가 현재 연속', () {
      final streak = calculateRecordStreak([ago(1), ago(2), ago(3)], today);
      expect(streak.current, 3);
      expect(streak.longest, 3);
    });

    test('오늘 기록하면 오늘부터 센다', () {
      final streak = calculateRecordStreak([ago(0), ago(1), ago(2)], today);
      expect(streak.current, 3);
    });

    test('하루 건너뛰면 현재 연속이 끊기고 최장은 유지된다', () {
      final streak = calculateRecordStreak([
        ago(1),
        ago(2),
        ago(5),
        ago(6),
        ago(7),
        ago(8),
      ], today);
      expect(streak.current, 2);
      expect(streak.longest, 4);
    });

    test('한 날에 여러 건이어도 하루로 센다, 기록이 없으면 0', () {
      expect(calculateRecordStreak([ago(1), ago(1), ago(1)], today).current, 1);
      expect(calculateRecordStreak(const [], today).current, 0);
      expect(calculateRecordStreak([ago(3)], today).current, 0);
    });
  });

  group('기록 입력 검사 (T-11, T-12)', () {
    test('공백만 / 2001자 / 정상', () {
      expect(EntryValidator.validateBody('   '), isNotNull);
      expect(EntryValidator.validateBody('가' * 2001), isNotNull);
      expect(EntryValidator.validateBody('가' * 2000), isNull);
    });

    test('강도 선택 필수, 미래 날짜 불가', () {
      expect(EntryValidator.validateIntensity(null), isNotNull);
      expect(EntryValidator.validateIntensity(4), isNotNull);
      expect(EntryValidator.validateIntensity(2), isNull);
      final now = DateTime(2026, 10, 22);
      expect(
        EntryValidator.validateCreatedAt(DateTime(2026, 10, 23), now),
        isNotNull,
      );
      expect(EntryValidator.validateCreatedAt(now, now), isNull);
    });
  });
}
