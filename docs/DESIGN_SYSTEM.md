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
4. **면으로 구분한다.** 차가운 회색 배경 `#F2F2F4` 위에 흰 둥근 카드(24)를 얹고, 카드에는 그림자·테두리를 기본으로 넣지 않습니다(떠 있는 요소만 그림자).
5. **모든 눌림에 반응한다.** 눌린 동안 흐려지고(0.7) 가벼운 햅틱이 따라옵니다. 머티리얼 번짐(리플)은 쓰지 않습니다.
6. **상태를 빠뜨리지 않는다.** 모든 데이터 화면은 로딩·빈 상태·오류·정상 네 가지를 갖춥니다.
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
| 화면 배경 | `background` | `#F2F2F4` | Figma 홈 리디자인 (`8805:1043`) |
| 흰 카드 | `cardWhite` | `#FFFFFF` | Figma |
| 핑크 카드 (기록 완료) | `cardPink` | `#FEDAE5` | Figma |
| 카드 테두리·구분선 | `cardBorder` | `#EEE6E9` | Figma |
| 칩·보조 버튼·세그먼트 배경 | `chip` | `#F0F2F3` | Figma |
| 아바타 배경 | `avatar` | `#D9D9D9` | Figma |
| 아이콘 타일 배경 | `iconTile` | `rgba(217,217,217,0.5)` | Figma |
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
| 토스트 테두리 / 문구 / 강조(✓·확인) / 체크 원 | `toastBorder` / `toastText` / `toastAccent` / `toastCheckFill` | `#E9E9EE` / `#22232A` / `#D94F79` / `#FBE8EF` | Figma `834:2088` (배경은 `cardWhite`) |
| 스켈레톤 막대 | `skeleton` | `#E4E4E4` | Figma `834:2351` |
| 빈 화면 안내 문구 | `emptyText` | `#B3B3B3` | Figma `834:1161` |

(성공·경고 색은 쓸 곳이 생길 때 추가합니다.)

### 1.5 컨트롤·그래프
| 용도 | 필드 | 값 | 출처 |
|---|---|---|---|
| 주요 CTA 배경 | `ctaPrimary` | `#FF80A6` | Figma `862:2951` |
| 토글 켜짐 / 꺼짐 | `toggleOn` / `toggleOff` | `#FFAFC7` / `rgba(60,60,67,0.3)` | Figma `834:1399` |
| 세그먼트 트랙 / 선택 칸 | `segmentTrack` / `segmentSelected` | `#FFFFFF` / `#F2F2F4` | Figma `834:1248` |
| 바텀시트 손잡이 / 제목 / 행 글자 | `sheetHandle` / `sheetTitle` / `sheetRowText` | `#E4E4E4` / `#22252C` / `#4B5260` | Figma `834:1374` |
| 알림 버튼 배경 | `bellButton` | `rgba(153,153,153,0.1)` | Figma |
| 탭 바 배경/테두리/그림자/선택 | `navFill` / `navBorder` / `navShadow` / `navSelection` | `rgba(255,255,255,0.7)` / `#D0D0D0` / `rgba(0,0,0,0.1)` / `#EDEDED` | Figma |
| 그래프 바닥선 | `gridLine` | `rgba(160,167,180,0.5)` | Figma |
| 그래프 막대 3단계 | `barStrong` / `barMid` / `barLight` | `#D94F79` / `#FF80A6` / `#FFB3CA` | Figma 수정안 |
| 출석 패널 / 그 위 글자 | `attendancePanel` / `onAttendancePanel` | `#FFB2CA` / `rgba(255,255,255,0.8)` | Figma |
| 그래프 이모지 (지금은 안 씀) | `emoji` | `#A0A7B4` | Figma |

### 1.6 감정 7색과 캐릭터
감정은 캐릭터 시안(`RebornMood`)의 7종입니다: 기쁨·슬픔·무표정·화남·불안함·사랑·신남. 색은 시안의 이름표 색에서 뽑았고, 감정 카드 배경·비율 막대·범례에 씁니다. 캐릭터 이미지는 시안을 캐릭터별로 잘라 번짐을 정리한 PNG(`assets/images/emotions/`, 320×320)입니다.

| 감정 | 필드 | 값 | | 감정 | 필드 | 값 |
|---|---|---|---|---|---|---|
| 기쁨 | `emotionJoy` | `#F4B1CB` | | 화남 | `emotionAnger` | `#FDA4AC` |
| 슬픔 | `emotionSadness` | `#BBD5ED` | | 불안함 | `emotionAnxiety` | `#B9E5C6` |
| 무표정 | `emotionNeutral` | `#D1BDF3` | | 사랑 | `emotionLove` | `#FF9EC4` |
| 신남 | `emotionExcited` | `#FAD599` | | | | |

코드: `emotionColor(emotion, colors)`, `EmotionDot`, `EmotionChip`(`emotion_chip.dart`), `EmotionFace`(캐릭터 이미지, `emotion_face.dart`). 극성은 팀 확인 전 제안값입니다(SPEC 11장 4번). 시안 원본은 `docs/design/references/user/RebornMood_source.png`(git 제외, 번들 밖)이며 알파에 번짐 잡음이 있어 그대로 쓰지 않습니다.

**임시 프로필 이미지:** 인물·사용자 아바타는 같은 캐릭터 7종을 `CharacterAvatar(seed)`로 고정 배정해 씁니다(인물 id가 seed). 사용자 본인은 사진을 고르면 `UserAvatar`가 사진, 없으면 캐릭터를 보여 줍니다.

### 1.7 사용 규칙
- 핑크(`brand`)는 **행동·선택·강조**에만 씁니다(버튼, 선택된 칩, 체크, 활성 탭, 막대). 본문 글자를 핑크로 칠하지 않습니다(링크처럼 눌리는 글자와 선택 상태만 예외).
- 한 화면에 핑크 면적이 크면(핑크 카드 + 핑크 버튼) 위계가 사라집니다. 핑크 카드 안의 버튼은 `cta`, 흰 카드 안의 버튼은 `ctaSoft`를 씁니다.
- 위험 색(`danger`)은 삭제·로그아웃처럼 되돌릴 수 없는 동작과 오류·읽지 않음 표시에만 씁니다.
- **대비(확인 필요):** 흰 글자 on `brand`(`#FF6090`)와 `brand` on 흰색은 대비비가 약 3:1이라 작은 글자의 WCAG AA(4.5:1)에 못 미칩니다. 버튼 글자는 16 SemiBold 이상으로 쓰고, 핑크 글자는 큰 글자·아이콘에만 씁니다.
- **팔레트 프레임(Figma `02_DesignSystemScreen`):** `FFB2CA`(`attendancePanel`), `FF6090`(`brand`), `FFF5F8`·`A46273`(아직 쓰는 곳 없음), `E8D5DA`(`toggleOff`), `FFF8F8`은 이전 배경색이며 홈 리디자인(`8805:1043`)의 `F2F2F4`로 대체했습니다. `FFFF5B`·`FFFFA0`(노랑, 용도 불명). 쓰는 곳이 생기면 토큰으로 추가합니다.

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
| `AppRadii.dialog` | 28 | 모달 |
| `AppRadii.sheet` | 34 | 바텀시트 카드 (Figma) |
| `AppRadii.skeletonBar` | 6 | 스켈레톤 막대 (Figma) |
| `AppRadii.button` | 12 | 모달 버튼, 입력창, 아이콘 타일 |
| `AppRadii.pill` | 100 | CTA 버튼, 세그먼트, 토스트, 칩, 뱃지, 알림 버튼, 탭 바, 토글 |

- **표면:** 배경 `#F2F2F4` → 흰 카드(`AppCard.white`, 테두리 없음) → 필요하면 강조 카드(`AppCard.outlined`: 1px `cardBorder`, `AppCard.pink`: 기록 완료).
- **그림자(`AppShadows`):** `subtle`(작은 입체감) / `floating`(탭 바) / `sheet`(바텀시트, Figma 여러 겹) / `toast`(토스트, Figma `0 6 20` 6%). 카드는 그림자를 쓰지 않습니다.
- **테두리:** 카드 1px, 입력창 1.5px(기본 `cardBorder` → 포커스 `brand` → 오류 `danger`).

## 5. 모션

`AppMotion` (`lib/app/theme/app_motion.dart`). 값은 토스 같은 앱의 느낌(짧고 부드러움)을 참고한 **추정**입니다.

| 토큰 | 값 | 쓰임 |
|---|---|---|
| `press` | 100ms | 눌림 반응(불투명도 `pressedOpacity` 0.7) |
| `fast` | 200ms | 토글·체크·세그먼트·칩 상태 변화, 버튼 비활성 전환 |
| `normal` | 300ms | 바텀시트·모달·화면 전환 |
| `slow` | 500ms | 맨 위로 스크롤처럼 긴 이동 |
| `enter` / `exit` / `move` | easeOutCubic / easeInCubic / easeInOutCubic | 나타남 / 사라짐 / 위치 이동 |

- **햅틱(`AppHaptics`):** 버튼·링크 `tap`(가벼운 톡), 토글·칩·체크·세그먼트·탭 바 `selection`. 오류·완료 같은 큰 사건에는 쓰지 않습니다. iOS는 Flutter 기본 햅틱(Taptic Engine), Android는 기본 햅틱이 기기마다 거의 안 느껴져서 `MainActivity.kt`의 `reborn/haptics` 채널로 기기 기본 효과(`tap`=클릭, `selection`=틱)를 재생합니다. 시스템의 터치 진동 설정을 따릅니다.
- **화면 전환:** 앱 시작 시 투데이 화면으로 바로 진입합니다. 탭 위로 쌓이는 화면(상세·작성·알림·설정 등)은 iOS·Android 모두 오른쪽에서 밀려 들어오고(iOS식), **화면 어디서나 오른쪽으로 밀어** 이전 페이지로 돌아갑니다(`SwipeBackPage`, `lib/app/swipe_back_page.dart`). 절반 넘게 밀었거나 오른쪽으로 빠르게(화면 폭/초 1배 이상) 튕기면 뒤로, 아니면 제자리. 가로로 미는 안쪽 요소가 먼저이고, 첫 화면·`PopScope`로 막은 화면은 밀리지 않습니다. 하단 탭 전환·스플래시 페이드는 그대로. 다이얼로그는 페이드 + 0.96→1 확대(200ms), 바텀시트는 아래에서 올라옴(300ms, 닫을 때 200ms), 바텀시트는 손가락을 따라 끌리고 놓으면 스프링으로 돌아오거나 닫힘(7.4), 토스트는 12 올라오며 250ms 페이드, 전체 3초('확인'을 누르면 바로 사라짐). 스켈레톤은 1.2초 왕복으로 깜빡임.
- **움직임 줄이기:** 애니메이션의 시스템 설정 대응은 화면 롤아웃 때 추가합니다(확인 필요).

## 6. 아이콘·일러스트

- **아이콘:** 하단 탭 투데이·관계·기록은 Phosphor, 전체는 Iconsax(`menu`). **앱에 새 아이콘이 필요하면 Iconsax(Linear)를 씁니다**: Iconsax 공개 저장소(`lusaxweb/iconsax`)의 SVG를 받아 `assets/icons/ui/ix_*.svg`로 넣고 `AppAssets`에 상수를 추가합니다(아이콘 패키지는 쓰지 않음). 지금 쓰는 것: add, edit, camera, gallery, eye, eye-off, trash. 소셜 로그인 마크(`google_g` 24, `kakao_bubble` 24×23)는 Figma 로그인 화면(`8877:1934`·`8877:1938`)에서 받은 그대로이고, 출시 전 각 회사 브랜드 가이드 확인이 필요합니다. 크기 20(행 화살표·체크), 24(체크 원), 28(탭·벨).
- **마스코트(여우원숭이, `AppAssets.mascotLemur`):** 홈 기록 카드(버튼 뒤에서 얼굴만), 빈·오류 상태(120×120, `EmptyState(showMascot: true)`).
- **감정 캐릭터 7종:** `assets/images/emotions/`의 PNG(`AppAssets.emotionImages`)를 `EmotionFace`로 그립니다(달력 20, 카드 44, 상세 64, 선택 격자 칸). 정식 에셋이 오면 같은 파일 이름으로 교체합니다.
- 이모지는 쓰지 않습니다(8장 글자 규칙).

## 7. 컴포넌트 카탈로그

상태 열: **✅ 구현** (갤러리에서 확인, 위젯 테스트 있음) / 🟡 임시(레퍼런스 대기·다듬기 필요) / ⬜ 미구현. 모든 컴포넌트는 `lib/shared/widgets/`(감정은 `features/entries/…/emotion_chip.dart`)에 있습니다.

### 7.1 버튼 · 입력 · 선택
| 컴포넌트 | 파일 | 변형·상태 | 치수·규칙 | 접근성 | 상태 |
|---|---|---|---|---|---|
| 버튼 `CtaButton` | `cta_button.dart` | `primary`(`ctaPrimary` #FF80A6) · `soft`(연한 핑크) · `secondary`(회색) · `destructive`(연한 빨강) · 비활성(`onPressed: null`, 0.4) | Figma CTA `862:2951`: 알약(100), 폭은 부모를 채움. 하단 고정 60(글자 18 SemiBold) / 카드 안 52(글자 16) / 48·44(글자 14), 눌림 0.7, 햅틱 `tap` | `button`, `enabled`, label | ✅ (Figma) |
| 하단 CTA 바 `BottomCtaBar` | `bottom_cta_bar.dart` | 주요 버튼 하나 + 아래 보조 링크(선택) | 좌우 24, 위 12, 아래 16(+홈 인디케이터), 버튼 52. `PageScaffold(bottom:)`에 넣음 | 버튼과 같음 | ✅ |
| 글자 버튼 `AppTextButton` | `app_text_button.dart` | 색을 지정, 눌림 흐려짐 | 최소 44×44 | `button`, label | ✅ |
| 입력창 `AppTextField` | `app_text_field.dart` | 기본 · 포커스(`brand`) · 오류(`danger` + 문구) · 비활성 · 비밀번호(가림 + `suffix` "보기") · 라벨 · 도움말 · 글자 수 | 모서리 12, 테두리 1.5, 안쪽 16, 글자 16 | TextField 기본 | ✅ |
| 선택 칩 `ChoiceChipButton` | `choice_chip_button.dart` | 선택(핑크 채움) / 미선택(`chip`) | 알약, 세로 9·가로 16, 글자 14 SemiBold, 햅틱 `selection` | `button`, `selected` | 🟡 높이 36 규칙 정리, 감정 칩과 구분 |
| 세그먼트 `SegmentedControl` | `segmented_control.dart` | 글자(기본) · 아이콘(`.icons`, 예: 토끼·웃는 얼굴 — 쓰는 화면은 미정) 2~4칸, 선택 칸 회색 알약이 200ms로 이동 | Figma `834:1248`: 흰 알약 트랙, 안쪽 좌우 6·상하 5, 칸 36 높이, 칸 사이 20, 글자 12 SemiBold, 아이콘 24 | 칸마다 `button`+`selected` | ✅ (Figma) |
| 토글 `AppToggle` | `app_toggle.dart` | 켜짐(`toggleOn`) / 꺼짐(`toggleOff`) / 비활성 | Figma `834:1399`: 64×28 알약, 흰 손잡이 38×24(안쪽 2), 터치 44, 200ms. iOS·Android 같은 모양 | `toggled`, `enabled` | ✅ (Figma) |
| 체크 행 `CheckRow` | `check_row.dart` | 미완료(빈 원) / 완료(핑크 채움 + 체크 + 취소선 + 흐림), 보조 문구·trailing | 원 24, 행 최소 56, 200ms, 행 전체가 터치 영역 | `checked` | ✅ |
| 감정 칩 `EmotionChip` · 색 점 `EmotionDot` | `emotion_chip.dart` | 감정 7종 | 옅은 감정색 배경 + 색 점 + 이름 | label | ✅ |

### 7.2 카드 · 목록 · 설정
| 컴포넌트 | 파일 | 변형·규칙 | 상태 |
|---|---|---|---|
| 카드 `AppCard` | `app_card.dart` | `white`(테두리 없음, 투명 2px 자리) · `outlined`(1px `cardBorder`, 기록 카드 Before) · `pink`(기록 완료). 모서리 24 | ✅ |
| 목록 구획 머리글 `ListSectionHeader` | `list_section_header.dart` | 14 SemiBold `textSecondary`, 위 24 아래 8, 오른쪽 trailing | ✅ |
| 프로필 행 `ProfileRow` | `profile_row.dart` | 아바타 56 + 이름(18) + 보조 문구(14) + 화살표(누를 수 있을 때) | ✅ |
| 설정 목록 `SettingsGroup` · `SettingsRow` | `settings_group.dart` | 흰 카드에 행 묶음, 선택적 굵은 제목. 행 56: 토글 / 값 + 화살표 / 위험(빨강) | ✅ |
| 뱃지 `AppBadge` · `Badged` | `app_badge.dart` | 점 8 / 숫자(99+) 높이 18, `danger` | ✅ |
| 인물·기록 목록 카드 | `person_card.dart`, `entry_card.dart` | 화면별 임시 카드 | 🟡 레퍼런스 반영 필요 |
| 날짜 그룹 기록 카드(감정색 카드 + 태그 칩 + 시각) | — | 레퍼런스: Mentry·감정 기록 앱 | ⬜ |

### 7.3 상단 바 · 내비게이션
| 컴포넌트 | 파일 | 변형·규칙 | 상태 |
|---|---|---|---|
| 페이지 틀 `PageScaffold` | `page_scaffold.dart` | 뒤로가기 + 가운데 제목(20) + 오른쪽 `PageAction`. `largeTitle: true`면 제목을 바 아래 26 ExtraBold로(토스식), `centerTitle: true`면 높이 44 바 가운데 22 Bold + 오른쪽 `PageIconAction`(24 아이콘, Figma 알림 `834:1149`). 뒤로 가기는 두 바 모두 `PageBackButton`(회색 꺾쇠 `chevronSignal`, 터치 44, 왼쪽 16)이고, 화면을 오른쪽으로 밀어도 뒤로 감(5장), `bottom:`에 `BottomCtaBar`(높이 60) | ✅ |
| 알림 종 버튼 `NotificationBellButton` | `notification_bell_button.dart` | Figma `828:959`: 회색 10% 원 44 + 종 24, 안 읽은 알림이 있으면 분홍 점 종(`bellUnread`). 읽지 않은 수를 접근성 라벨로 | ✅ (Figma) |
| 탭 화면 틀 `TabPageScaffold` | `tab_page_scaffold.dart` | 홈형 고정 블러 상단 바 + 큰 제목. 관계·기록·전체가 임시로 씀 | 🟡 큰 제목형으로 정리 필요 |
| 홈 상단 바 | `home_top_bar.dart` | 블러 + 로고(누르면 맨 위로) + 벨 | ✅ (Figma) |
| 하단 탭 바 | `app_bottom_nav_bar.dart` | iOS 26+ 네이티브, 그 외 Flutter(블러). [DESIGN_HOME.md](./DESIGN_HOME.md) 5.8 | ✅ (Figma) |

### 7.4 오버레이
| 컴포넌트 | 함수·파일 | 규칙 | 상태 |
|---|---|---|---|
| 모달 | `showAppDialog` · `showAppConfirmDialog` (`app_dialogs.dart`) | 흰 둥근 창(28, 안쪽 24, 좌우 24), 왼쪽 정렬 제목·본문, 버튼 높이 52. 2개 이하 가로(취소 `secondary` + 확인 `brand`), 3개 이상 세로. `destructive`는 연한 빨강 + 빨간 글자. 페이드 + 0.96→1 | ✅ |
| 나가기 확인 | `LeaveConfirmScope` (`leave_confirm_scope.dart`) | 입력 화면을 감싼다. 입력이 처음과 달라졌으면 뒤로 버튼·화면 밀기·Android 뒤로 가기 때 "작성 중인 내용을 버릴까요?"(계속 쓰기 / 나가기) 확인 창. 저장 후 `pop()`은 막지 않는다. 기록·인물 작성 화면에 적용 | ✅ |
| 바텀시트 | `showAppBottomSheet` · `SheetActionRow` · `SheetOptionRow` (`app_bottom_sheet.dart`) | Figma `834:1374`·`828:115`: 화면 좌우 24 띄운 떠 있는 카드(34), 아래는 안전 영역(없으면 24)만큼 띄움, 안쪽 위 12·좌우 20·아래 20, 손잡이 40×4(아래 24), 제목 20 Bold. 행동 행 56(아이콘 24 + 간격 16 + 16 Medium `sheetRowText`, 위험 행은 빨강·추정). 선택 행은 같은 높이·글자 + 선택되면 핑크 + 체크(추정). 가림막 검정 50%, 최대 높이 90%, 열기 300ms·닫기 200ms. **끌기(토스식, 추정 값):** 시트 어디를 잡아도 손가락을 따라 움직이고, 놓았을 때 높이의 25% 넘게 내렸거나 아래로 초당 700 넘게 튕기면 닫힘, 아니면 스프링(`AppMotion.sheetSpring`)으로 제자리. 위로는 고무줄처럼 최대 24. 끌어내린 만큼 가림막이 옅어짐. 긴 내용은 맨 위에서 더 끌어내리면 시트가 내려가고, 내려간 상태에서 위로 밀면 시트가 먼저 올라온 뒤 스크롤 | ✅ (Figma) |
| 토스트 | `showAppToast(context, 문구, success:)` (`app_dialogs.dart`) | Figma `834:2088`: 흰 알약(테두리 1 `toastBorder`, 그림자 6%), 좌우 16, 간격 12, 문구 14 Medium, 오른쪽 '확인'(14 SemiBold `toastAccent`, 누르면 바로 닫힘). `success: true`(저장·완료)면 왼쪽에 체크 원 28, 오류·안내 문구는 체크 없음. 탭 바 위 16, 3초(추정), 새 토스트가 이전 것을 대체, 토스트 바깥 터치는 통과 | ✅ (Figma) |
| 날짜 선택 휠 시트 · 내보내기 시트 | — | 레퍼런스: 분석 컨셉 시안 | ⬜ |

### 7.5 상태 화면
| 컴포넌트 | 파일 | 규칙 | 상태 |
|---|---|---|---|
| 빈 상태 `EmptyState` | `empty_state.dart` | (마스코트 120) + 제목(18) + 설명(14) + (소프트 버튼 48). 한 줄 문구는 8장 | ✅ |
| 조용한 빈 상태 `QuietEmptyState` | `empty_state.dart` | Figma 알림 `834:1148`: 마스코트 151 + 한 줄(20 Regular `emptyText`). `ComponentLayout.quietEmptyAlignment`로 가운데보다 조금 위 | ✅ (Figma) |
| 스켈레톤 `SkeletonPulse` · `SkeletonBox` · `SkeletonCard` · `SkeletonListCard` · `SkeletonList` | `skeleton.dart` | Figma 홈 스켈레톤 `834:2351`: 흰 카드(24) 위 `#E4E4E4` 막대(6). 한 화면을 `SkeletonPulse`로 감싸 1.2초 왕복으로 깜빡임(불투명도 1↔0.5, 추정), '동작 줄이기'면 정지, "불러오는 중"으로 한 번 읽힘. 홈은 `HomeSkeleton`(Figma 좌표 그대로), 기록·관계·알림 목록과 인물 그래프는 같은 조각으로 만든 추정 배치 | ✅ |
| 앱 잠금 화면 `LockScreen` | `lib/features/security/presentation/lock_screen.dart` | Figma `834:1480`·`834:2141`: 흰 배경(`splashBackground`) 가운데 로고 160(스플래시와 같은 `SplashLayout` 값이라 이어져 보임), 시스템 인증 창은 OS가 위에 띄움. 실패 시 아래에 글자 버튼 "인증에 실패하거나 비밀번호를 잊으셨나요?" 314×45, 안전 영역 위 30, 14 SemiBold −0.35 `lockHelpText`(`rgba(76,83,95,0.8)`), 누르는 동안 알약 배경 `lockHelpPressed`(`rgba(160,167,180,0.2)`). 앱 전환 화면 덮개는 버튼 없이 로고만 | ✅ (Figma) |
| 로그인 화면 `LoginScreen` | `lib/features/auth/presentation/login_screen.dart` | Figma `8877:1929`: 흰 배경(`splashBackground`), RE:BORN 워드마크 314×78(`AppAssets.logo`, Figma 위쪽 331을 기기 높이 비율로 `LoginLayout.logoAlignment`). 아래에 구글·카카오 버튼(`SocialLoginButtonPair`), 버튼 끝에서 57 아래 약관 안내 12 Regular −0.3 줄 높이 14 `loginLegalText`, 안전 영역 위 14. Figma 메모대로 "개인정보 보호 정책"·"서비스 약관"을 각각 링크로 나눠 시트로 엶(밑줄은 추정). 디버그 빌드에서만 워드마크를 길게 누르면 다음 로그인 결과를 고르는 패널(출시 빌드에는 없음) | ✅ (Figma) |
| 오류 상태 `ErrorState` | `empty_state.dart` | "불러오지 못했어요" + "잠시 뒤에 다시 시도해 주세요." + "다시 시도". 오류 원인(기술 문구)은 보이지 않음 | ✅ |

### 7.6 화면 흐름용 컴포넌트 (구현됨, 디버그 갤러리 "감정·기록" 이하에서 확인)
| 컴포넌트 | 파일 | 쓰는 곳 |
|---|---|---|
| `EmotionFace` | `features/entries/.../emotion_face.dart` | 감정 캐릭터 이미지 7종 |
| `CharacterAvatar` · `UserAvatar` | `shared/widgets/` | 캐릭터 기반 임시 프로필 · 사용자 사진/기본 캐릭터 |
| `SocialLoginButton` · `SocialLoginButtonPair` | `features/auth/.../social_login_buttons.dart` | Figma `8877:1931`: 높이 55 알약(Figma 메모대로 두 버튼 높이 통일), 아이콘 24 + 간격 16 + 14 SemiBold −0.35, 버튼 사이 16. 구글(위) 흰 배경·`socialBorder` `#E5E5E5` 테두리, 카카오(아래) `kakaoYellow`. 한쪽을 누르면 끝날 때까지 두 버튼 모두 막고 누른 버튼에 로딩 표시(추정) |
| `EmotionPicker`, `EmotionRatioBar` | `emotion_picker.dart` | 기록 작성의 감정 선택(4열×2행), 감정 비율 막대 |
| `MonthCalendar` | `shared/widgets/month_calendar.dart` | 기록 탭 달력(날짜 아래 마커, 미래 날짜 비활성) |
| `DonutChart` | `donut_chart.dart` | 인물 상세 감정 분포 |
| `IndexLineChart` | `features/relations/.../index_line_chart.dart` | 관계 지수 곡선 + 영역 + 오늘 점 |
| `StepProgressBar` | `step_progress_bar.dart` | 가입 4단계 |
| `SelectCard` | `select_card.dart` | 온보딩 관계 유형 |
| `ConsentRow` | `consent_row.dart` | 확인 체크(계정 삭제), 전체 동의 강조형 포함 |
| `PermissionRow` | `permission_row.dart` | 권한·기능 안내 행(지금은 디자인 갤러리에서만, 가입 단계 화면을 지워서) |
| `SummaryCard` | `summary_card.dart` | 전체 탭·관계 탭·인사이트 상세의 수치 2~3칸 |
| `NotificationRow` | `notification_row.dart` | 알림 목록(읽지 않음 강조) |
| `SwipeToDelete` | `swipe_to_delete.dart` | 기록·체크리스트 밀어서 삭제(확인 팝업 선택) |
| `AppFab` | `app_fab.dart` | 기록 탭 "기록하기"(`TabPageScaffold.floating`) |
| `IntensitySelector` | `features/record/.../intensity_selector.dart` | 감정 강도 1~3 |

아직 없는 것: 날짜 휠 시트.

## 8. 화면 패턴

1. **탭 화면(투데이·관계·기록·전체):** 고정 상단 바(블러) + 세로 스크롤 + 아래 탭 바 여백 148. 큰 제목은 `greeting`(26). 좌우 24.
2. **푸시 화면(작성·상세·설정 하위):** `PageScaffold`. 정보가 많은 상세는 가운데 제목형, **질문·입력·선택 화면은 큰 제목형 + 하단 고정 CTA**(`largeTitle` + `bottom: BottomCtaBar`). 뒤로가기는 항상 왼쪽 위.
3. **목록:** 구획 머리글(`ListSectionHeader`: 오늘 / 어제 / 날짜) 아래에 흰 카드 또는 행을 12 간격으로. 항목이 없으면 빈 상태, 많으면 스크롤.
4. **폼:** 큰 제목(질문) → 입력/선택 → 하단 고정 버튼. 입력 오류는 해당 입력창 아래에 빨간 문구로 바로 보여 주고, 저장 실패는 토스트. 키보드가 올라오면 하단 버튼이 위로 밀립니다(`PageScaffold`가 처리).
5. **상태 네 가지:** 로딩 중에는 스켈레톤(`SkeletonPulse`)으로 내용 자리를 보여 주고, 빈 상태는 마스코트 + 한 줄(+ 행동 버튼), 오류는 "불러오지 못했어요" + 다시 시도를 표시합니다.
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
| `showModalBottomSheet` + `ListTile` | `showAppBottomSheet` + `SheetActionRow` · `SheetOptionRow` |
| `TextButton` · `ElevatedButton` | `AppTextButton` · `CtaButton` |
| `InkWell`(번짐) · `ListTile` | `Pressable` · `SettingsRow`/`ProfileRow`/`CheckRow` |

## 10. 확인이 필요한 것 (추정으로 처리한 것)

1. 감정 7종의 극성(제안값), 감정 7색(시안 이름표 색), 소셜 로그인 버튼·마크의 브랜드 가이드 준수.
2. 위험·오류 색(`danger`/`dangerTile`), 가림막 색, 모달 확인 버튼 색, 바텀시트 선택 행·위험 행 표시, 토스트 시간·스켈레톤 깜빡임 속도.
3. 모션 값(지속시간·곡선)과 "움직임 줄이기" 전체 대응.
4. 핑크 on 흰색의 대비(AA 미달 가능), 접근성 검사.
5. 월 달력·감정 선택 격자·곡선 그래프·도넛·가입·온보딩·약관·알림 화면은 레퍼런스(INDEX.md)를 해석해 만든 것이라 치수가 추정이다(Figma 프레임이 `W8guq…` 파일에 있으나 MCP 호출 한도로 읽지 못함 → 읽으면 Figma 기준으로 교정). 위기 안내의 상담 전화번호(109·1577-0199·1388)도 출시 전에 공식 안내로 확인한다.
6. 앱 잠금: 언제 다시 잠글지(지금은 백그라운드에 다녀오면 바로), 인증 사유 문구("기록을 보려면 잠금을 풀어 주세요")는 Figma에 없어 정한 값.
7. 홈 외 화면의 Figma 프레임과 이 문서의 컴포넌트 규칙이 어긋나는 부분.
8. Home After(`466:2704`)의 최신 안.
9. 아직 레퍼런스가 없는 화면: 체크리스트, 기록 작성 폼, 인물 목록·추가·상세(밝은 화면), 약관 동의, 이메일 가입(한국어), 인사이트 상세, 위기 안내, 한국어 오류·빈 상태, 계정 삭제 흐름([INDEX.md](./design/references/INDEX.md) C).

## 11. 규칙 요약 (코드 작성 시)

- 색·글자·간격·모서리·모션은 `lib/app/theme/` 토큰만. 없는 값이 필요하면 토큰을 추가하고 이 문서(해당 표)와 `test/app/theme/app_theme_test.dart`를 함께 고칩니다.
- 새 컴포넌트는 `lib/shared/widgets/`에 만들고 7장 표와 갤러리, 위젯 테스트를 함께 추가합니다.
- 화면 하나를 만들 때: 네 가지 상태, 360 폭 오버플로, 눌림·햅틱, 접근성(Semantics), iOS·Android 실행 캡처를 확인합니다.
- 레퍼런스를 참고했으면 [INDEX.md](./design/references/INDEX.md)에 어느 화면에 썼는지 적습니다.
