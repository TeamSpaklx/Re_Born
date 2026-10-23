# 홈 화면 디자인 명세 (Figma 값)

홈 화면을 Figma에서 읽은 값(좌표·크기·에셋)을 정리한 문서입니다. **리본 전체의 규칙(색 역할·글자·간격·모션·컴포넌트·화면 패턴)은 [DESIGN_SYSTEM.md](./DESIGN_SYSTEM.md)에 있고**, 이 문서는 그 규칙을 홈에 적용한 결과의 정확한 수치입니다.
코드로 옮긴 값은 `lib/app/theme/`에 있으며, 화면 코드는 그 상수만 사용합니다 ([AGENTS.md](../AGENTS.md) UI 규칙).

- 출처 표시: **Figma** = Figma 노드에서 읽은 값, **추정** = Figma에 없어서 정한 값(확인 필요)
- **2026-10-23 수정안(`8632:1470`)과 2026-10-24 최신 안(`736:213`)이 나와 아래 값이 바뀌었습니다.** 화면 배경 `#FFF8F8`, 상단 핑크 그라디언트 없음, 기록 카드(Before)가 흰 카드 + 여우원숭이 일러스트로(높이 268), 카드 테두리 없음, 막대 색 3단계. 최신 안은 수정안과 같은 색·카드이고 기록 카드와 그 아래 위치만 다릅니다. After(`466:2704`)는 최신 안이 없어 핑크 카드 그대로입니다(확인 필요).
- Figma: [홈 화면 섹션](https://www.figma.com/design/W8guqOac0W71P3l7e23ZsN/%E1%84%85%E1%85%B5%E1%84%87%E1%85%A9%E1%86%ABRe_born-%E1%84%83%E1%85%B5%E1%84%8C%E1%85%A1%E1%84%8B%E1%85%B5%E1%86%AB?node-id=654-827) (파일 `W8guqOac0W71P3l7e23ZsN`, 섹션 `654:827`). 2026-10-21에 디자인이 새 Figma 파일로 옮겨지면서 색과 탭 바 "전체" 아이콘이 바뀌었습니다(노드 ID는 그대로, 이전 파일 `PJNOc5b1S7pmmtoObtP9mw`).

| 노드 | ID | 스크린샷 |
|---|---|---|
| 홈 Home[Before] **최신 안** (402×1270, 파일 `PJNOc5b1S7pmmtoObtP9mw`) | `736:213` (2026-10-24, 사용자가 직접 디자인) | [design/home_before.png](./design/home_before.png) |
| 홈 Home[Before] 수정안 (402×1205, 파일 `W8guq…`) | `8632:1470` | [design/home_before_v2.png](./design/home_before_v2.png) |
| 홈 Home[Before] 이전 안 | `282:160` | [design/home_before_v1.png](./design/home_before_v1.png) |
| 홈 Home[After] (402×1407) | `466:2704` | [design/home_after.png](./design/home_after.png) |
| ButtonNavigator[Liquid Glass] (4개 상태) | `289:1158` | [design/bottom_nav.png](./design/bottom_nav.png) |

## 0. 결정 사항과 전제

- **디자인이 있는 화면은 홈뿐입니다.** 관계·기록·전체 탭은 디자인이 없어서 흰 배경의 빈 화면으로 둡니다. 홈만 Figma와 100% 일치를 목표로 합니다.
- **하단 탭 4개:** 투데이(홈) / 관계 / 기록 / 전체. (Figma 컴포넌트의 상태 이름은 홈/관계/기록/마이이지만 화면에 보이는 글자는 투데이/관계/기록/전체입니다.)
- **고정 규칙:** 글자 크기 배율 1.0(시스템 글자 크기 설정 무시), 라이트 모드만, 세로 방향만. **다크 모드는 나중에 추가할 예정**이라 색은 `context.colors`로만 읽습니다.
- **화면 크기:** 디자인 기준은 402×874(iPhone 16 Pro)입니다. 좌우 여백 24를 고정하고 카드가 남는 폭을 채웁니다(402에서 카드 폭 354).
- **세로 스크롤 화면입니다.** Figma 프레임이 874보다 길어서(Before 최신 안 1270, After 1407) 내용이 스크롤됩니다. 하단 탭 바는 화면 아래에 고정되어 있습니다.
- 최신 Before 프레임 높이는 1270(마지막 카드 끝 1140 + 아래 130)이지만, 구현은 다른 탭과 같은 아래 여백 148(`scrollBottomPadding`)을 유지해 스크롤 끝이 1288입니다(차이 18, 확인 필요).
- 상태바와 홈 인디케이터는 시스템 영역이라 구현하지 않습니다. 헤더(로고·알림)가 스크롤과 같이 움직이는지는 Figma에 없어서 **추정**으로 "같이 움직임"입니다.
- 샘플 글자(규리님, 지민, 9월 13일 목요일 등)는 가짜 데이터 예시입니다.

## 1. 색상

`AppColors.light` (`lib/app/theme/app_colors.dart`)

| 용도 | 필드 | 값 | 출처 |
|---|---|---|---|
| 브랜드 핑크 (막대·활성 탭·강조 숫자·출석 알약) | `brand` | `#FF6090` | Figma |
| 주요 버튼 배경 | `cta` | `#FF6090` (지금은 `brand`와 같은 값, 나중에 달라질 수 있어 이름을 나눠 둠) | Figma |
| 버튼 글자 | `onCta` | `#FFFFFF` | Figma |
| 화면 배경 | `background` | `#FFF8F8` (수정안, 이전 `#FFFFFF`) | Figma |
| 기록 카드(핑크, After·상세 화면) | `cardPink` | `#FEDAE5` | Figma |
| 흰 카드 / 테두리 | `cardWhite` / `cardBorder` | `#FFFFFF` / `#EEE6E9` | Figma |
| 글자 검정 | `textBlack` | `#000000` | Figma |
| 글자 진한 회색 | `textStrong` | `#1A1A1A` | Figma |
| 글자 보조 | `textSecondary` | `rgba(76,83,95,0.8)` | Figma |
| 날짜 글자 | `textDate` | `rgba(68,68,68,0.6)` | Figma |
| 그래프 설명 글자 | `textGraphCaption` | `#70757F` | Figma |
| 그래프 이모지 | `emoji` | `#A0A7B4` | Figma (최신 안에서 이모지가 숨겨져 지금은 화면에 그리지 않음) |
| 칩 배경 | `chip` | `#F0F2F3` | Figma |
| 기록 카드(Before) 부제 | `recordCardSubtitle` | `#7D8492` | Figma 수정안 |
| 연한 핑크 버튼 / 그 위 글자 | `ctaSoft` / `onCtaSoft` | `#FFAFC7` / `#000000` | Figma 수정안 |
| 그래프 막대 3단계 | `barStrong` / `barMid` / `barLight` | `#D94F79`(Figma 변수 `브랜드 컬러`) / `#FF80A6` / `#FFB3CA` | Figma 수정안 |
| 홈 상단 바 덮개 | `topBarTint` | `rgba(255,255,255,0.1)` | Figma 수정안 |
| 토글 꺼짐 | `toggleOff` | `#E8D5DA` (팔레트 색) | **추정** |
| 위험 글자 / 위험 버튼 배경 | `danger` / `dangerTile` | `#E5484D` / `#FDECEE` | **추정** |
| 토스트 배경 | `toastFill` | `#1A1A1A` 불투명도 90% | **추정** |
| 모달 뒤 가림막 | `scrim` | 검정 50% | **추정** |
| 아바타 배경 | `avatar` | `#D9D9D9` | Figma |
| 아이콘 타일 배경 | `iconTile` | `rgba(217,217,217,0.5)` | Figma |
| 그래프 격자선 | `gridLine` | `rgba(160,167,180,0.5)` | Figma |
| 출석 패널 | `attendancePanel` | `#FFB2CA` | Figma |
| 출석 패널 위 글자 | `onAttendancePanel` | `rgba(255,255,255,0.8)` | Figma |
| 알림 버튼 배경 | `bellButton` | `rgba(153,153,153,0.1)` | Figma |
| 탭 바 배경 | `navFill` | `rgba(255,255,255,0.7)` | Figma |
| 탭 바 테두리 | `navBorder` | `#D0D0D0` | Figma |
| 탭 바 그림자 | `navShadow` | `rgba(0,0,0,0.1)` | Figma |
| 탭 바 선택 알약 | `navSelection` | `#EDEDED` (Figma 변수 `Fills - Vibrant/Tertiary`, SVG에도 같은 색) | Figma |

**배경:** 수정안에서 화면 배경은 `#FFF8F8`이고 상단 핑크 그라디언트는 없습니다(이전 안의 그라디언트는 2026-10-23에 제거, `backgroundGradient*` 상수도 삭제). 상단 바는 흰색 10% 덮개(`topBarTint`)와 블러(`topBarBlurSigma` 10)만 씁니다.

**Figma 팔레트 프레임(수정안, 8색):** `FFB2CA`(`attendancePanel`) / `FF6090`(`brand`) / `FFF5F8` / `E8D5DA`(`toggleOff`로 사용) / `A46273` / `FFF8F8`(`background`) / `FFFF5B`, `FFFFA0`(노랑, 쓰이는 곳을 모름 → 코드에 없음, 확인 필요). `FFF5F8`, `A46273`도 아직 쓰이는 곳이 없어 코드에 넣지 않았습니다.

## 2. 글자 (Pretendard)

`AppTextStyles` (`lib/app/theme/app_text_styles.dart`). 자간은 Figma px 값 그대로이고 줄 높이는 Figma 고정 px입니다(표에서 "기본"은 height를 지정하지 않음). 색은 스타일에 넣지 않고 화면에서 `context.colors`로 지정합니다.

| 스타일 | 크기 / 굵기 | 자간 | 줄 높이 | 쓰이는 곳 | 색 |
|---|---|---|---|---|---|
| `greeting` | 26 ExtraBold | −0.65 | 32 | "규리님, 오늘도 즐거운 하루 보내세요!" | textBlack |
| `sectionTitle` | 20 SemiBold | −0.5 | 32 | "최근 관계 신호", "오늘 해볼까요?", 인물 이름 | textBlack |
| `attendanceTitle` | 20 SemiBold | −0.5 | 기본 | "출석 체크" | textBlack |
| `recordCardTitleBefore` | 18 Bold | −0.45 | 기본 | "아직 오늘의 마음을 기록하지 않았어요" | textBlack |
| `recordCardTitleAfter` | 18 Bold | −0.45 | 24 | "오늘도 기록 완료! …" (숫자 6만 brand 색) | textBlack |
| `actionTitle` | 18 SemiBold | −0.45 | 32 | "지민님에게 가볍게 안부 묻기" | textBlack |
| `body` | 14 Medium | −0.35 | 기본 | "1분만 천천히 돌아볼까요?" | textSecondary |
| `button` | 14 SemiBold | −0.35 | 기본 | 버튼 글자 | onCta |
| `graphTitle` | 14 SemiBold | −0.35 | 기본 | "이번 주 감정 흐름" | textBlack |
| `weekday` | 14 Medium | −0.35 | 기본 | 월~일 | textStrong |
| `date` | 14 Regular | −0.35 | 기본 | "9월 13일 목요일" | textDate |
| `signalText` | 12 Medium | −0.3 | 32 | "최근 대화가 조금 줄었어요" (신호 카드는 textStrong, 액션 카드는 textSecondary) | — |
| `seeAll` | 12 Medium | −0.3 | 기본 | "전체 보기" | textSecondary |
| `chipLabel` | 12 SemiBold | −0.3 | 32 | "친구" | textSecondary |
| `graphMonth` | 12 Regular | −0.3 | 기본 | "✦ 9월" | textStrong |
| `graphCaption` | 12 Regular | −0.12 | 기본 | "긍정적인 감정이 … 하고 있어요." | textGraphCaption |
| `graphCaptionEmphasis` | 12 SemiBold + 밑줄 | −0.12 | 기본 | "조금씩 증가" | textGraphCaption |
| `caption` | 10 Regular | −0.25 | 기본 | "마지막 기록 5일 전" | textSecondary |
| `navLabel` | 10 Bold | −0.1 | 12 | 탭 라벨 | 기본 textStrong, 선택 brand |
| `attendanceNumber` | 40 Bold | −0.45 | 24 | 출석 숫자 "6" | brand |
| `attendanceUnit` | 20 Bold | −0.45 | 24 | "일" | textBlack |
| `graphEmoji` | 22 Regular | −0.22 | 기본 | (그래프 위 😁, 최신 안에서 숨겨져 지금은 안 씀) | emoji |

참고: Figma에서 "✦ 9월"에는 `CTGR`, `wdth` 가변 폰트 설정이 있지만 Flutter에서는 무시될 수 있습니다(추정, 확인 필요). 이모지는 플랫폼 기본 폰트(Apple Color Emoji / Noto)라 Figma와 모양이 다를 수 있습니다.

## 3. 모서리·간격·크기

`AppRadii`, `AppSpacing`, `HomeLayout`, `GraphLayout`, `AttendanceLayout`, `BottomNavTokens`

| 항목 | 값 |
|---|---|
| 카드 모서리 | 24 |
| 버튼 / 아이콘 타일 / 출석 패널 모서리 | 12 |
| 칩·아바타·알림 버튼·탭 바 | 100(원형/알약) |
| 그래프 막대 | 위쪽 모서리만 5 |
| 출석 알약 | 43×13, 모서리 10, 간격 5, 6개 |
| 화면 좌우 여백 | 24 |
| 흰 카드 테두리 | 2px `cardBorder` |
| 기록 카드 안쪽 여백 | 20 |
| 액션 카드 사이 간격 | 12 |

## 4. 홈 화면 레이아웃

아래 y는 Figma 프레임(Before) 기준 위쪽 좌표입니다. 코드에서는 세로로 쌓고 간격으로 배치하며, 이 좌표로 결과를 대조합니다.

### 4.1 위에서 아래 순서 (Before)

| 요소 | y | 높이 | 위 요소와의 간격 |
|---|---|---|---|
| 헤더 (상태바 62 아래 행): 로고 `169×42` @x24, 알림 `44` @x334 | 62(행) | 62 | — |
| 날짜 (14 Regular) | 128 | 17 | |
| 인사말 (2줄, 줄 32) | 149 | 64 | 날짜와 4 |
| 기록 카드 (Before 최신 안, 일러스트 포함) | 237 | **268** | 인사말과 24 |
| "최근 관계 신호" 제목 | 527 | 32 | 기록 카드와 **22** (이전 안 35) |
| "전체 보기 >" (x 오른쪽 끝 378) | 536 | 14 | |
| 신호 카드 | 571 | 104 | 제목과 12 |
| 감정 그래프 카드 | 697 | 180 | 신호 카드와 22 |
| "오늘 해볼까요? >" 제목 | 904 | 32 | 그래프 카드와 27 |
| 액션 카드 1 | 948 | 90 | 제목과 12 |
| 액션 카드 2 | 1050 | 90 | 카드 사이 12 |
| 하단 탭 바 | 프레임 아래에서 34 위 | 64 | 마지막 카드와 약 50 (스크롤 끝 여백) |

### 4.2 Before와 After의 차이

- **기록 카드만 다릅니다.** Before는 높이 **268**(안내문 + 여우원숭이 일러스트 + 버튼), After는 높이 399(아바타·완료 문구·버튼·출석 체크). 아래 섹션은 그만큼 밀립니다.
- ⚠️ **디자인 불일치 (확인 필요):** After는 기록 카드와 "최근 관계 신호" 제목 사이 간격이 23(카드 끝 636 → 제목 659)이고 Before 최신 안은 **22**(카드 끝 505 → 제목 527)입니다. 구현은 둘 다 22(`recordCardToSignalTitle`)로 통일합니다(After 최신 안 확인 필요).
- ⚠️ **디자인 불일치 (확인 필요):** "오늘 해볼까요?" 옆 `>` 화살표가 Before에만 있습니다. 액션 카드 오른쪽 원 색도 Before `#D0D0D0`, After `#EEE6E9`로 다릅니다(`radioCircle`, `radioCircleAfter`).
- 샘플 아바타 사진 3장(After)은 더미 이미지라 에셋에 넣지 않았습니다. 실제로는 오늘 기록한 인물의 프로필(없으면 `avatar` 색 원 + `person` 아이콘)을 보여줍니다(추정).

## 5. 컴포넌트

### 5.1 헤더
- **상단 바(`HomeTopBar`)는 화면 위에 고정**됩니다(사용자 요청 2026-10-22). 상태바 영역 + 헤더 행(62)이 스크롤하지 않고, 그 뒤로 지나가는 내용은 블러(`topBarBlurSigma` 10, 사용자 첨부 사진 기준 **추정**)로 흐려집니다. 수정안에서 핑크 그라디언트는 없고 흰색 10% 덮개(`topBarTint`)만 있습니다. 헤더의 로고를 누르면 화면 맨 위로 부드럽게 올라갑니다(0.5초, `HomeLayout.scrollToTopDuration`, **추정**). 블러가 날짜 글자를 번지게 해 헤더 바로 아래 옅은 회색 자국이 보이는 점은 확인 필요(블러를 빼면 사라지지만 스크롤 때 흐려지는 효과도 없어집니다).
- 배경 `rgba(255,255,255,0.1)`(행 전체, 거의 투명), 높이 62.
- 로고: `logo_reborn.png`(1000×250, 안쪽 여백 있음). Figma는 169×42 영역에 이미지를 꽉 채우고 `left −11.32%`, `top −0.64%` 오프셋을 줘서 글자가 영역 왼쪽 끝(x24)에서 시작하게 합니다. 글자가 보이는 폭은 약 130px입니다.
- 알림 버튼: 44×44 원, 배경 `bellButton`, 안에 `bell.svg`(28, 안쪽 여백 18.18%).

### 5.2 기록 카드 — Before (`UnWrite`, 최신 안 `736:301`)
- 354×**268**, 배경 `cardWhite`, **테두리 1px `cardBorder`**(안쪽 위에 겹쳐 그려 좌표가 변하지 않음, `AppCard.outlined`), 모서리 24. 안쪽 좌표는 테두리 1px 안쪽 기준이라 바깥 기준으로는 +1(좌우 21).
- 위에서(바깥 기준): 제목 27(높이 20, `recordCardTitleBefore` Bold 18 검정) → 부제 57(높이 20, `recordCardSubtitle` Medium 16, 색 `recordCardSubtitle` `#7D8492`) → **여우원숭이 일러스트 96**(151×98) → 버튼 194(폭 312·높이 52) → 아래 22. 글자는 **왼쪽 정렬**.
- **일러스트(`mascotLemur`):** Figma `핑크 앞치마를 입은 귀여운 여우원숭이 1`. 정사각 PNG(원본 1254×1254, 앱 번들은 604×604로 줄임)를 가로 151·세로 150.77(153.85%)로 놓고 **위쪽 98px만 보이게** 잘라(`ClipRect` + `OverflowBox` 위쪽 정렬), 가로 가운데. 아래 몸통은 버튼 뒤로 숨어 머리·귀·꼬리만 보입니다. 스크린 리더에는 장식이라 읽지 않습니다.
- 버튼: **`ctaSoft`(`#FFAFC7`)**, 모서리 12, 글자 `buttonLarge`(SemiBold 16, 검정)("감정 기록하기") 가운데. `CtaButton(soft: true)`.
- 이전 안: 핑크 `cardPink` 카드(172), 가운데 정렬, `cta` 버튼 + 흰 글자(`button` 14). 수정안(`8632:1470`)은 흰 카드(172)이고 일러스트가 없었습니다.

### 5.3 기록 카드 — After (`UnWrite`, 기록 완료)
- 354×399, 배경 `cardPink`, 모서리 24, 안쪽 여백 20, 블록 사이 간격 22.
- (카드 위쪽 y 기준) 아바타 행 20 (높이 44) / 완료 문구 86 (2줄, 높이 48) / 버튼 156 (높이 48) / "출석 체크 >" 제목 226 / 출석 패널 268 (높이 110) / 카드 끝 399(아래 여백 약 21).
- 아바타 행: 원 44(테두리 2px 흰색)가 x 0 / 31 / 62에 겹쳐 있고, 오른쪽 끝에 `seal_check.svg`(44).
- 문구: "오늘도 기록 완료!" 줄바꿈 "**6**일 연속 마음을 기록하고 있어요." (`recordCardTitleAfter`, 숫자만 `brand`).
- 버튼: 폭 314, 높이 **48**(Before는 52), `cta`, 글자 "오늘 기록 보기".
- 출석 패널(314×110, `attendancePanel`, 모서리 12): 왼쪽 15에서 "**6** 일"(`attendanceNumber` brand + `attendanceUnit`), 패널 안 y 약 31 중심. 2026-10-21 디자인부터 **오른쪽 불꽃 아이콘(`fire.svg`)은 없습니다.** 설명 "최장 기록 20일 · 6/20일"(`body` 14 Medium, `onAttendancePanel`) y 약 65 중심, 왼쪽 15. 진행 알약 6개 왼쪽 15·패널 안 y 약 86(43×13, `brand`, 간격 5). 연속 일수는 기록 작성 날짜로 앱에서 계산합니다([FRONTEND.md](./FRONTEND.md)).
- 알약 6개는 모두 `brand`로 채워져 있고(연속 기록 6일일 때의 모습), 연속 일수가 6 미만일 때 빈 알약 모양은 Figma에 없습니다(추정: 앞에서부터 `min(current, 6)`개만 채우고 나머지는 비움, 확인 필요).

### 5.4 신호 카드 ("최근 관계 신호")
- 354×104, 배경 `cardWhite`, 모서리 24. **수정안은 테두리가 없습니다.** 안쪽 좌표를 그대로 쓰도록 `AppCard.white`가 투명한 2px 자리를 남겨 둡니다(좌표는 테두리 안쪽 기준 그대로).
- 아바타 원 48 @(18,26) 배경 `avatar`, 안에 `person.svg`(36, 오프셋 6).
- 이름 "지민"(`sectionTitle`) x 87·y 18, 오른쪽에 간격 6으로 칩(38×22, `chip`, 모서리 100, 글자 `chipLabel` "친구").
- 문장 `signalText`(textStrong) 중심 y 57, 캡션 `caption` 중심 y 76 (둘 다 x 87).
- 오른쪽 끝 `chevron_signal.svg`(20) 세로 가운데, x 314.

### 5.5 감정 그래프 카드 ("이번 주 감정 흐름")
- 354×180, 배경 `cardWhite`, 모서리 24(수정안은 테두리 없음, 투명 2px 자리 유지). 좌표는 카드 안쪽 기준.
- 제목 `graphTitle` @(18,12) + `chevron_graph.svg`(17) 간격 2. "✦ 9월" `graphMonth` @(18,48). **이모지는 최신 안(`736:267`)에서 숨겨져 있어 그리지 않습니다**(이전 안: 😁 `graphEmoji`, 가장 높은 막대 위). 데이터의 `peakEmoji`는 남아 있지만 화면에 쓰지 않습니다.
- **격자선은 바닥선 하나만** 보입니다: y 124(바깥 기준 126), x 18, 폭 314, 두께 1, `gridLine`(`GraphLayout.baselineY`). 이전 안의 위쪽 선 3개(y 61 / 82 / 103)는 최신 안에서 숨겨져 있습니다.
- **좌표 기준 주의:** 제목·격자선·설명·월 라벨·이모지는 테두리(2px) **안쪽** 기준이고, 막대와 요일 라벨은 테두리 **바깥(카드 모서리)** 기준입니다. 구현은 막대·요일 라벨에서 2px를 빼 맞춥니다(`WeeklyEmotionCard._borderInset`).
- 막대 6개(월~토) 폭 27.437, 왼쪽 x 20 / 67.76 / 115.52 / 163.28 / 211.04 / 258.8, 바닥 y 126, 위쪽 모서리 5. **색은 값에 따라 3단계(수정안):** 값 ≤ 0.5(월·화·목)는 `barStrong` `#D94F79`, ≤ 0.9(수·토)는 `barMid` `#FF80A6`, 그 위(금)는 `barLight` `#FFB3CA`. 값 구간(`GraphLayout.barStrongMax`·`barMidMax`)은 Figma에 규칙이 없어 샘플 막대에서 정한 **추정**입니다(`WeeklyEmotionCard.barColor`). 샘플 높이: 월 9 / 화 21 / 수 48 / 목 36 / 금 75.8 / 토 66. **일요일은 막대가 없습니다**(값 없음). 가장 높은 막대 = 75.806px.
- 요일 라벨(월~일 7개) 14 Medium `weekday`, 중심 y 135, 막대 가운데 아래. 글자 상자(폭 13.21)의 왼쪽 x는 월 27.1 / 화 74.9 / 수 122.6 / 목 170.4 / 금 219.2 / 토 266.9 / 일 314.7.
- 설명 `graphCaption` @(18,159) 중심: "긍정적인 감정이 **조금씩 증가**하고 있어요."(강조 부분 `graphCaptionEmphasis` 밑줄).

### 5.6 액션 카드 ("오늘 해볼까요?")
- 354×90, `cardWhite`, 모서리 24(수정안은 테두리 없음, 투명 2px 자리 유지), 가로 배치
- 아이콘 타일 48×48(`iconTile`, 모서리 12, 안쪽 6) 안에 `forum.svg`(36).
- 글자 열 폭 215: 제목 `actionTitle`(높이 32) + 부제 `signalText`(`textSecondary`, 높이 16).
- 오른쪽 `radio_circle.svg`(20). After는 `radio_circle_after.svg`.

### 5.7 섹션 제목 줄
- 제목 `sectionTitle`. "최근 관계 신호" 오른쪽 끝에 "전체 보기"(`seeAll`) + `chevron_see_all.svg`(11.3×14), "오늘 해볼까요?" 오른쪽에 `chevron_section.svg`(20)(Before만).

### 5.8 하단 탭 바 (`BottomNavTokens`)
- 354×64, 가운데 정렬, 화면 아래에서 34 위(그 아래에 홈 인디케이터 34). 모서리 100(알약).
- 항목 4개: 폭 68, 간격 17, 아이콘 28 + 라벨(`navLabel`), 항목 영역 323×40(위 12). 선택 알약 92×56(`tab_selection.svg`, 선택된 탭 뒤, 왼쪽 x 5 / 89 / 174 / 258).
- 선택된 탭: 아이콘이 `*_active.svg`(분홍 `#FF6090`)로 바뀌고 라벨 색이 `brand`. 나머지는 검정 아이콘 + `textStrong` 라벨.

| 탭 | 라벨 | 기본 아이콘 | 선택 아이콘 |
|---|---|---|---|
| 1 | 투데이 | `tab_home.svg` | `tab_home_active.svg` |
| 2 | 관계 | `tab_relations.svg` | `tab_relations_active.svg` |
| 3 | 기록 | `tab_record.svg` | `tab_record_active.svg` |
| 4 | 전체 | `tab_all.svg` | `tab_all_active.svg` |

- **iOS 26 이상 (네이티브 `UITabBar`, Liquid Glass):** 탭 바 전체를 시스템이 그립니다(`ios/Runner/NativeTabBarView.swift`를 `lib/shared/widgets/native_tab_bar.dart`가 `UiKitView`로 얹음). 유리 재질, 선택 알약, 알약 이동 애니메이션, VoiceOver는 시스템이 처리합니다. 앱이 정하는 값은 아래뿐이고 모두 이 문서와 `lib/app/theme/`의 값을 Flutter가 네이티브에 넘깁니다.
  - 아이콘: 위 표의 Figma SVG를 Flutter가 28×28(기기 배율) PNG로 그려 넘깁니다(기본=검정, 선택=분홍 파일을 각각 사용).
  - 라벨: Pretendard Bold 10, 자간 −0.1, 색은 기본 `textStrong` / 선택 `brand`. Pretendard는 `CTFontManagerRegisterFontsForURL`로 UIKit에 등록합니다.
  - 크기: 시스템이 알약을 뷰 안쪽 좌우 21(`nativeSideInset`)에서 그리므로 뷰를 354+42 폭으로 만들어 **알약 폭이 354**가 되게 합니다(iOS 26.5·27.0 시뮬레이터에서 측정). 알약 높이는 시스템이 약 62로 정하고(Figma 64) 뷰 안에서 가운데에 놓입니다.
  - 이 모양은 Apple이 그리므로 Figma의 회색 테두리 `navBorder`, 그림자 `navShadow`, 선택 알약 색 `navSelection`은 **쓰이지 않습니다.** 선택 알약 크기와 라벨 위치도 시스템 값(**확인 필요**).
- **iOS 26 미만:** Android와 같은 Flutter 탭 바(배경 블러 강도만 다름)로, Figma 값(반투명 흰색 `navFill` + 테두리 1px `navBorder` + 그림자 `0 4 25 4 navShadow`)에 약한 블러(`iosBlurSigma` 8, **추정**)를 더한 Flutter 탭 바. 그림자는 알약 **바깥쪽에만** 그립니다(반투명 배경 아래로 비쳐 탁해지는 것을 막으려고 알약 모양을 even-odd 경로로 오려낸 영역에 그림). 선택 알약은 탭을 바꿀 때 200ms `easeOut`으로 옆 탭으로 미끄러집니다(**추정**). 알약 위치는 Figma 값(5/89/174/258)과 같고, 화면 폭이 좁아 탭 바 폭이 줄어도(폭 = min(354, 화면 폭 − 48)) 4등분 비율로 따라갑니다.
- **Android (블러 배경):** **Figma 시안이 없습니다(추정).** iOS 26 미만과 같은 Flutter 탭 바에 `BackdropFilter` 가우시안 블러(`androidBlurSigma` 20)를 더한 배경을 씁니다. 블러 강도·불투명도는 확인 필요.
- 탭 바 위치: 화면 아래에서 `max(시스템 하단 여백, 34)`만큼 위. 탭 바에 가려지지 않게 스크롤 화면의 아래 여백은 `scrollBottomPadding`(148)을 씁니다.
- 플랫폼 분기는 한 곳(`AppBottomNavBar`)에서만 합니다: iOS 26 이상 → 네이티브, 그 외 → Flutter 탭 바.
- 네이티브 탭 바는 탭을 누르면 Dart로 index를 알리고(`onTap`), Dart에서 탭이 바뀌면(화면 안 버튼 등) 선택 표시를 맞춥니다(`setSelectedIndex`). 같은 탭을 다시 누르면 그 탭의 첫 화면으로 돌아갑니다.
- **스크롤 가장자리 효과(Figma `Scroll Edge Effect - Soft`)는 쓰지 않습니다.** 탭 바 뒤에서 내용이 흐려지는 구간(블러·배경색 베일)을 요청으로 제거했습니다(2026-10-23). 내용은 탭 바 뒤로 그대로 지나갑니다.

### 5.9 공통 컴포넌트

토글·모달·토스트·설정 목록 등 공통 컴포넌트는 [DESIGN_SYSTEM.md](./DESIGN_SYSTEM.md) 7장(컴포넌트 카탈로그)으로 옮겼습니다.

## 6. 에셋 목록

`lib/app/theme/app_assets.dart`의 상수와 파일, Figma 노드의 대응입니다. 아이콘은 Figma가 내려준 SVG를 그대로 쓰며 `flutter_svg`로 그립니다(색을 코드에서 바꾸지 않음: 선택 상태는 파일이 다릅니다).

| 상수 | 파일 | 크기 | 쓰이는 곳 |
|---|---|---|---|
| `tabHome` / `tabHomeActive` | `assets/icons/ui/tab_home(_active).svg` | 28 | 탭 1 (`house-fill`) |
| `tabRelations` / `tabRelationsActive` | `tab_relations(_active).svg` | 28 | 탭 2 (`users-fill`) |
| `tabRecord` / `tabRecordActive` | `tab_record(_active).svg` | 28 | 탭 3 (기록) |
| `tabAll` / `tabAllActive` | `tab_all(_active).svg` | 28 | 탭 4 (Iconsax `menu`, 가로줄 3개). Figma는 마스크+선 SVG 두 장으로 내보내서 `flutter_svg`가 마스크를 못 그릴 수 있어, 선 SVG를 28×28 뷰박스의 Figma 위치(2.75, 7.4167)에 놓아 한 파일로 합쳤습니다 |
| `tabSelection` | `tab_selection.svg` | 92×56 | 선택 알약 |
| `person` | `person.svg` | 36 | 신호 카드 아바타 |
| `forum` | `forum.svg` | 36 | 액션 카드 |
| `bell` | `bell.svg` | 28 | 알림 버튼 |
| `sealCheck` | `seal_check.svg` | 44 | After 기록 카드 |
| `chevronSignal` | `chevron_signal.svg` | 20 | 신호 카드 |
| `chevronGraph` | `chevron_graph.svg` | 17 | 그래프 제목 |
| `chevronSeeAll` | `chevron_see_all.svg` | 11.3×14 | "전체 보기" |
| `chevronSection` | `chevron_section.svg` | 20 | "오늘 해볼까요?"(Before) |
| `chevronAttendance` | `chevron_attendance.svg` | 20 | "출석 체크 >" |
| `radioCircle` / `radioCircleAfter` | `radio_circle(_after).svg` | 20 | 액션 카드 오른쪽 원 |
| `logo` | `assets/images/logo_reborn.png` | 1000×250 | 헤더 로고 |
| `logoMark` | `assets/images/logo_mark.png` | 2000×2000 (표시 200) | 스플래시 로고 (Figma `651:730`, 배경 투명) |
| `mascotLemur` | `assets/images/mascot_lemur.png` | 604×604 (원본 1254×1254, 표시 151×150.77에서 위 98만 보임) | 기록 카드(Before) 일러스트 (Figma `736:309`, 배경 투명) |

- **아이콘 출처:** 하단 탭 바의 투데이·관계·기록은 Phosphor Icons(`house-fill`, `users-fill`, 기록), 전체는 Iconsax(`menu`)입니다. 그 밖의 홈 아이콘(`person`, `forum`, `bell`, 화살표류, `seal-check-fill`)의 출처는 확인하지 못했습니다(확인 필요). 새 아이콘이 필요하면 두 라이브러리에서 SVG로 받아 `assets/icons/ui/`에 넣습니다(Flutter 패키지는 쓰지 않음).
- 폰트: `assets/fonts/Pretendard-{Regular,Medium,SemiBold,Bold,ExtraBold}.otf` (v1.3.9, SIL OFL 1.1, `OFL-LICENSE.txt`). pubspec에서 weight 400/500/600/700/800으로 등록.
- Figma 에셋 URL은 7일 후 만료되므로 이미 이 레포에 내려받아 두었습니다. 새 에셋이 필요하면 디자이너에게 SVG/PNG를 받아 `assets/icons/ui/`에 넣고 `AppAssets`에 상수를 추가합니다.
- `tab_selection.svg`는 Figma가 내려준 파일에서 배경 블러용 `foreignObject`·`mix-blend-mode`를 지우고 알약 도형(`#EDEDED`)만 남겼습니다. `flutter_svg`가 `foreignObject`를 처리하지 못해 "unhandled element" 경고를 냈기 때문이고, 그려지는 모양은 같습니다.
- 번들에서 앱 아이콘 원본(`assets/icons/reborn_app_icon_1024.png`)은 제외하려고 `assets/icons/ui/` 폴더만 선언했습니다.

## 7. 확인이 필요한 부분 (추정으로 처리한 것)

1. (제거됨) 상단 배경 그라디언트는 수정안에서 없어짐
2. (결정됨) 헤더는 고정 + 블러 배경으로 구현(사용자 요청)
3. After의 기록 카드 아래 간격 23 vs Before 35 (→ 35로 통일)
4. Before에만 있는 "오늘 해볼까요? >" 화살표와 액션 카드 원 색 차이
5. Android 하단 탭 바 (Figma 시안 없음, 블러 값 추정), iOS 26 미만 탭 바 블러 강도(8)와 알약 이동 애니메이션, iOS 네이티브 탭 바가 Figma와 달라지는 부분(알약 높이 62 vs 64, 선택 알약 모양·색, 테두리·그림자)
6. 연속 일수가 6 미만일 때 출석 알약의 빈 모양, 샘플 아바타 사진 처리
7. (제거됨) 스크롤 가장자리 효과는 쓰지 않음
8. 이모지·가변 폰트 설정은 플랫폼에 따라 Figma와 다를 수 있음
9. (제거됨) 스크롤 가장자리 효과는 쓰지 않음(사용자 요청, 2026-10-23)
10. (제거됨) 상단 그라디언트 색
11. Figma 섹션 메모 "그날 적어놓았던 기록을 보여줌 →": 섹션 밖의 화면으로 가는 동작으로 보이며 디자인을 아직 못 봄
12. 그래프 막대 색 3단계를 정하는 값 구간(0.5 / 0.9)은 Figma에 규칙이 없어 샘플 막대에서 정한 추정
13. Home After(`466:2704`)는 수정안이 없어 핑크 카드 그대로(Before는 흰 카드로 바뀜) — 맞춰야 하는지 확인
14. 공통 컴포넌트(토글·모달·토스트·설정 목록)의 치수·색은 모두 추정(토스 구조 참고). 모달 확인 버튼 `brand`, 위험 색 `danger`/`dangerTile`, 토글 꺼짐 `toggleOff`(팔레트 `E8D5DA`), 토스트 `toastFill`, 가림막 `scrim`
15. 상단 바 블러: 날짜 글자가 번져 헤더 아래 옅은 회색 자국이 보임(블러 유지 여부 결정 필요)
16. 팔레트 프레임의 `FFF5F8`·`A46273`·노랑 2색의 용도

## 8. 지켜야 할 규칙

- 화면 코드에 색(`Color(0x…)`), 글자 크기·굵기·자간, 모서리, 에셋 경로를 직접 쓰지 않습니다. 없는 값이 필요하면 `lib/app/theme/`에 상수를 추가하고 이 문서에도 적습니다.
- 값을 바꾸면 이 문서, `lib/app/theme/`, `test/app/theme/app_theme_test.dart`를 같이 고칩니다.
- 구현한 화면은 iOS 시뮬레이터와 Android 에뮬레이터에서 실행해 `docs/design/`의 스크린샷과 나란히 비교합니다.
- (DESIGN_SYSTEM.md 9장으로 이동) **머티리얼(구글) 위젯을 화면에서 직접 쓰지 않습니다**: `Switch`, `SnackBar`, `AlertDialog`/`Dialog`+`TextButton`, `InkWell` 번짐 효과 대신 `lib/shared/widgets/`의 `AppToggle`, `showAppToast`, `showAppConfirmDialog`/`showAppDialog`, `SettingsGroup`/`SettingsRow`, `AppTextButton`, `Pressable`을 씁니다(5.9).
