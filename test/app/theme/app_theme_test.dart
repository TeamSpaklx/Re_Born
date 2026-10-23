import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_app/app/theme/app_assets.dart';
import 'package:reborn_app/app/theme/app_colors.dart';
import 'package:reborn_app/app/theme/app_motion.dart';
import 'package:reborn_app/app/theme/app_radii.dart';
import 'package:reborn_app/app/theme/app_spacing.dart';
import 'package:reborn_app/app/theme/app_text_styles.dart';
import 'package:reborn_app/app/theme/app_theme.dart';
import 'package:reborn_app/app/theme/bottom_nav_tokens.dart';

/// docs/DESIGN_SYSTEM.md의 표와 코드 상수가 어긋나지 않는지 확인한다.
/// 디자인 값을 바꾸면 문서와 이 테스트를 함께 고친다.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('색상 (docs/DESIGN_SYSTEM.md 색상 표)', () {
    const c = AppColors.light;

    test('주요 색', () {
      expect(c.brand, const Color(0xFFFF6090));
      expect(c.cta, const Color(0xFFFF6090));
      expect(c.cardPink, const Color(0xFFFEDAE5));
      expect(c.cardBorder, const Color(0xFFEEE6E9));
      expect(c.attendancePanel, const Color(0xFFFFB2CA));
      expect(c.background, const Color(0xFFFFF8F8));
      expect(c.splashBackground, const Color(0xFFFFFFFF));
      expect(c.recordCardSubtitle, const Color(0xFF7D8492));
      expect(c.ctaSoft, const Color(0xFFFFAFC7));
      expect(c.onCtaSoft, const Color(0xFF000000));
      expect(c.barStrong, const Color(0xFFD94F79));
      expect(c.barMid, const Color(0xFFFF80A6));
      expect(c.barLight, const Color(0xFFFFB3CA));
      expect(c.toggleOff, const Color(0xFFE8D5DA));
      expect(c.skeleton, const Color(0xFFF1EAED));
      expect(c.danger, const Color(0xFFE5484D));
      expect(c.dangerTile, const Color(0xFFFDECEE));
    });

    test('반투명 색은 Figma rgba 값과 같다', () {
      void expectRgba(Color color, int r, int g, int b, double a) {
        expect((color.r * 255).round(), r, reason: 'red of $color');
        expect((color.g * 255).round(), g, reason: 'green of $color');
        expect((color.b * 255).round(), b, reason: 'blue of $color');
        expect(color.a, closeTo(a, 0.005), reason: 'alpha of $color');
      }

      expectRgba(c.toastFill, 26, 26, 26, 0.9);
      expectRgba(c.scrim, 0, 0, 0, 0.5);
      expectRgba(c.topBarTint, 255, 255, 255, 0.1);
      expectRgba(c.textSecondary, 76, 83, 95, 0.8);
      expectRgba(c.textDate, 68, 68, 68, 0.6);
      expectRgba(c.iconTile, 217, 217, 217, 0.5);
      expectRgba(c.gridLine, 160, 167, 180, 0.5);
      expectRgba(c.onAttendancePanel, 255, 255, 255, 0.8);
      expectRgba(c.bellButton, 153, 153, 153, 0.1);
      expectRgba(c.navFill, 255, 255, 255, 0.7);
      expectRgba(c.navShadow, 0, 0, 0, 0.1);
    });
  });

  group('감정 8색 · 간격 스케일 · 모션 (docs/DESIGN_SYSTEM.md 1·3·5장)', () {
    const c = AppColors.light;

    test('감정 8색', () {
      expect(c.emotionJoy, const Color(0xFFFFD66B));
      expect(c.emotionGratitude, const Color(0xFFFFB38A));
      expect(c.emotionExcitement, const Color(0xFFFF9CC2));
      expect(c.emotionCalm, const Color(0xFF9FD8C0));
      expect(c.emotionHurt, const Color(0xFF9DB4F2));
      expect(c.emotionAnxiety, const Color(0xFFC5A8EE));
      expect(c.emotionAnger, const Color(0xFFF27B72));
      expect(c.emotionSadness, const Color(0xFF9FB7C9));
    });

    test('간격은 4pt 스케일이고 화면 좌우 여백은 24', () {
      expect(
        [
          AppSpacing.space4,
          AppSpacing.space8,
          AppSpacing.space12,
          AppSpacing.space16,
          AppSpacing.space20,
          AppSpacing.space24,
          AppSpacing.space32,
          AppSpacing.space40,
          AppSpacing.space48,
        ],
        [4, 8, 12, 16, 20, 24, 32, 40, 48],
      );
      expect(AppSpacing.pageMargin, AppSpacing.space24);
      expect(AppSpacing.minTouchTarget, 44);
    });

    test('모션 길이와 눌림 값', () {
      expect(AppMotion.press, const Duration(milliseconds: 100));
      expect(AppMotion.fast, const Duration(milliseconds: 200));
      expect(AppMotion.normal, const Duration(milliseconds: 300));
      expect(AppMotion.slow, const Duration(milliseconds: 500));
      expect(AppMotion.pressedOpacity, 0.7);
    });

    test('모서리: 카드 24, 모달·시트 28, 버튼·입력 12, 토스트 16', () {
      expect(AppRadii.card, 24);
      expect(AppRadii.dialog, 28);
      expect(AppRadii.button, 12);
      expect(AppRadii.toast, 16);
    });

    test('컴포넌트 치수', () {
      expect(ComponentLayout.toggleWidth, 51);
      expect(ComponentLayout.toggleHeight, 31);
      expect(ComponentLayout.segmentedHeight, 44);
      expect(ComponentLayout.settingsRowHeight, 56);
      expect(ComponentLayout.ctaButtonHeight, 52);
      expect(ComponentLayout.dialogButtonHeight, 52);
      expect(ComponentLayout.sheetHandleWidth, 40);
      expect(ComponentLayout.checkSize, 24);
      expect(ComponentLayout.profileAvatarSize, 56);
    });
  });

  group('글자 스타일 (docs/DESIGN_SYSTEM.md 글자 표)', () {
    void expectStyle(
      TextStyle style,
      double size,
      FontWeight weight,
      double letterSpacing, {
      double? lineHeight,
    }) {
      expect(style.fontFamily, 'Pretendard');
      expect(style.fontSize, size);
      expect(style.fontWeight, weight);
      expect(style.letterSpacing, letterSpacing);
      if (lineHeight == null) {
        expect(style.height, isNull);
      } else {
        // 렌더링되는 줄 높이(px)가 Figma 값과 같아야 한다.
        expect(style.height! * style.fontSize!, closeTo(lineHeight, 0.001));
      }
    }

    test('인사말·제목', () {
      expectStyle(
        AppTextStyles.greeting,
        26,
        FontWeight.w800,
        -0.65,
        lineHeight: 32,
      );
      expectStyle(
        AppTextStyles.sectionTitle,
        20,
        FontWeight.w600,
        -0.5,
        lineHeight: 32,
      );
      expectStyle(AppTextStyles.attendanceTitle, 20, FontWeight.w600, -0.5);
    });

    test('카드 제목', () {
      expectStyle(
        AppTextStyles.recordCardTitleBefore,
        18,
        FontWeight.w700,
        -0.45,
      );
      expectStyle(
        AppTextStyles.recordCardTitleAfter,
        18,
        FontWeight.w700,
        -0.45,
        lineHeight: 24,
      );
      expectStyle(
        AppTextStyles.actionTitle,
        18,
        FontWeight.w600,
        -0.45,
        lineHeight: 32,
      );
    });

    test('본문·보조 글자', () {
      expectStyle(AppTextStyles.body, 14, FontWeight.w500, -0.35);
      expectStyle(AppTextStyles.button, 14, FontWeight.w600, -0.35);
      expectStyle(AppTextStyles.graphTitle, 14, FontWeight.w600, -0.35);
      expectStyle(AppTextStyles.weekday, 14, FontWeight.w500, -0.35);
      expectStyle(AppTextStyles.date, 14, FontWeight.w400, -0.35);
      expectStyle(
        AppTextStyles.signalText,
        12,
        FontWeight.w500,
        -0.3,
        lineHeight: 32,
      );
      expectStyle(AppTextStyles.seeAll, 12, FontWeight.w500, -0.3);
      expectStyle(
        AppTextStyles.chipLabel,
        12,
        FontWeight.w600,
        -0.3,
        lineHeight: 32,
      );
      expectStyle(AppTextStyles.graphMonth, 12, FontWeight.w400, -0.3);
      expectStyle(AppTextStyles.graphCaption, 12, FontWeight.w400, -0.12);
      expectStyle(AppTextStyles.caption, 10, FontWeight.w400, -0.25);
      expectStyle(AppTextStyles.graphEmoji, 22, FontWeight.w400, -0.22);
    });

    test('그래프 설명 강조는 밑줄이 있다', () {
      expectStyle(
        AppTextStyles.graphCaptionEmphasis,
        12,
        FontWeight.w600,
        -0.12,
      );
      expect(
        AppTextStyles.graphCaptionEmphasis.decoration,
        TextDecoration.underline,
      );
    });

    test('탭 라벨·출석 숫자', () {
      expectStyle(
        AppTextStyles.navLabel,
        10,
        FontWeight.w700,
        -0.1,
        lineHeight: 12,
      );
      expectStyle(
        AppTextStyles.attendanceNumber,
        40,
        FontWeight.w700,
        -0.45,
        lineHeight: 24,
      );
      expectStyle(
        AppTextStyles.attendanceUnit,
        20,
        FontWeight.w700,
        -0.45,
        lineHeight: 24,
      );
    });
  });

  group('모서리·간격·탭 바 치수', () {
    test('모서리', () {
      expect(AppRadii.card, 24);
      expect(AppRadii.button, 12);
      expect(AppRadii.graphBarTop, 5);
      expect(AppRadii.pill, 100);
    });

    test('간격', () {
      expect(AppSpacing.designWidth, 402);
      expect(AppSpacing.designHeight, 874);
      expect(AppSpacing.pageMargin, 24);
      // 카드 폭 = 화면 폭 - 좌우 여백 × 2
      expect(
        AppSpacing.designWidth - AppSpacing.pageMargin * 2,
        AppSpacing.designCardWidth,
      );
    });

    test('그래프 막대는 6개이고 간격이 일정하다', () {
      expect(GraphLayout.barLefts, hasLength(6));
      for (var i = 1; i < GraphLayout.barLefts.length; i++) {
        expect(
          GraphLayout.barLefts[i] - GraphLayout.barLefts[i - 1],
          closeTo(47.76, 0.01),
        );
      }
    });

    test('하단 탭 바', () {
      expect(BottomNavTokens.width, 354);
      expect(BottomNavTokens.height, 64);
      expect(BottomNavTokens.labels, ['투데이', '관계', '기록', '전체']);
      expect(BottomNavTokens.selectionLefts, hasLength(4));
      // 항목 4개(68) + 간격 3개(17)가 탭 바 안쪽 323에 들어간다.
      expect(BottomNavTokens.itemWidth * 4 + BottomNavTokens.itemGap * 3, 323);
    });
  });

  group('테마', () {
    test('라이트 전용이며 Pretendard와 AppColors를 쓴다', () {
      final theme = AppTheme.light;
      expect(theme.brightness, Brightness.light);
      expect(theme.textTheme.bodyMedium?.fontFamily, 'Pretendard');
      expect(theme.extension<AppColors>(), AppColors.light);
      expect(theme.scaffoldBackgroundColor, AppColors.light.background);
    });

    testWidgets('context.colors로 팔레트를 읽을 수 있다', (tester) async {
      late AppColors read;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (context) {
              read = context.colors;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(read.brand, const Color(0xFFFF6090));
    });
  });

  group('에셋', () {
    test('경로 상수에 중복이 없다', () {
      expect(AppAssets.all.toSet().length, AppAssets.all.length);
    });

    test('모든 에셋이 번들에 들어 있고 비어 있지 않다', () async {
      for (final path in AppAssets.all) {
        final data = await rootBundle.load(path);
        expect(data.lengthInBytes, greaterThan(0), reason: path);
      }
    });

    test('Pretendard 5개 굵기가 번들에 들어 있다', () async {
      for (final weight in [
        'Regular',
        'Medium',
        'SemiBold',
        'Bold',
        'ExtraBold',
      ]) {
        final data = await rootBundle.load(
          'assets/fonts/Pretendard-$weight.otf',
        );
        expect(data.lengthInBytes, greaterThan(100000), reason: weight);
      }
    });
  });
}
