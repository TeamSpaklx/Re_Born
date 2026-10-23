/// 에셋 경로 상수. 문자열 경로를 화면에서 직접 쓰지 않는다.
/// 파일과 Figma 노드의 대응은 docs/DESIGN_SYSTEM.md의 에셋 목록 참고.
abstract final class AppAssets {
  static const _icons = 'assets/icons/ui';

  // 하단 탭 (기본 / 선택[분홍]). 투데이·관계·기록은 Phosphor Icons, 전체는 Iconsax(menu).
  static const tabHome = '$_icons/tab_home.svg';
  static const tabHomeActive = '$_icons/tab_home_active.svg';
  static const tabRelations = '$_icons/tab_relations.svg';
  static const tabRelationsActive = '$_icons/tab_relations_active.svg';
  static const tabRecord = '$_icons/tab_record.svg';
  static const tabRecordActive = '$_icons/tab_record_active.svg';
  static const tabAll = '$_icons/tab_all.svg';
  static const tabAllActive = '$_icons/tab_all_active.svg';

  /// 선택된 탭 뒤의 알약 (92×56).
  static const tabSelection = '$_icons/tab_selection.svg';

  // 홈 화면 아이콘
  static const person = '$_icons/person.svg';
  static const forum = '$_icons/forum.svg';
  static const bell = '$_icons/bell.svg';
  static const sealCheck = '$_icons/seal_check.svg';

  // 임시 디자인 화면용 아이콘 (Phosphor Icons, MIT). 한 가지 색(currentColor)이라 쓰는 곳에서 색을 입힌다.
  static const check = '$_icons/check.svg';
  static const trash = '$_icons/trash.svg';

  // 화살표: 쓰이는 자리마다 크기·색이 달라 파일이 나뉘어 있다.
  static const chevronSignal = '$_icons/chevron_signal.svg';
  static const chevronGraph = '$_icons/chevron_graph.svg';
  static const chevronSeeAll = '$_icons/chevron_see_all.svg';
  static const chevronSection = '$_icons/chevron_section.svg';
  static const chevronAttendance = '$_icons/chevron_attendance.svg';

  /// 액션 카드 오른쪽 원. Before는 `#D0D0D0`, After는 `#EEE6E9`(디자인 불일치, 확인 필요).
  static const radioCircle = '$_icons/radio_circle.svg';
  static const radioCircleAfter = '$_icons/radio_circle_after.svg';

  /// 헤더 로고 (1000×250, 안쪽 여백 포함).
  static const logo = 'assets/images/logo_reborn.png';

  /// 스플래시 화면 로고 마크 (2000×2000, 배경 투명).
  static const logoMark = 'assets/images/logo_mark.png';

  /// iOS 네이티브 탭 바 라벨용 글꼴 파일(UIKit에 직접 등록한다). Flutter 글자는 pubspec의 Pretendard를 쓴다.
  static const pretendardBold = 'assets/fonts/Pretendard-Bold.otf';

  /// 번들에 포함되어야 하는 모든 에셋 (존재 여부 테스트용).
  static const all = [
    tabHome,
    tabHomeActive,
    tabRelations,
    tabRelationsActive,
    tabRecord,
    tabRecordActive,
    tabAll,
    tabAllActive,
    tabSelection,
    person,
    forum,
    bell,
    sealCheck,
    check,
    trash,
    chevronSignal,
    chevronGraph,
    chevronSeeAll,
    chevronSection,
    chevronAttendance,
    radioCircle,
    radioCircleAfter,
    logo,
    logoMark,
    pretendardBold,
  ];
}
