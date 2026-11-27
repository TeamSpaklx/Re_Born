/// 에셋 경로 상수. 문자열 경로를 화면에서 직접 쓰지 않는다.
/// 파일과 Figma 노드의 대응은 docs/DESIGN_HOME.md의 에셋 목록 참고.
abstract final class AppAssets {
  static const _icons = 'assets/icons/ui';

  // 하단 탭 (기본 / 선택[분홍]). 홈·분석·기록은 Phosphor Icons(fill), 마이는 Figma account_circle.
  static const tabHome = '$_icons/tab_home.svg';
  static const tabHomeActive = '$_icons/tab_home_active.svg';
  static const tabAnalysis = '$_icons/tab_analysis.svg';
  static const tabAnalysisActive = '$_icons/tab_analysis_active.svg';
  static const tabRecord = '$_icons/tab_record.svg';
  static const tabRecordActive = '$_icons/tab_record_active.svg';
  static const tabMy = '$_icons/tab_my.svg';
  static const tabMyActive = '$_icons/tab_my_active.svg';

  /// 선택된 탭 뒤의 알약 (92×56).
  static const tabSelection = '$_icons/tab_selection.svg';

  // 홈 화면 아이콘
  static const forum = '$_icons/forum.svg';

  /// 알림 종 (Phosphor Bell, Figma `828:955`)과 안 읽은 알림이 있을 때의 종(분홍 점, Figma `828:960`).
  static const bell = '$_icons/bell.svg';
  static const bellUnread = '$_icons/bell_unread.svg';
  static const sealCheck = '$_icons/seal_check.svg';

  /// 알림 화면 오른쪽 위 설정 톱니 (Iconsax setting, Figma `834:1153`).
  static const ixSetting = '$_icons/ix_setting.svg';

  /// 아이콘 세그먼트 예시 아이콘 (Phosphor Rabbit·Smiley, Figma `834:1241`, `834:1244`).
  static const segmentRabbit = '$_icons/seg_rabbit.svg';
  static const segmentSmiley = '$_icons/seg_smiley.svg';

  // 임시 디자인 화면용 아이콘. check는 Phosphor Icons(MIT), `ix_*`는 Iconsax(Linear)다.
  // 한 가지 색이라 쓰는 곳에서 `colorFilter`로 색을 입힌다.
  static const check = '$_icons/check.svg';
  static const trash = '$_icons/ix_trash.svg';
  static const ixAdd = '$_icons/ix_add.svg';
  static const ixEdit = '$_icons/ix_edit.svg';
  static const ixCamera = '$_icons/ix_camera.svg';
  static const ixGallery = '$_icons/ix_gallery.svg';
  static const ixEye = '$_icons/ix_eye.svg';
  static const ixEyeOff = '$_icons/ix_eye_off.svg';

  // 전체 탭 설정 행 아이콘 (Iconsax Linear).
  static const ixMessageText = '$_icons/ix_message_text.svg';
  static const ixCall = '$_icons/ix_call.svg';
  static const ixLock = '$_icons/ix_lock.svg';
  static const ixNotification = '$_icons/ix_notification.svg';
  static const ixMoon = '$_icons/ix_moon.svg';
  static const ixLogout = '$_icons/ix_logout.svg';
  static const ixProfileDelete = '$_icons/ix_profile_delete.svg';

  /// 설정 행 오른쪽 꺾쇠 `>` (Iconsax `arrow-right-1`). 설정 묶음 안 아이콘을 Iconsax로 통일한다.
  static const ixArrowRight = '$_icons/ix_arrow_right.svg';

  /// 소셜 로그인 버튼 마크(단순화한 로고, 출시 전 브랜드 가이드 확인 필요).
  static const googleG = '$_icons/google_g.svg';
  static const kakaoBubble = '$_icons/kakao_bubble.svg';

  // 화살표: 쓰이는 자리마다 크기·색이 달라 파일이 나뉘어 있다.
  static const chevronSignal = '$_icons/chevron_signal.svg';
  static const chevronGraph = '$_icons/chevron_graph.svg';
  static const chevronSeeAll = '$_icons/chevron_see_all.svg';
  static const chevronSection = '$_icons/chevron_section.svg';
  static const chevronAttendance = '$_icons/chevron_attendance.svg';

  /// 액션 카드 오른쪽 원 (`#D0D0D0`, Figma Before). After용 `#EEE6E9` 원은 쓰지 않아 지웠다.
  static const radioCircle = '$_icons/radio_circle.svg';

  /// 헤더 로고 (1000×250, 안쪽 여백 포함).
  static const logo = 'assets/images/logo_reborn.png';

  /// 스플래시 화면 로고 마크 (640×640, 배경 투명, 원본 2000×2000을 줄임. Figma 805:953).
  static const logoMark = 'assets/images/logo_mark.png';

  /// 기록 카드(Before)의 여우원숭이 일러스트 (604×604, 배경 투명, 원본 1254×1254를 줄임).
  static const mascotLemur = 'assets/images/mascot_lemur.png';

  /// 인트로 온보딩의 앱 화면 목업 (942×1942, 원본 1066×2198을 줄임. Figma 8877:1946 안의 이미지).
  static const introPreview = 'assets/images/onboarding/intro_preview.png';

  /// 인트로 끝 화면의 기울어진 앱 화면 목업 (1295×1257, Figma 8877:1967 안의 이미지).
  static const startPreview = 'assets/images/onboarding/start_preview.png';

  /// 감정 캐릭터 7종 (RebornMood 시안에서 캐릭터별로 잘라 번짐을 정리한 PNG, 320×320 투명 배경).
  static const _emotions = 'assets/images/emotions';
  static const emotionJoy = '$_emotions/joy.png';
  static const emotionSadness = '$_emotions/sadness.png';
  static const emotionNeutral = '$_emotions/neutral.png';
  static const emotionAnger = '$_emotions/anger.png';
  static const emotionAnxiety = '$_emotions/anxiety.png';
  static const emotionLove = '$_emotions/love.png';
  static const emotionExcited = '$_emotions/excited.png';
  static const emotionImages = [
    emotionJoy,
    emotionSadness,
    emotionNeutral,
    emotionAnger,
    emotionAnxiety,
    emotionLove,
    emotionExcited,
  ];

  /// iOS 네이티브 탭 바 라벨용 글꼴 파일(UIKit에 직접 등록한다). Flutter 글자는 pubspec의 Pretendard를 쓴다.
  static const pretendardBold = 'assets/fonts/Pretendard-Bold.otf';

  /// 번들에 포함되어야 하는 모든 에셋 (존재 여부 테스트용).
  static const all = [
    tabHome,
    tabHomeActive,
    tabAnalysis,
    tabAnalysisActive,
    tabRecord,
    tabRecordActive,
    tabMy,
    tabMyActive,
    tabSelection,
    forum,
    bell,
    bellUnread,
    ixSetting,
    segmentRabbit,
    segmentSmiley,
    sealCheck,
    check,
    trash,
    ixAdd,
    ixEdit,
    ixCamera,
    ixGallery,
    ixEye,
    ixEyeOff,
    googleG,
    kakaoBubble,
    chevronSignal,
    chevronGraph,
    chevronSeeAll,
    chevronSection,
    chevronAttendance,
    radioCircle,
    logo,
    logoMark,
    mascotLemur,
    introPreview,
    startPreview,
    ...emotionImages,
    pretendardBold,
  ];
}
