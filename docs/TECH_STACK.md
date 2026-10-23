# 기술 스택

리본(Re:Born)에서 **실제로 쓰는 기술**을 정리한 문서입니다. [SPEC.md](./SPEC.md)와 다른 내용이 있으면 이 문서를 따릅니다.
새 라이브러리를 추가하거나 바꿀 때는 PR에서 이 문서도 함께 고쳐 주세요.

## 확정

| 영역 | 사용 기술 | 비고 |
|---|---|---|
| 앱 | Flutter (stable 3.47.4), Dart `^3.12.0` | CI와 같은 버전 사용 |
| 대상 OS | **iOS와 Android 둘 다 (확정, SPEC 11장 3번)** | 코드는 둘 다 잘 동작해야 하고 플랫폼 설정(Info.plist, AndroidManifest)은 항상 양쪽 다 처리합니다. **확인은 팀원 기기에 따라 나눕니다: Windows 기기는 Android만, Mac 기기는 Android와 iOS 둘 다.** iOS 전용 코드는 `ios/`와 `Platform` 분기 안에만 두어 Windows에서도 Android 빌드가 깨지지 않게 합니다 |
| 폰트 | Pretendard (400·500·600·700·800) | `assets/fonts/`, 라이선스 SIL OFL 1.1 (`OFL-LICENSE.txt`) |
| 아이콘 | `flutter_svg` ^2.3.0 + Figma에서 내려받은 SVG | `assets/icons/ui/`, 경로는 `lib/app/theme/app_assets.dart`. 원본 라이브러리: 탭 바 투데이·관계·기록 = Phosphor Icons, 전체 = Iconsax, 임시 디자인 화면의 새 아이콘(check, trash)도 Phosphor(MIT)에서 SVG로 받음 (아이콘 패키지는 쓰지 않음) |
| 디자인 기준 | Figma 홈 화면 (100% 일치 목표) | [DESIGN_SYSTEM.md](./DESIGN_SYSTEM.md), 값은 `lib/app/theme/` 상수만 사용 |
| 인증 | Supabase Auth, 이메일 + 비밀번호 | 구글 로그인은 미정 (SPEC 11장 7번) |
| 상태 관리 | `flutter_riverpod` ^3.4.3 | 앱 최상단 `ProviderScope`, 데이터는 Repository를 Provider로 주입 ([FRONTEND.md](./FRONTEND.md)) |
| 라우팅 | `go_router` ^18.1.1 | `lib/app/router.dart`, 하단 탭은 `StatefulShellRoute.indexedStack`(탭마다 상태 유지) |
| DB | Supabase PostgreSQL | 사용자별 접근은 RLS로 제한 |
| 클라이언트 SDK | `supabase_flutter` 2.17.2 | 초기화: `lib/main.dart`, 설정: `lib/core/config/supabase_config.dart` |
| 감정 분석·관계 지수 | Flutter 앱 내부 규칙 기반 계산 | 외부 AI·분석 API 없음 |
| DB 스키마 관리 | Supabase CLI 마이그레이션 | `supabase/migrations/` |
| 린트 | `flutter_lints` 6 | `analysis_options.yaml` |
| CI | GitHub Actions | `main` 대상 PR마다 `flutter analyze` + `flutter test` (`.github/workflows/flutter-ci.yml`) |

## 쓰지 않는 것

- **Firebase / Firestore**: SPEC의 `users/{uid}/entries/{entryId}` 같은 경로는 Firestore 시절 표기입니다. PostgreSQL 테이블 + `user_id` 컬럼 + RLS로 읽어 주세요.
- **외부 AI API**: 기록 본문을 외부로 보내지 않습니다 (SPEC 6.7).
- **별도 서버**: 계산은 앱에서, 저장은 Supabase에서 합니다.
- **SwiftUI, WidgetKit, ActivityKit**: SPEC 6장 스택에 적혀 있지만 MVP 범위가 아닙니다.

## 폴더 구조

```
lib/
  main.dart          앱 진입점, 세로 고정·시스템 바 설정, Supabase 초기화
  app/               앱 전체 설정 (app.dart 앱 위젯, router.dart 라우팅, main_shell.dart 하단 탭 틀)
    theme/           색·글자·모서리·간격·탭 바 치수·에셋 경로 상수, ThemeData
  core/              공통 기반 (config, 상수, 유틸)
  features/<기능>/   기능별 {models, data, presentation} (예: home, relations, record, all)
  shared/            여러 기능이 같이 쓰는 위젯·모델
assets/
  fonts/             Pretendard
  icons/ui/          Figma에서 내려받은 SVG 아이콘
  images/            로고 등
supabase/
  migrations/        DB 스키마·RLS 마이그레이션
docs/                명세서, 디자인 시스템, 프론트 문서 (design/ 은 Figma 스크린샷)
```

## 화면 규칙

- **하단 탭 4개:** 투데이(홈) / 관계 / 기록 / 전체. 디자인이 있는 화면은 홈뿐이고(2026-10-23 수정안 반영, 배경 `#FFF8F8`), 나머지 탭은 빈 화면으로 둡니다. 토글·모달·토스트·설정 목록은 Figma에 없어 Reborn 공통 컴포넌트로 만들어 쓰고 머티리얼 위젯은 쓰지 않습니다(DESIGN_SYSTEM.md 7장).
- **고정 규칙:** 글자 크기 배율 1.0(시스템 글자 크기 설정 무시), 라이트 모드만, 세로 방향만. **다크 모드는 나중에 추가할 예정**이라 색은 `AppColors` 팔레트로만 씁니다.
- 앱은 스플래시 화면(로고만)으로 시작해, 홈 데이터가 준비되면(최소 0.8초, 최대 3초) 홈이 로고 화면 위로 서서히 나타납니다(크로스페이드 0.4초, 시간은 임시값). 로고에는 투명도·크기 애니메이션이 없습니다. 로그인·회원가입은 디자인이 나올 때까지 제외합니다(로그인이 들어오면 스플래시가 로그인 여부로 로그인/홈을 나눕니다). 시작 경로는 `initialLocationProvider`이고 `main.dart`에서만 스플래시로 바꿉니다(테스트는 기본값 투데이). Supabase 초기화는 첫 화면을 막지 않도록 `runApp` 뒤에 합니다(화면이 Supabase를 쓰기 시작하면 그 전에 끝나도록 바꿀 것).
- 앱이 켜지는 동안의 네이티브 시작 화면(iOS `LaunchScreen.storyboard`, Android `launch_background.xml`)도 같은 로고(200)로 맞춰 두었습니다. **알려진 한계(iOS 시뮬레이터 iOS 27·26.5에서 확인):** 시스템이 그리는 시작 화면의 로고가 앱 안에서 그린 로고(RGB 230,106,141)보다 진하게(248,96,141) 보이는 구간이 앱을 켠 직후 잠깐 있습니다. sRGB 태그, 템플릿 tint, 화면 색공간별 이미지, `UILaunchScreen`, 번들 PNG를 시도했지만 해결되지 않았고 실제 기기에서는 확인하지 못했습니다. 앱 시작을 빠르게 해(Supabase 초기화 지연) 이 구간을 줄입니다. Android 12 이상은 시스템 스플래시(앱 아이콘 기반)가 먼저 나와 완전히 같지는 않습니다.
- 하단 탭 바는 플랫폼별로 다릅니다: **iOS 26 이상 = 네이티브 `UITabBar`(Liquid Glass)**, iOS 26 미만·Android = Flutter가 그린 탭 바(블러). 분기는 `lib/shared/widgets/app_bottom_nav_bar.dart` 한 곳이고, 네이티브 쪽은 `ios/Runner/NativeTabBarView.swift`(플랫폼 뷰)와 `lib/shared/widgets/native_tab_bar.dart`입니다. 새 패키지는 쓰지 않습니다.
- iOS 네이티브 탭 바(Liquid Glass)는 **Xcode 26 이상(iOS 26 SDK)으로 빌드**해야 유리 모양이 나옵니다. iOS 시뮬레이터 런타임 26.5와 27.0에서 확인했습니다.
- 세로 고정은 세 곳에서 합니다: `main.dart`(SystemChrome), iOS `Info.plist`, Android `AndroidManifest.xml`.

## 보안 규칙

- 앱에는 Supabase **publishable key**만 둡니다. `service_role` 키나 비밀 키는 절대 커밋하지 않습니다.
- 모든 사용자 데이터 테이블에 RLS를 켜고, 본인 `user_id`의 행만 읽고 쓰게 합니다.

## 미정 (팀 결정 필요)

정해지면 위 "확정" 표로 옮겨 주세요.

| 항목 | 후보 | 비고 |
|---|---|---|
| 그래프 (F-09) | fl_chart 등 | 홈의 주간 막대 그래프는 Figma 그대로 직접 그리므로 라이브러리가 필요 없음 |
| 푸시 알림 (F-10) | FCM / 로컬 알림 / 미도입 | MVP 이후 확장 기능 |
| 오류 수집 (F-12) | 앱 내부 처리만 / 외부 도구 | MVP는 앱 내부 처리만 |
