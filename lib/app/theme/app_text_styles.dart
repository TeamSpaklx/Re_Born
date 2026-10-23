import 'package:flutter/material.dart';

/// 앱에서 쓰는 모든 글자 스타일 (Pretendard).
///
/// 색은 넣지 않는다. 다크 모드에서 색이 바뀌므로 화면에서
/// `AppTextStyles.greeting.copyWith(color: context.colors.textBlack)`처럼 지정한다.
/// 자간은 Figma의 px 값 그대로이고, 줄 높이는 Figma의 고정 px 값을 글자 크기로 나눈
/// 배율이다(Figma에서 "기본"인 곳은 height를 비워 둠). 값의 출처는 docs/DESIGN_SYSTEM.md.
abstract final class AppTextStyles {
  static const fontFamily = 'Pretendard';

  static const _regular = FontWeight.w400;
  static const _medium = FontWeight.w500;
  static const _semiBold = FontWeight.w600;
  static const _bold = FontWeight.w700;
  static const _extraBold = FontWeight.w800;

  static TextStyle _style(
    double size,
    FontWeight weight,
    double letterSpacing, {
    double? lineHeight,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      height: lineHeight == null ? null : lineHeight / size,
      leadingDistribution: TextLeadingDistribution.even,
      decoration: decoration,
    );
  }

  /// "규리님, 오늘도 즐거운 하루 보내세요!"
  static final greeting = _style(26, _extraBold, -0.65, lineHeight: 32);

  /// 섹션 제목("최근 관계 신호"), 인물 이름("지민").
  static final sectionTitle = _style(20, _semiBold, -0.5, lineHeight: 32);

  /// "출석 체크 >" 제목 (줄 높이 기본).
  static final attendanceTitle = _style(20, _semiBold, -0.5);

  /// 기록 카드 제목: 기록 전 ("아직 오늘의 마음을…").
  static final recordCardTitleBefore = _style(18, _bold, -0.45);

  /// 기록 카드 제목: 기록 후 ("오늘도 기록 완료!").
  static final recordCardTitleAfter = _style(18, _bold, -0.45, lineHeight: 24);

  /// 액션 카드 제목 ("지민님에게 가볍게 안부 묻기").
  static final actionTitle = _style(18, _semiBold, -0.45, lineHeight: 32);

  /// 본문 14 Medium ("1분만 천천히 돌아볼까요?", 출석 설명).
  static final body = _style(14, _medium, -0.35);

  /// 버튼 글자.
  static final button = _style(14, _semiBold, -0.35);

  /// 연한 핑크 버튼 글자 16 SemiBold ("감정 기록하기", 수정안).
  static final buttonLarge = _style(16, _semiBold, -0.4);

  /// 기록 카드(Before) 부제 16 Medium ("1분만 천천히 돌아볼까요?", 수정안).
  static final recordCardSubtitle = _style(16, _medium, -0.4);

  /// 설정 행 제목 16 Medium, 설정 묶음 제목 16 Bold (Figma에 없음, 토스 구조 참고, 추정).
  static final rowTitle = _style(16, _medium, -0.4);
  static final groupTitle = _style(16, _bold, -0.4);

  /// 감정 그래프 카드 제목.
  static final graphTitle = _style(14, _semiBold, -0.35);

  /// 그래프 요일 라벨.
  static final weekday = _style(14, _medium, -0.35);

  /// "9월 13일 목요일".
  static final date = _style(14, _regular, -0.35);

  /// 신호 카드 문장, 액션 카드 부제 ("최근 대화가 조금 줄었어요").
  static final signalText = _style(12, _medium, -0.3, lineHeight: 32);

  /// "전체 보기".
  static final seeAll = _style(12, _medium, -0.3);

  /// 인물 관계 칩 ("친구").
  static final chipLabel = _style(12, _semiBold, -0.3, lineHeight: 32);

  /// 그래프 월 라벨 ("✦ 9월").
  static final graphMonth = _style(12, _regular, -0.3);

  /// 그래프 설명 문장 일반 부분.
  static final graphCaption = _style(12, _regular, -0.12);

  /// 그래프 설명 문장 강조 부분 ("조금씩 증가", 밑줄).
  static final graphCaptionEmphasis = _style(
    12,
    _semiBold,
    -0.12,
    decoration: TextDecoration.underline,
  );

  /// "마지막 기록 5일 전".
  static final caption = _style(10, _regular, -0.25);

  /// 하단 탭 라벨.
  static final navLabel = _style(10, _bold, -0.1, lineHeight: 12);

  /// 출석 숫자 ("6", 40 Bold).
  static final attendanceNumber = _style(40, _bold, -0.45, lineHeight: 24);

  /// 출석 단위 ("일", 20 Bold).
  static final attendanceUnit = _style(20, _bold, -0.45, lineHeight: 24);

  /// 그래프 위 이모지.
  static final graphEmoji = _style(22, _regular, -0.22);
}
