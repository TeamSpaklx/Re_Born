/// 동의 항목의 자세한 내용(내용 보기 시트). 법무 확정 전의 요약 문구다 — 출시 전에 팀이 확정한다(SPEC 11장).
abstract final class ConsentTexts {
  static const privacyTitle = '개인정보 수집·이용';
  static const privacy =
      '리본은 서비스를 제공하려고 아래 정보를 모아요.\n\n'
      '• 이메일, 닉네임\n'
      '• 내가 남긴 기록(본문, 감정, 강도)과 등록한 인물 이름\n\n'
      '기록은 내 계정으로만 볼 수 있고, 언제든 설정에서 삭제할 수 있어요.';

  static const aiTitle = '감정 분석 이용';
  static const ai =
      '남긴 기록을 앱 안에서 규칙에 따라 분석해 감정 점수와 관계 지수, 인사이트를 만들어요.\n\n'
      '기록 내용은 외부 AI 서비스로 보내지 않아요. 동의하지 않으면 분석 기능을 쓸 수 없어요.';

  static const analyticsTitle = '사용 분석';
  static const analytics =
      '앱을 더 좋게 만들기 위해 어떤 화면을 얼마나 쓰는지 통계로 살펴봐요. 기록 본문은 포함되지 않고, 동의하지 않아도 앱을 쓸 수 있어요.';
}
