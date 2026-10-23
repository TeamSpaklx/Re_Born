# 리본(Re:Born) 디자인 시스템

리본의 모든 화면이 따르는 규칙입니다: 색·글자·간격·모서리·모션(토큰), 공통 컴포넌트, 화면 패턴, 문구, 접근성.
**홈 화면의 Figma 좌표·크기·에셋은 [DESIGN_HOME.md](./DESIGN_HOME.md)**에 있고, 이 문서는 그 밖의 모든 화면을 같은 품질로 만들기 위한 기준입니다.
목표 품질은 토스 수준입니다: 위계가 또렷하고, 여백이 넉넉하고, 눌림·전환·로딩·오류까지 빠짐없이 다듬어진 화면.

- **값의 우선순위:** Figma 프레임 > 이 문서 > 레퍼런스([references/INDEX.md](./design/references/INDEX.md)). 레퍼런스(다른 앱 화면)는 **구조·위계만** 참고하고 색·글자·모서리는 이 문서의 토큰으로 다시 입힙니다.
- **출처 표시:** **Figma** = Figma에서 읽은 값 / **레퍼런스** = 참고 화면에서 정한 값 / **추정** = 근거가 없어 정한 값(확인 필요).
- **코드 위치:** 토큰은 `lib/app/theme/`(`AppColors`·`AppTextStyles`·`AppSpacing`·`ComponentLayout`·`AppRadii`·`AppShadows`·`AppMotion`·`AppAssets`), 공통 컴포넌트는 `lib/shared/widgets/`입니다. 화면 코드는 토큰만 쓰고(`Color(0x…)`·글자 크기·`Duration(…)`·경로 문자열 직접 사용 금지) 머티리얼 위젯을 직접 쓰지 않습니다(9장).
- **눈으로 확인:** 디버그 빌드에서 전체 탭 설정 맨 아래 "디자인 갤러리 (개발용)" 또는 `flutter run --dart-define=INITIAL_ROUTE=/dev/gallery`로 모든 토큰·컴포넌트를 한 화면에서 볼 수 있습니다(`lib/shared/dev/design_gallery_screen.dart`). 컴포넌트를 바꾸면 갤러리와 이 문서 7장을 같이 고칩니다.

## 0. 원칙

1. **화면당 주요 행동은 하나.** 주요 버튼(핑크)은 화면에 하나이고, 나머지는 보조(회색)·텍스트 링크입니다. 폼·선택 화면은 주요 행동을 맨 아래에 고정합니다(`BottomCtaBar`).
2. **큰 굵은 제목 → 보조 설명.** 제목(26/20)과 본문(14/16)의 크기 차이로 위계를 만들고, 색은 검정과 회색 두 단계로 나눕니다. 핑크는 행동·선택·강조에만 씁니다.
3. **여백이 위계를 만든다.** 화면 좌우 24, 카드 안쪽 20, 카드 사이·섹션 사이는 12~32. 빽빽한 화면보다 스크롤을 택합니다.
4. **면으로 구분한다.** 배경 `#FFF8F8` 위에 흰 둥근 카드(24)를 얹고, 카드에는 그림자·테두리를 기본으로 넣지 않습니다(떠 있는 요소만 그림자).
5. **모든 눌림에 반응한다.** 눌린 동안 흐려지고(0.7) 가벼운 햅틱이 따라옵니다. 머티리얼 번짐(리플)은 쓰지 않습니다.
6. **상태를 빠뜨리지 않는다.** 모든 데이터 화면은 로딩(스켈레톤)·빈 상태·오류·정상 네 가지를 갖춥니다.
7. **부드럽게 말한다.** 문구는 해요체로 짧게, 경고도 다정하게(8장). 감정 기록 앱이라 사용자를 평가하거나 놀라게 하는 표현을 쓰지 않습니다.

## 1. 색

`AppColors.light` (`lib/app/theme/app_colors.dart`). 화면은 항상 `context.colors.<이름>`으로 읽습니다(다크 모드는 나중에 추가 예정, 같은 이름으로 `AppColors.dark`를 만들면 됩니다).

### 1.1 브랜드·행동
| 용도 | 필드 | 값 | 출처 |
|---|---|---|---|
| 브랜드 핑크 (선택·강조·막대·활성 탭) | `brand` | `#FF6090` | Figma |
| 주요 버튼 배경 | `cta` | `#FF6090` (`brand`와 같지만 나중에 달라질 수 있어 분리) | Figma |
| 주요 버튼 글자 | `onCta` | `#FFFFFF` | Figma |
| 소프트 버튼 배경 / 글자 | `ctaSoft` / `onCtaSoft` | `#FFAFC7` / `#000000` | Figma 수정안 |

### 1.2 배경·표면
| 용도 | 필드 | 값 | 출처 |
|---|---|---|---|
| 화면 배경 | `background` | `#FFF8F8` | Figma 수정안 |
| 스플래시 배경 | `splashBackground` | `#FFFFFF` (iOS·Android 시작 화면과 같음) | Figma |
| 흰 카드 | `cardWhite` | `#FFFFFF` | Figma |
| 핑크 카드 (기록 완료) | `cardPink` | `#FEDAE5` | Figma |
| 카드 테두리·구분선 | `cardBorder` | `#EEE6E9` | Figma |
| 칩·보조 버튼·세그먼트 배경 | `chip` | `#F0F2F3` | Figma |
| 아바타 배경 | `avatar` | `#D9D9D9` | Figma |
| 아이콘 타일 배경 | `iconTile` | `rgba(217,217,217,0.5)` | Figma |
| 스켈레톤 블록 | `skeleton` | `#F1EAED` | 추정 |
| 홈 상단 바 덮개 | `topBarTint` | `rgba(255,255,255,0.1)` | Figma 수정안 |

### 1.3 글자
| 용도 | 필드 | 값 | 출처 |
|---|---|---|---|
| 제목·강조 | `textBlack` | `#000000` | Figma |
| 본문(진한 회색) | `textStrong` | `#1A1A1A` | Figma |
| 보조 설명 | `textSecondary` | `rgba(76,83,95,0.8)` | Figma |
| 날짜 | `textDate` | `rgba(68,68,68,0.6)` | Figma |
| 그래프 설명 | `textGraphCaption` | `#70757F` | Figma |
| 기록 카드 부제 | `recordCardSubtitle` | `#7D8492` | Figma 수정안 |

### 1.4 상태·오버레이
| 용도 | 필드 | 값 | 출처 |
|---|---|---|---|
| 위험·오류·읽지 않음 | `danger` | `#E5484D` | 추정 |
| 위험 버튼 배경 | `dangerTile` | `#FDECEE` | 추정 |
| 모달·시트 뒤 가림막 | `scrim` | 검정 50% | 추정 |
| 토스트 배경 | `toastFill` | `#1A1A1A` 90% | 추정 |

(성공·경고 색은 쓸 곳이 생길 때 추가합니다.)

### 1.5 컨트롤·그래프
| 용도 | 필드 | 값 | 출처 |
|---|---|---|---|
| 토글 꺼짐·시트 핸들 | `toggleOff` | `#E8D5DA` (Figma 팔레트) | 추정 |
| 알림 버튼 배경 | `bellButton` | `rgba(153,153,153,0.1)` | Figma |
| 탭 바 배경/테두리/그림자/선택 | `navFill` / `navBorder` / `navShadow` / `navSelection` | `rgba(255,255,255,0.7)` / `#D0D0D0` / `rgba(0,0,0,0.1)` / `#EDEDED` | Figma |
| 그래프 바닥선 | `gridLine` | `rgba(160,167,180,0.5)` | Figma |
| 그래프 막대 3단계 | `barStrong` / `barMid` / `barLight` | `#D94F79` / `#FF80A6` / `#FFB3CA` | Figma 수정안 |
| 출석 패널 / 그 위 글자 | `attendancePanel` / `onAttendancePanel` | `#FFB2CA` / `rgba(255,255,255,0.8)` | Figma |
| 그래프 이모지 (지금은 안 씀) | `emoji` | `#A0A7B4` | Figma |

### 1.6 감정 8색 (임시, 캐릭터 에셋 대기)
감정마다 대표색을 하나 갖고, 감정 칩·달력·그래프·목록의 색 점에 씁니다. **감정 캐릭터 에셋을 팀이 준비하는 중이라, 에셋이 오면 에셋의 대표색으로 교체**합니다(추정).

| 감정 | 필드 | 값 | | 감정 | 필드 | 값 |
|---|---|---|---|---|---|---|
| 기쁨 | `emotionJoy` | `#FFD66B` | | 서운함 | `emotionHurt` | `#9DB4F2` |
| 감사 | `emotionGratitude` | `#FFB38A` | | 불안 | `emotionAnxiety` | `#C5A8EE` |
| 설렘 | `emotionExcitement` | `#FF9CC2` | | 분노 | `emotionAnger` | `#F27B72` |
| 평온 | `emotionCalm` | `#9FD8C0` | | 슬픔 | `emotionSadness` | `#9FB7C9` |

코드: `emotionColor(emotion, colors)`, `EmotionDot`, `EmotionChip` (`lib/features/entries/presentation/widgets/emotion_chip.dart`). 감정 8종과 극성은 팀 확인 전 제안값입니다(SPEC 11장).

### 1.7 사용 규칙
- 핑크(`brand`)는 **행동·선택·강조**에만 씁니다(버튼, 선택된 칩, 체크, 활성 탭, 막대). 본문 글자를 핑크로 칠하지 않습니다(링크처럼 눌리는 글자와 선택 상태만 예외).
- 한 화면에 핑크 면적이 크면(핑크 카드 + 핑크 버튼) 위계가 사라집니다. 핑크 카드 안의 버튼은 `cta`, 흰 카드 안의 버튼은 `ctaSoft`를 씁니다.
- 위험 색(`danger`)은 삭제·로그아웃처럼 되돌릴 수 없는 동작과 오류·읽지 않음 표시에만 씁니다.
- **대비(확인 필요):** 흰 글자 on `brand`(`#FF6090`)와 `brand` on 흰색은 대비비가 약 3:1이라 작은 글자의 WCAG AA(4.5:1)에 못 미칩니다. 버튼 글자는 16 SemiBold 이상으로 쓰고, 핑크 글자는 큰 글자·아이콘에만 씁니다.
- **팔레트 프레임(Figma `02_DesignSystemScreen`):** `FFB2CA`(`attendancePanel`), `FF6090`(`brand`), `FFF5F8`·`A46273`(아직 쓰는 곳 없음), `E8D5DA`(`toggleOff`), `FFF8F8`(`background`), `FFFF5B`·`FFFFA0`(노랑, 용도 불명). 쓰는 곳이 생기면 토큰으로 추가합니다.

## 2. 글자 (Pretendard)

`AppTextStyles` (`lib/app/theme/app_text_styles.dart`). 굵기 Regular 400 / Medium 500 / SemiBold 600 / Bold 700 / ExtraBold 800. 자간은 Figma px 값이고 줄 높이는 Figma 고정 px입니다. 색은 스타일에 넣지 않고 화면에서 `context.colors`로 지정합니다. **글자 크기 배율은 1.0 고정**(시스템 글자 크기 설정을 무시)이라 줄바꿈에 여유를 둡니다.

| 역할 | 스타일 | 크기 / 굵기 | 자간 | 줄 높이 | 쓰는 곳 |
|---|---|---|---|---|---|
| 큰 제목 | `greeting` | 26 ExtraBold | −0.65 | 32 | 인사말, 큰 제목형 화면의 제목(`PageScaffold(largeTitle)`) |
| 제목 | `sectionTitle` | 20 SemiBold | −0.5 | 32 | 섹션 제목, 모달·시트 제목, 인물 이름 |
| 소제목(강조) | `recordCardTitleBefore` | 18 Bold | −0.45 | 기본 | 카드 제목, 빈 상태 제목 |
| 소제목 | `actionTitle` | 18 SemiBold | −0.45 | 32 | 액션 카드 제목, 프로필 이름 |
| 본문 큰 | `rowTitle` | 16 Medium | −0.4 | 기본 | 설정 행·체크 행·시트 선택 행 제목, 입력 글자 |
| 본문 | `body` | 14 Medium | −0.35 | 기본 | 설명, 보조 문구, 토스트, 모달 본문 |
| 버튼 큰 | `buttonLarge` | 16 SemiBold | −0.4 | 기본 | 높이 52 이상 버튼 |
| 버튼 | `button` | 14 SemiBold | −0.35 | 기본 | 높이 48 이하 버튼, 칩, 세그먼트, 글자 버튼 |
| 라벨 | `sectionLabel` | 14 SemiBold | −0.35 | 기본 | 목록 구획 머리글, 입력 라벨 |
| 그룹 제목 | `groupTitle` | 16 Bold | −0.4 | 기본 | 설정 묶음 제목 |
| 부제 | `recordCardSubtitle` | 16 Medium | −0.4 | 기본 | 기록 카드(Before) 부제 |
| 작은 설명 | `signalText` | 12 Medium | −0.3 | 32 | 신호·액션 카드 설명 |
| 캡션 | `caption` | 10 Regular | −0.25 | 기본 | 마지막 기록 시각, 입력 도움말·오류 |
| 숫자 뱃지 | `badge` | 11 Bold | −0.2 | 기본 | `AppBadge.count` |
| 날짜 | `date` | 14 Regular | −0.35 | 기본 | 홈 날짜 |
| 탭 라벨 | `navLabel` | 10 Bold | −0.1 | 12 | 하단 탭 |
| 큰 숫자 | `attendanceNumber` / `attendanceUnit` | 40 Bold / 20 Bold | −0.45 | 24 | 출석 숫자 |

그래프 전용 스타일(`graphTitle`, `weekday`, `seeAll`, `chipLabel`, `graphMonth`, `graphCaption`, `graphCaptionEmphasis`)과 값은 [DESIGN_HOME.md](./DESIGN_HOME.md)에 있습니다. 새 역할이 필요하면 `AppTextStyles`에 이름 있는 스타일을 추가하고 이 표에 적습니다(화면에서 크기를 직접 지정하지 않음).

**규칙**
- 한 화면의 글자 크기는 4~5종 안에서 씁니다(큰 제목 → 제목 → 본문 → 설명 → 캡션).
- 제목·목록 행은 한 줄(`maxLines: 1`, `TextOverflow.ellipsis`), 설명은 최대 두세 줄입니다. 사용자가 쓴 긴 글(기록 본문)만 여러 줄로 보여 줍니다.
- 숫자·단위는 붙여 씁니다("5일 전", "3건"). 이모지는 플랫폼마다 모양이 달라 쓰지 않습니다(감정은 색 점·캐릭터로 표현).

## 3. 간격·크기

`AppSpacing`(`lib/app/theme/app_spacing.dart`), 새 컴포넌트 치수는 `ComponentLayout`, 홈 Figma 좌표는 `HomeLayout`.

| 토큰 | 값 | 쓰임 |
|---|---|---|
| `space4` / `space8` | 4 / 8 | 아이콘·글자 사이, 제목과 설명 사이 |
| `space12` | 12 | 카드 사이(목록), 컨트롤 사이 |
| `space16` | 16 | 시트·카드 안쪽 위아래, 큰 요소 사이 |
| `space20` | 20 | 카드 안쪽 좌우 |
| `space24` | 24 | **화면 좌우 여백(`pageMargin`)**, 섹션 머리글 위 |
| `space32` / `space40` / `space48` | 32 / 40 / 48 | 섹션 사이, 빈 상태 위아래 |
| `minTouchTarget` | 44 | 눌리는 모든 요소의 최소 크기 |

기준 화면은 402×874(iPhone 16 Pro)이고 좌우 여백 24를 고정한 채 카드가 폭을 채웁니다(402에서 354). 스크롤 화면 맨 아래는 탭 바에 가려지지 않게 `scrollBottomPadding`(148)을 둡니다.

## 4. 모서리·그림자·표면

| 토큰 | 값 | 쓰임 |
|---|---|---|
| `AppRadii.card` | 24 | 카드 |
| `AppRadii.dialog` | 28 | 모달, 바텀시트 위쪽 |
| `AppRadii.button` | 12 | 버튼, 입력창, 세그먼트, 아이콘 타일 |
| `AppRadii.toast` | 16 | 토스트 |
| `AppRadii.pill` | 100 | 칩, 뱃지, 알림 버튼, 탭 바, 토글 |

- **표면:** 배경 `#FFF8F8` → 흰 카드(`AppCard.white`, 테두리 없음) → 필요하면 강조 카드(`AppCard.outlined`: 1px `cardBorder`, `AppCard.pink`: 기록 완료).
- **그림자(`AppShadows`):** `subtle`(세그먼트 선택 알약, 토글 동그라미) / `floating`(탭 바) / `overlay`(바텀시트). 카드는 그림자를 쓰지 않습니다.
- **테두리:** 카드 1px, 입력창 1.5px(기본 `cardBorder` → 포커스 `brand` → 오류 `danger`).

## 5. 모션

`AppMotion` (`lib/app/theme/app_motion.dart`). 값은 토스 같은 앱의 느낌(짧고 부드러움)을 참고한 **추정**입니다.

| 토큰 | 값 | 쓰임 |
|---|---|---|
| `press` | 100ms | 눌림 반응(불투명도 `pressedOpacity` 0.7) |
| `fast` | 200ms | 토글·체크·세그먼트·칩 상태 변화, 버튼 비활성 전환 |
| `normal` | 300ms | 바텀시트·모달·화면 전환 |
| `slow` | 500ms | 맨 위로 스크롤처럼 긴 이동 |
| `skeletonPulse` | 1200ms | 스켈레톤 한 번 깜빡임 |
| `enter` / `exit` / `move` | easeOutCubic / easeInCubic / easeInOutCubic | 나타남 / 사라짐 / 위치 이동 |

- **햅틱(`AppHaptics`):** 버튼·링크 `tap`(가벼운 톡), 토글·칩·체크·세그먼트·탭 바 `selection`. 오류·완료 같은 큰 사건에는 쓰지 않습니다.
- **화면 전환:** 스플래시 → 홈은 크로스페이드(0.4초), 상세·작성 화면은 플랫폼 기본 전환. 다이얼로그는 페이드 + 0.96→1 확대(200ms), 바텀시트는 아래에서 올라옴(300ms, 닫을 때 200ms), 토스트는 12 올라오며 250ms 페이드, 전체 3초.
- **움직임 줄이기:** 시스템의 "애니메이션 줄이기"가 켜지면 스켈레톤 깜빡임을 멈춥니다(`SkeletonScope`). 다른 애니메이션의 대응은 화면 롤아웃 때 추가합니다(확인 필요).

## 6. 아이콘·일러스트

- **아이콘:** 하단 탭 투데이·관계·기록은 Phosphor, 전체는 Iconsax(`menu`). 새 아이콘은 두 라이브러리에서 SVG로 받아 `assets/icons/ui/`에 넣고 `AppAssets`에 상수를 추가합니다(새 패키지 금지). 크기 20(행 화살표·체크), 24(체크 원), 28(탭·벨).
- **마스코트(여우원숭이, `AppAssets.mascotLemur`):** 홈 기록 카드(버튼 뒤에서 얼굴만), 빈·오류 상태(120×120, `EmptyState(showMascot: true)`). 스플래시에는 쓰지 않습니다(R 로고만).
- **감정 캐릭터 8종:** 팀이 에셋을 준비 중입니다(정사각 PNG/SVG, 배경 투명, 감정별 대표색). 에셋이 올 때까지 감정 색 원(`EmotionDot`)이 그 자리를 맡습니다. 에셋이 오면 `emotionColor`를 에셋 기반으로 교체하고 `AppAssets`에 등록합니다.
- 이모지는 쓰지 않습니다(8장 글자 규칙).

## 7. 컴포넌트 카탈로그

상태 열: **✅ 구현** (갤러리에서 확인, 위젯 테스트 있음) / 🟡 임시(레퍼런스 대기·다듬기 필요) / ⬜ 미구현. 모든 컴포넌트는 `lib/shared/widgets/`(감정은 `features/entries/…/emotion_chip.dart`)에 있습니다.

### 7.1 버튼 · 입력 · 선택
| 컴포넌트 | 파일 | 변형·상태 | 치수·규칙 | 접근성 | 상태 |
|---|---|---|---|---|---|
| 버튼 `CtaButton` | `cta_button.dart` | `primary`(핑크) · `soft`(연한 핑크) · `secondary`(회색) · `destructive`(연한 빨강) · 비활성(`onPressed: null`, 0.4) | 폭은 부모를 채움, 높이 52(글자 16) / 48(글자 14), 모서리 12, 눌림 0.7, 햅틱 `tap` | `button`, `enabled`, label | ✅ |
| 하단 CTA 바 `BottomCtaBar` | `bottom_cta_bar.dart` | 주요 버튼 하나 + 아래 보조 링크(선택) | 좌우 24, 위 12, 아래 16(+홈 인디케이터), 버튼 52. `PageScaffold(bottom:)`에 넣음 | 버튼과 같음 | ✅ |
| 글자 버튼 `AppTextButton` | `app_text_button.dart` | 색을 지정, 눌림 흐려짐 | 최소 44×44 | `button`, label | ✅ |
| 입력창 `AppTextField` | `app_text_field.dart` | 기본 · 포커스(`brand`) · 오류(`danger` + 문구) · 비활성 · 비밀번호(가림 + `suffix` "보기") · 라벨 · 도움말 · 글자 수 | 모서리 12, 테두리 1.5, 안쪽 16, 글자 16 | TextField 기본 | ✅ |
| 선택 칩 `ChoiceChipButton` | `choice_chip_button.dart` | 선택(핑크 채움) / 미선택(`chip`) | 알약, 세로 9·가로 16, 글자 14 SemiBold, 햅틱 `selection` | `button`, `selected` | 🟡 높이 36 규칙 정리, 감정 칩과 구분 |
| 세그먼트 `SegmentedControl` | `segmented_control.dart` | 2~4칸, 선택 칸에 흰 알약이 200ms로 이동 | 높이 44, 안쪽 4, 모서리 12, `AppShadows.subtle` | 칸마다 `button`+`selected` | ✅ |
| 토글 `AppToggle` | `app_toggle.dart` | 켜짐(`brand`) / 꺼짐(`toggleOff`) / 비활성 | 51×31, 동그라미 27, 터치 44, 200ms | `toggled`, `enabled` | ✅ |
| 체크 행 `CheckRow` | `check_row.dart` | 미완료(빈 원) / 완료(핑크 채움 + 체크 + 취소선 + 흐림), 보조 문구·trailing | 원 24, 행 최소 56, 200ms, 행 전체가 터치 영역 | `checked` | ✅ |
| 감정 칩 `EmotionChip` · 색 점 `EmotionDot` | `emotion_chip.dart` | 감정 8종 | 옅은 감정색 배경 + 색 점 + 이름 | label | ✅ (캐릭터 에셋 대기) |

### 7.2 카드 · 목록 · 설정
| 컴포넌트 | 파일 | 변형·규칙 | 상태 |
|---|---|---|---|
| 카드 `AppCard` | `app_card.dart` | `white`(테두리 없음, 투명 2px 자리) · `outlined`(1px `cardBorder`, 기록 카드 Before) · `pink`(기록 완료). 모서리 24 | ✅ |
| 목록 구획 머리글 `ListSectionHeader` | `list_section_header.dart` | 14 SemiBold `textSecondary`, 위 24 아래 8, 오른쪽 trailing | ✅ |
| 프로필 행 `ProfileRow` | `profile_row.dart` | 아바타 56 + 이름(18) + 보조 문구(14) + 화살표(누를 수 있을 때) | ✅ |
| 설정 목록 `SettingsGroup` · `SettingsRow` | `settings_group.dart` | 흰 카드에 행 묶음, 선택적 굵은 제목. 행 56: 토글 / 값 + 화살표 / 위험(빨강) | ✅ |
| 뱃지 `AppBadge` · `Badged` | `app_badge.dart` | 점 8 / 숫자(99+) 높이 18, `danger` | ✅ |
| 인물·기록 목록 카드 | `person_card.dart`, `entry_card.dart` | 화면별 임시 카드 | 🟡 레퍼런스 반영 필요 |
| 알림 행(아이콘 타일 + 제목·본문 + 시간 + 건수 칩, 읽지 않음 강조) | — | 레퍼런스: 토스·당근 알림 | ⬜ |
| 날짜 그룹 기록 카드(감정색 카드 + 태그 칩 + 시각) | — | 레퍼런스: Mentry·감정 기록 앱 | ⬜ |
| 스와이프 삭제 행 | — | 레퍼런스 없음(찾는 중) | ⬜ |

### 7.3 상단 바 · 내비게이션
| 컴포넌트 | 파일 | 변형·규칙 | 상태 |
|---|---|---|---|
| 페이지 틀 `PageScaffold` | `page_scaffold.dart` | 뒤로가기 + 가운데 제목(20) + 오른쪽 `PageAction`. `largeTitle: true`면 제목을 바 아래 26 ExtraBold로(토스식), `bottom:`에 `BottomCtaBar` | ✅ |
| 탭 화면 틀 `TabPageScaffold` | `tab_page_scaffold.dart` | 홈형 고정 블러 상단 바 + 큰 제목. 관계·기록·전체가 임시로 씀 | 🟡 큰 제목형으로 정리 필요 |
| 홈 상단 바 | `home_top_bar.dart` | 블러 + 로고(누르면 맨 위로) + 벨 | ✅ (Figma) |
| 하단 탭 바 | `app_bottom_nav_bar.dart` | iOS 26+ 네이티브, 그 외 Flutter(블러). [DESIGN_HOME.md](./DESIGN_HOME.md) 5.8 | ✅ (Figma) |

### 7.4 오버레이
| 컴포넌트 | 함수·파일 | 규칙 | 상태 |
|---|---|---|---|
| 모달 | `showAppDialog` · `showAppConfirmDialog` (`app_dialogs.dart`) | 흰 둥근 창(28, 안쪽 24, 좌우 24), 왼쪽 정렬 제목·본문, 버튼 높이 52. 2개 이하 가로(취소 `secondary` + 확인 `brand`), 3개 이상 세로. `destructive`는 연한 빨강 + 빨간 글자. 페이드 + 0.96→1 | ✅ |
| 바텀시트 | `showAppBottomSheet` · `SheetOptionRow` (`app_bottom_sheet.dart`) | 위쪽 28, 핸들 40×4, 제목(20)·설명, 선택 행 56(선택되면 핑크 + 체크), 최대 높이 90%, 끌어서 닫기, 300ms | ✅ |
| 토스트 | `showAppToast` (`app_dialogs.dart`) | 어두운 둥근 상자(16), 탭 바 위 16, 3초, 새 토스트가 이전 것을 대체, 터치 통과 | ✅ |
| 날짜 선택 휠 시트 · 내보내기 시트 | — | 레퍼런스: 분석 컨셉 시안 | ⬜ |

### 7.5 상태 화면
| 컴포넌트 | 파일 | 규칙 | 상태 |
|---|---|---|---|
| 스켈레톤 `SkeletonScope` · `SkeletonBox` · `SkeletonListCard` | `skeleton.dart` | 연한 블록이 1.2초로 깜빡임(0.55↔1), 실제 레이아웃 크기에 맞춤, 상단 바·탭 바는 그대로. 홈은 `HomeSkeleton` | ✅ |
| 빈 상태 `EmptyState` | `empty_state.dart` | (마스코트 120) + 제목(18) + 설명(14) + (소프트 버튼 48). 한 줄 문구는 8장 | ✅ |
| 오류 상태 `ErrorState` | `empty_state.dart` | "불러오지 못했어요" + "잠시 뒤에 다시 시도해 주세요." + "다시 시도". 오류 원인(기술 문구)은 보이지 않음 | ✅ |

### 7.6 아직 없는 컴포넌트 (화면 롤아웃 때 만들 것)
레퍼런스는 [references/INDEX.md](./design/references/INDEX.md)에 있습니다. 감정 선택 격자(3열 + 큰 질문 제목), 월 달력(날짜 원 + 감정 표시 + 선택일 상세), 선 그래프(곡선 + 점 + 영역, 기간 세그먼트), 도넛 차트 + 범례, 진행 막대(온보딩 단계), 선택 카드 쌓기(온보딩·관계 유형), 전체 동의 체크 행(약관), 권한 안내 행, 요약 카드(2열 수치), 탭 밑줄 인디케이터, 스와이프 삭제.

## 8. 화면 패턴

1. **탭 화면(투데이·관계·기록·전체):** 고정 상단 바(블러) + 세로 스크롤 + 아래 탭 바 여백 148. 큰 제목은 `greeting`(26). 좌우 24.
2. **푸시 화면(작성·상세·설정 하위):** `PageScaffold`. 정보가 많은 상세는 가운데 제목형, **질문·입력·선택 화면은 큰 제목형 + 하단 고정 CTA**(`largeTitle` + `bottom: BottomCtaBar`). 뒤로가기는 항상 왼쪽 위.
3. **목록:** 구획 머리글(`ListSectionHeader`: 오늘 / 어제 / 날짜) 아래에 흰 카드 또는 행을 12 간격으로. 항목이 없으면 빈 상태, 많으면 스크롤.
4. **폼:** 큰 제목(질문) → 입력/선택 → 하단 고정 버튼. 입력 오류는 해당 입력창 아래에 빨간 문구로 바로 보여 주고, 저장 실패는 토스트. 키보드가 올라오면 하단 버튼이 위로 밀립니다(`PageScaffold`가 처리).
5. **상태 네 가지:** 로딩은 스켈레톤(레이아웃 유지, 스피너 쓰지 않음), 빈 상태는 마스코트 + 한 줄 + 행동 버튼, 오류는 "불러오지 못했어요" + 다시 시도, 정상.
6. **오버레이 선택 기준:** 목록에서 하나 고르기·정렬·필터 → **바텀시트**. 되돌릴 수 없는 동작·중요한 확인 → **모달**(위험은 빨간 버튼). 결과 알림("담았어요") → **토스트**. 입력 형식 오류 → 입력창 아래 **인라인 문구**.
7. **위기 안내(F-13):** 모달 톤으로 부드럽게. 제목 "마음이 많이 힘드신 것 같아요", 단일 확인 버튼. 저장은 막지 않습니다.
8. **홈 화면:** 값이 Figma로 확정되어 있습니다([DESIGN_HOME.md](./DESIGN_HOME.md)).

## 9. 문구 · 접근성 · 플랫폼

### 문구(톤)
- **해요체**, 한 문장은 짧게. "~했어요", "~해 볼까요?". 명령형보다 제안형.
- 버튼은 동사형 2~6자("저장", "감정 기록하기", "다시 시도"). 취소는 "취소" 또는 "나중에".
- 오류는 원인보다 **다음 행동**: "불러오지 못했어요 / 잠시 뒤에 다시 시도해 주세요".
- 부정 감정이나 위기 표현은 평가하지 않고 곁에 있는 말투로("마음이 많이 힘드신 것 같아요").
- 알림·잠금 화면 문구에는 기록 본문·인물 이름을 넣지 않습니다. 의료·상담 서비스가 아니라는 안내를 설정 화면 하단과 위기 안내에 둡니다.

### 접근성
- 눌리는 모든 요소는 44×44 이상. 시각 크기가 작으면 투명 영역으로 확장(`AppToggle`, `AppTextButton`).
- 버튼은 `Semantics(button, label)`, 선택 `selected`, 체크 `checked`, 토글 `toggled`, 구획 머리글 `header`. 장식 이미지(마스코트·아이콘)는 `excludeFromSemantics`.
- 색만으로 상태를 구분하지 않습니다(선택은 색 + 체크/알약, 오류는 색 + 문구).
- 글자 배율이 1.0 고정이므로 긴 문구가 잘리지 않게 말줄임·줄바꿈을 확인합니다(360 폭).

### 플랫폼
- iOS와 Android 모두 같은 모양입니다. iOS 전용 코드는 `ios/`와 플랫폼 분기 안에만 둡니다(하단 탭 바만 iOS 26+ 네이티브).
- **머티리얼(구글) 위젯을 화면에서 직접 쓰지 않습니다.** 대체표:

| 쓰지 않을 것 | 대신 쓸 것 |
|---|---|
| `Switch` | `AppToggle` |
| `SnackBar` | `showAppToast` |
| `AlertDialog` · `Dialog` + `TextButton` | `showAppDialog` · `showAppConfirmDialog` |
| `showModalBottomSheet` + `ListTile` | `showAppBottomSheet` + `SheetOptionRow` |
| `TextButton` · `ElevatedButton` | `AppTextButton` · `CtaButton` |
| `InkWell`(번짐) · `ListTile` | `Pressable` · `SettingsRow`/`ProfileRow`/`CheckRow` |
| `CircularProgressIndicator`(전체 화면 로딩) | `SkeletonScope` |

## 10. 확인이 필요한 것 (추정으로 처리한 것)

1. 감정 8종·극성, 감정 8색·캐릭터 에셋(팀이 준비 중).
2. 위험·오류 색(`danger`/`dangerTile`), 토스트·가림막 색, 스켈레톤 색, 토글 꺼짐 색, 모달 확인 버튼 색.
3. 모션 값(지속시간·곡선)과 "움직임 줄이기" 전체 대응.
4. 핑크 on 흰색의 대비(AA 미달 가능), 접근성 검사.
5. 월 달력·감정 선택 격자·선 그래프·도넛·온보딩·약관·알림 화면의 정확한 치수(Figma 프레임이 `W8guq…` 파일에 있으나 MCP 호출 한도로 읽지 못함 → 읽으면 Figma 기준으로 교정).
6. 홈 외 화면의 Figma 프레임과 이 문서의 컴포넌트 규칙이 어긋나는 부분.
7. Home After(`466:2704`)의 최신 안.
8. 아직 레퍼런스가 없는 화면: 체크리스트, 기록 작성 폼, 인물 목록·추가·상세(밝은 화면), 약관 동의, 이메일 가입(한국어), 인사이트 상세, 위기 안내, 한국어 오류·빈 상태, 계정 삭제 흐름([INDEX.md](./design/references/INDEX.md) C).

## 11. 규칙 요약 (코드 작성 시)

- 색·글자·간격·모서리·모션은 `lib/app/theme/` 토큰만. 없는 값이 필요하면 토큰을 추가하고 이 문서(해당 표)와 `test/app/theme/app_theme_test.dart`를 함께 고칩니다.
- 새 컴포넌트는 `lib/shared/widgets/`에 만들고 7장 표와 갤러리, 위젯 테스트를 함께 추가합니다.
- 화면 하나를 만들 때: 네 가지 상태, 360 폭 오버플로, 눌림·햅틱, 접근성(Semantics), iOS·Android 실행 캡처를 확인합니다.
- 레퍼런스를 참고했으면 [INDEX.md](./design/references/INDEX.md)에 어느 화면에 썼는지 적습니다.
