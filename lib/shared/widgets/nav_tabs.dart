import '../../app/theme/app_assets.dart';

/// 하단 탭 하나의 아이콘: 기본(검정)과 선택(분홍 #D94F79). 라벨은 `BottomNavTokens.labels`.
class NavTab {
  const NavTab(this.icon, this.activeIcon);

  final String icon;
  final String activeIcon;

  /// 홈 / 관계 / 기록 / 마이 순서. 라우터의 탭 순서와 같다.
  static const all = [
    NavTab(AppAssets.tabHome, AppAssets.tabHomeActive),
    NavTab(AppAssets.tabRelations, AppAssets.tabRelationsActive),
    NavTab(AppAssets.tabRecord, AppAssets.tabRecordActive),
    NavTab(AppAssets.tabMy, AppAssets.tabMyActive),
  ];
}
