# 디자인 레퍼런스 인덱스

다른 앱의 화면을 **구조·위계·상태 표현**을 배우려고 모은 참고 자료입니다. 색·글자·모서리 값은 따라 하지 않고 리본 디자인 시스템([DESIGN_SYSTEM.md](../../DESIGN_SYSTEM.md))의 토큰으로 다시 입힙니다.

- **이미지 파일은 저작권 때문에 git에 올리지 않습니다**(`.gitignore`). 이 폴더의 PNG는 각자 PC에만 있고, 이 표(출처·메모)만 공유합니다. 새로 모으면 같은 이름 규칙으로 이 폴더에 넣고 표에 한 줄 추가하세요.
- Figma 프레임이 있는 화면은 **Figma가 레퍼런스보다 우선**입니다.

## A. 팀이 직접 모은 레퍼런스 (16장, `user/`)

| 파일(`user/`) | 출처(추정) | 가져올 것 | 쓸 화면·컴포넌트 |
|---|---|---|---|
| `emotion-select-character.png` | How are you feeling (영문 앱) | 큰 굵은 질문 제목 + 3×3 감정 캐릭터 격자 + 라벨, 뒤로가기만 있는 단순 상단 | 기록 작성의 감정 선택 (감정 8종은 3열 격자) |
| `graph-report.png` | 한국 앱(여우 캐릭터) | 기간 탭(최신·주간·월간·연간) 세그먼트, 곡선 라인 + 점 + 영역 채움, 도넛 + 범례, 카드 안 카드 | 인물 상세 지수 그래프, 세그먼트, 리포트 카드 |
| `record-calendar-detail.png` | 한국 앱(감정 기록) | 월 달력(날짜 원 + 감정 캐릭터 + 빨간 점), 선택일 상세(제목·시각·태그 칩·본문·감정 비율 막대), 하단 단일 CTA | 기록 탭 달력·상세 (달력은 SPEC에 없고 기획 메모에만 있음) |
| `record-list-calendar-mentry.png` | Mentry | Week/Month 세그먼트, 날짜 머리글 + 감정별 파스텔 카드(태그 칩·시각), 월 달력 | 기록 목록의 날짜 그룹, 감정색 카드 |
| `all-tab-danggeun.png` | 당근 | 큰 제목 + 설정 아이콘, 프로필 카드(이름 + 칩 + 화살표), 아이콘 격자 메뉴, 카드 묶음, 알림 숫자 뱃지 | 전체 탭 구성, 뱃지 |
| `mypage-profile.png` | 한국 앱(채팅) | 프로필 행(아바타·이름·이메일·화살표), 핑크 요약 카드(2열 수치), 구분선 있는 메뉴 행 | 전체 탭 프로필·요약 카드·메뉴 |
| `analytics-sheet-empty.png` | Analytics 컨셉 | 월/연 세그먼트, 문구 카드(캐릭터), 감정 비율 막대, 곡선 차트, 바텀시트(날짜 휠·내보내기 라디오 + 검정 CTA), "나중에 다시 와요" 빈 상태 | 바텀시트, 빈 상태, 리포트 |
| `login-hellobot.png` | 헬로우봇 | 가운데 로고, 하단 고정 로그인 버튼(큰 알약), "다른 방법으로 로그인", 약관 문구 | F-01 로그인 레이아웃 (소셜은 SPEC에 없음 → 이메일만) |
| `bottom-sheet-toss.png` | 토스 | 둥근 위쪽 28, 핸들, 큰 제목 + 보조 설명, 항목 행, 버튼 2개(보조 회색 + 주요), 맨 아래 텍스트 링크, 뒤 화면 딤 | 바텀시트·모달 버튼 위계 |
| `settings-toss.png` | 토스 | 프로필 행, 회색 배경 위 둥근 흰 카드 묶음, 굵은 섹션 제목, 행 + 우측 값 + 화살표 | 설정 (이미 `SettingsGroup`으로 반영) |
| `skeleton-airbnb.png` | Airbnb | 상단 검색·탭은 유지, 큰 이미지·텍스트 줄만 연회색 블록 | 로딩 상태 |
| `notification-settings.png` | 한국 앱 | 큰 굵은 제목 + 보조 설명 + 우측 토글, 항목 사이 두꺼운 구분 띠 | 알림 설정 (이미 `AppToggle`) |
| `notifications-toss.png` | 토스 | 큰 제목, 우측 상단 "알림 설정" 링크, 읽지 않음 강조 배경, "지난 알림" 섹션, 행(아이콘 타일 + 제목·본문 + 시간 + 건수 칩) | 알림 목록 |
| `notifications-danggeun.png` | 당근 | 탭 밑줄 인디케이터, 아이콘 + 문장 + 시간, 휴지통 | 알림 목록 변형 |
| `permissions.png` | 한국 앱 | 큰 제목, "선택 권한", 아이콘 + 이름 + 설명 행, 하단 안내문 + 고정 CTA | 온보딩 권한 안내 |
| `onboarding-planfit.png` | Planfit (다크) | 상단 진행 막대, 질문 제목 + 부제, 하단에 쌓인 선택 카드(제목 + 설명) → 라이트로 해석 | 온보딩·동의·관계 유형 선택 |

## B. Aside가 모은 레퍼런스 (9개 항목 31장, 번호별 폴더)

항목 번호는 레퍼런스 수집 요청 때의 번호입니다(01 바텀시트, 02 스켈레톤, 03 오류 상태, 04 세그먼트, 05 날짜 그룹 목록, 08 로그인·가입, 12 감정 선택, 15 인물 프로필, 16 선 그래프). 영문 앱 위주이고, 출처 URL은 아래 표에 있습니다.

### Re:Born UI references: 01–03

실제 앱 화면을 공개 레퍼런스 페이지에서 확인하고 PNG로 보관했다. 출처의 ScreensDesign/Mobbin 워터마크는 수정하지 않았다.

| 번호 | 상대 파일명 | 앱 | 출처 URL | 구조 참고 메모 |
|---|---|---|---|---|
| 01-01 | `01-bottom-sheet/01-bottom-sheet-01.png` | Bible Chat | https://screensdesign.com/apps/bible-chat-daily-devotional/?vs=185385 | 상단 핸들이 있는 큰 시트에서 항목별 펼침과 장 번호 그리드를 결합한다. |
| 01-02 | `01-bottom-sheet/01-bottom-sheet-02.png` | Fishbrain | https://screensdesign.com/apps/fishbrain-fishing-app/?vs=183701 | 지도 위 반높이 시트에 설정 토글과 지도 스타일 선택지를 층별로 배치한다. |
| 01-03 | `01-bottom-sheet/01-bottom-sheet-03.png` | Klook | https://screensdesign.com/apps/klook-travel-hotels-leisure/?vs=119532 | 어두운 배경 위 짧은 시트에 제목, 구분선, 선택 표시가 있는 단일선택 목록을 둔다. |
| 01-04 | `01-bottom-sheet/01-bottom-sheet-04.png` | WebNovel | https://screensdesign.com/apps/webnovel-read-novels-manga/?vs=32553 | 드래그 핸들과 라디오 선택지를 둔 정렬 시트로 현재 선택 상태를 명확히 드러낸다. |
| 02-01 | `02-skeleton-loading/02-skeleton-loading-01.png` | Airbnb | https://mobbin.com/explore/screens/58e82be1-52e3-4b1f-a32e-bb9634fdc509 | 검색·카테고리·하단 탭은 유지하고 큰 사진 카드와 텍스트만 자리표시자로 남긴다. |
| 02-02 | `02-skeleton-loading/02-skeleton-loading-02.png` | Instagram | https://mobbin.com/explore/screens/322429b9-4758-49c2-94fd-a0d40fe8cbda | 검색어와 탭은 유지하고 아바타 원형과 두 줄 텍스트 막대를 반복해 결과 목록을 예고한다. |
| 02-03 | `02-skeleton-loading/02-skeleton-loading-03.png` | TikTok | https://mobbin.com/explore/screens/07db6453-5f31-4ba4-a73f-e7a6b1944e4c | 2열 상품 이미지와 가격·설명 자리표시자의 크기와 간격을 실제 카드 구조에 맞춘다. |
| 02-04 | `02-skeleton-loading/02-skeleton-loading-04.png` | Swiggy | https://mobbin.com/explore/screens/84eba2b2-0c15-4e03-9c3c-9067ad069bde | 로딩 문구 아래 작은 카테고리 카드와 큰 콘텐츠 카드를 함께 예고한다. |
| 03-01 | `03-error-state/03-error-state-01.png` | Depuff AI | https://screensdesign.com/apps/depuff-ai-debloat-your-face/?vs=206305 | 업로드 실패 이유를 중앙에 놓고 색이 강한 단일 재시도 버튼으로 복구 행동을 집중시킨다. |
| 03-02 | `03-error-state/03-error-state-02.png` | Gymondo | https://screensdesign.com/apps/gymondo-fitness-yoga/?vs=339784 | 기존 화면 맥락을 흐림 처리하고 오류 대화상자에서 취소와 재시도를 나란히 제공한다. |
| 03-03 | `03-error-state/03-error-state-03.png` | Xeela | https://screensdesign.com/apps/xeela-fitness/?vs=135967 | 실패한 스캔 작업을 구체적으로 설명하고 수동 입력·재스캔·재시도의 대안을 단계화한다. |
| 03-04 | `03-error-state/03-error-state-04.png` | HEY Email | https://screensdesign.com/apps/hey-email/?vs=98341 | 네트워크 오류 아이콘과 설명을 중앙에 묶고 뒤로 가기 및 재시도를 남긴다. |

#### 즐겨찾기

- **01-04 WebNovel:** 핸들, 제목, 선택 상태와 배경 딤 처리까지 작은 시트의 핵심 요소가 또렷하다.
- **02-02 Instagram:** 실제 목록의 아바타·두 줄 텍스트 리듬이 가장 쉽게 재사용된다.
- **03-03 Xeela:** 오류의 대상과 다음 행동을 구분하며 재시도 외 대안도 제공한다.

#### 품질·누락 메모

- **01-01**은 시트가 화면 대부분을 덮어 배경과의 층위 비교에는 약하다. **03-02**는 오류 문구가 일반적이고, **03-04**는 재시도가 텍스트 링크라 버튼 위계 참고에는 약하다.
- 한국 앱의 조건에 맞는 공개 실화면은 이번 12장에 포함되지 않았다. 영어 앱으로 수량을 충족했다.
- 출처의 워터마크가 보이지만 원본 그대로 보존했다. 로그인·결제 화면이나 실사용자 식별정보가 보이는 화면은 포함하지 않았다.

### Re:Born UI reference fragment: 04, 05, 08

| 번호 | 상대 파일명 | 앱 | 출처 URL | 구조 메모 |
|---|---|---|---|---|
| 04-01 | `04-segmented-control/04-segmented-control-01.png` | Monarch | https://mobbin.com/explore/screens/3d951da4-8f9f-44d6-93af-ac3ddef8c85f | 계좌 요약과 그래프 위에서 세그먼트가 콘텐츠 범위를 전환한다. |
| 04-02 | `04-segmented-control/04-segmented-control-02.png` | Ubank Money App | https://mobbin.com/explore/screens/8859286f-85f4-478f-8c0a-c08b2a7812a7 | 지출 카테고리 분석을 작은 탭형 선택지로 나누고 하단에 상세 목록을 둔다. |
| 04-03 | `04-segmented-control/04-segmented-control-03.png` | Shake Shack | https://mobbin.com/explore/screens/fd677895-a389-426f-a2b2-01bf50c25224 | 지도와 매장 목록의 두 뷰를 상단 세그먼트로 전환한다. |
| 04-04 | `04-segmented-control/04-segmented-control-04.png` | Shipt | https://mobbin.com/explore/screens/abcfa120-3e0f-47aa-9a2f-fea2d7a53ca5 | 배송 시간 선택을 세그먼트와 날짜·시간 슬롯 계층으로 분리한다. |
| 05-01 | `05-date-grouped-list/05-date-grouped-list-01.png` | Origin | https://mobbin.com/explore/screens/916f6d3e-c39a-4219-8be9-de1359de6c05 | 월별 요약 아래 날짜 제목을 두고 거래 행의 명칭·금액을 양끝에 정렬한다. |
| 05-02 | `05-date-grouped-list/05-date-grouped-list-02.png` | Wise | https://mobbin.com/explore/screens/8e6526ec-8344-4861-a18e-383605f19e6d | 거래 필터 칩 아래 날짜 구획을 놓고 아이콘·상대·금액을 반복 행으로 쌓는다. |
| 05-03 | `05-date-grouped-list/05-date-grouped-list-03.png` | Vivid | https://mobbin.com/explore/screens/bf32efdd-7f54-4e22-aaf0-3af8c90e2150 | 거래 요약 뒤 날짜 머리글 아래에 입출금 항목을 순서대로 배치한다. |
| 05-04 | `05-date-grouped-list/05-date-grouped-list-04.png` | KakaoBank | https://mobbin.com/explore/screens/cb5a2202-e64d-4c7d-95b4-7a1f2c437cec | 알림을 이번 주·지난 주 같은 시간 구획으로 묶고 각 행에 시점을 표시한다. |
| 08-01 | `08-login-signup/08-login-signup-01.png` | Shopify | https://mobbin.com/explore/screens/1d36cecc-52e6-429d-81a1-9b161529e8cf | 이메일·비밀번호 필드 아래 약한 비밀번호 오류와 조건 목록, CTA를 보여준다. |
| 08-02 | `08-login-signup/08-login-signup-02.png` | Wise | https://mobbin.com/explore/screens/fb5d07cf-480b-43ad-a1c8-5d35754dee0e | 비밀번호 작성 단계를 단일 필드·표시 토글·조건 안내·하단 완료 버튼으로 구성한다. |
| 08-03 | `08-login-signup/08-login-signup-03.png` | Turo | https://mobbin.com/explore/screens/fa92cda1-ab4f-4a94-9385-2c547d8f7c3d | 이메일 가입 양식에서 약관 동의 체크박스와 필수 입력 필드를 CTA 위에 둔다. |
| 08-04 | `08-login-signup/08-login-signup-04.png` | Hinge | https://mobbin.com/explore/screens/33741b39-2ab0-4f2c-9b07-041a561302ed | 이메일 입력·마케팅 수신 체크박스·하단 진행 버튼을 한 페이지에 정리한다. |

#### 즐겨찾기
- 04: Shake Shack. 한 제어로 지도/목록 전환을 명확히 보여준다.
- 05: Origin. 날짜 머리글, 반복 거래 행, 우측 금액 열의 위계가 뚜렷하다.
- 08: Shopify. 비밀번호 강도 피드백과 조건 목록, 가입 CTA의 관계가 분명하다.

#### 빈틈
- 04: 한국 앱의 공개 실화면 예시를 확보하지 못했다.
- 05: KakaoBank는 일자별이 아닌 주간 상대 구획이며, 나머지 예시는 화면에 한 날짜 구획만 보인다.
- 08: 한국 앱에서 이메일·비밀번호·약관·오류 상태를 함께 드러내는 적합한 공개 실화면을 확보하지 못했다. 캡처에 표시된 가입 정보는 Mobbin 예시 계정이며 원본 표시를 수정하지 않았다.

### Re:Born UI references: 12, 15, 16

공식 앱 스토어·개발사·공식 도움말에 공개된 예시 스크린샷만 수집했다. 이미지는 원본 내용을 수정하지 않고 PNG 형식으로만 저장했다.

| 번호 | 상대 파일명 | 앱 | 출처 URL (원본 이미지 / 공개 페이지) | 구조 메모 |
|---|---|---|---|---|
| 12 | `12-emotion-selection/12-emotion-selection-01.png` | D·LOG | [원본 이미지](https://play-lh.googleusercontent.com/kuZg95dze7vK792Kj2IEUCPUxCGZAY5QP_DvcH5gk1yUbv4xIowoYag0vsHsE-5qCFgbxLoj5DSzFmGm3iJt2A=w1200) · [공개 페이지](https://play.google.com/store/apps/details?id=com.softlunch.dlog&hl=ko) | 감정 선택지를 사진 일기 입력 카드 안에 배치하고 색·표정으로 상태를 구분한다. |
| 12 | `12-emotion-selection/12-emotion-selection-02.png` | 무디 Moodee | [원본 이미지](https://play-lh.googleusercontent.com/-s_0bW8YLhww7Z_uDTPHtsV4TQcMbxTmbbXgdd2lB6qYIk7azCtzmmvxFisu_EdQr8vLPTeXPSNfw6CeKDPy=w1200) · [공개 페이지](https://play.google.com/store/apps/details?id=com.bluesignum.little_lighthouse&hl=ko) | 상위 감정 질문 다음에 구체적 감정 태그를 칩으로 고르는 단계형 구조다. |
| 12 | `12-emotion-selection/12-emotion-selection-03.png` | Daylio | [원본 이미지](https://play-lh.googleusercontent.com/ddNqmRy7PsBGprNKpbB-I5plJPdMiK5WNJ1UmHLkTcgLF-7O_XeXAHE5aHhSYlbN_-Gtuh1WU-Kn5tX2q9o6=w1200) · [공개 페이지](https://play.google.com/store/apps/details?id=net.daylio&hl=ko) | 한 화면에 다섯 표정의 기분 척도를 가로로 놓고 선택 뒤 활동 기록으로 이어진다. |
| 12 | `12-emotion-selection/12-emotion-selection-04.png` | How We Feel | [원본 이미지](https://play-lh.googleusercontent.com/OGpcIOJSZAWSL1sORRSe8METfYuPdUpScbYnTOGWwDeMMOMlcNrjPvpbTRHZH3PvcrKTDFWLYPedONN4fyiCIg=w1200) · [공개 페이지](https://play.google.com/store/apps/details?id=org.howwefeel.moodmeter&hl=en_US) | 에너지와 쾌·불쾌 사분면의 컬러 영역에서 세부 감정 단어를 탐색한다. |
| 15 | `15-friend-profile-detail/15-friend-profile-detail-01.png` | 인물 | [원본 이미지](https://play-lh.googleusercontent.com/u-y-DQpbVkWYlerQzCfSNDBB0VUwDFJYL2UfdPQx5hdlBWXznx6eXdO_pY1VQya5T54idwlrPyKCfJlFRRlNpA=w1200) · [공개 페이지](https://play.google.com/store/apps/details?id=com.superprin.people&hl=ko) | 인물 헤더 아래 그룹·관계 메모와 만남 기록을 카드형 타임라인으로 쌓는다. |
| 15 | `15-friend-profile-detail/15-friend-profile-detail-02.png` | 링크노트 | [원본 이미지](https://play-lh.googleusercontent.com/v7HnkRRTYyNpNJ8HEaKNQNZXfXc0ryt9unbWWJ2XSb8h3fofY6VZ6ZVWEEdFa33-FDO8FmFWrgWypoTXr3-v=w1200) · [공개 페이지](https://play.google.com/store/apps/details?id=com.jeong.linknote&hl=ko) | 프로필 사진·태그·연락처·메모를 세로 구획으로 나눈 예시 상세 화면이다. |
| 15 | `15-friend-profile-detail/15-friend-profile-detail-03.png` | Linc | [원본 이미지](https://is1-ssl.mzstatic.com/image/thumb/PurpleSource112/v4/6a/5b/18/6a5b1815-83d1-8a15-3866-c2a9fff73fc6/a95dd0b5-913f-4b94-be21-141c5d6c116f_04.jpeg/1242x2688bb.png) · [공개 페이지](https://apps.apple.com/us/app/linc-friendship-tracker/id1513780616) | 사진과 이름 헤더 다음에 연락 주기·최근 접촉·관계 메모를 행동 카드로 배치한다. |
| 16 | `16-line-graph-trend/16-line-graph-trend-01.png` | 컬로그 Callog | [원본 이미지](https://callog.gkuer.com/assets/screenshots/report.webp) · [공개 페이지](https://callog.gkuer.com/) | 기간 탭 아래 감정 점수의 꺾은선을 놓고 요약 수치·해석 카드로 이어진다. |
| 16 | `16-line-graph-trend/16-line-graph-trend-02.png` | Daylio | [원본 이미지](https://play-lh.googleusercontent.com/PcqMKb_rJfOikItlV5cpRU7Sz6kIam_46061et_EfBz2Q8E0FYolStgaQ1-6Im3_eJV9VEglmnp5Dujy6VyP=w1200) · [공개 페이지](https://play.google.com/store/apps/details?id=net.daylio&hl=ko) | 통계 화면에서 날짜별 기분의 꺾은선과 평균·범례를 한 화면에 묶는다. |
| 16 | `16-line-graph-trend/16-line-graph-trend-03.png` | 하루온도 | [원본 이미지](https://play-lh.googleusercontent.com/oSp-jdXLww58m1E251dQ0af-iOckw4Rv8N0w4V420fzCt3Zbv2tNnJ1h6R5JLrpcISObx5W0mg5MztiipjhGOg=w1200) · [공개 페이지](https://play.google.com/store/apps/details?id=com.haruondo.emotion_app&hl=ko) | 일·주·월 전환 아래 온도 점수를 점 마커와 단일 꺾은선으로 표시한다. |
| 16 | `16-line-graph-trend/16-line-graph-trend-04.png` | Oura | [원본 이미지](https://ouraringhelp.zendesk.com/hc/article_attachments/7987387978259) · [공개 페이지](https://support.ouraring.com/hc/en-us/articles/360055983614-Using-Trends) | 일·주·월·연 범위 탭과 선택된 점의 수치·기준값을 차트 상단에 함께 보여준다. |

#### Favorites
- **12:** 무디 `12-emotion-selection-02.png`의 단계형 태그 선택은 짧은 입력과 풍부한 감정 어휘를 결합하기 좋다.
- **15:** Linc `15-friend-profile-detail-03.png`는 사람 헤더, 연락 주기, 최근 접촉과 후속 행동의 위계가 가장 명확하다.
- **16:** 컬로그 `16-line-graph-trend-01.png`는 한국어 감정 추이와 해석 카드, Oura `16-line-graph-trend-04.png`는 기간 전환과 선택 점의 값 표현이 좋다.

#### Gaps
- **15:** 밝은 화면에서 관계 지수·추세 그래프·상세 기록 목록을 모두 결합한 공개 예시를 찾지 못했다. 인물 화면은 다크 모드이며 링크노트는 스토어용 예시 프로필에 반복 숫자 `010-8888-8888`을 표기한다. 실사용자 정보는 아니지만 전화번호 모양이므로 공유 시 주의한다.
- **16:** 하루온도 화면은 샘플 점 수가 적고 하단 테스트 광고가 포함된다. Oura 공식 도움말 이미지는 414×606px로 낮은 해상도다. 감정 그래프에서 특정 점을 탭했을 때 날짜·수치 팝오버까지 보여주는 고해상도 공개 예시는 확보하지 못했다.

## C. 아직 없는 레퍼런스 (찾아서 `user/`에 추가)

| # | 필요한 것 | 쓰이는 화면 | 찾을 때 포인트 |
|---|---|---|---|
| 1 | 체크리스트(할 일) 화면 | 전체 탭 F-04 | 체크 원 채워지는 방식, 완료 항목 흐림·취소선, 진행률, 항목 추가 입력줄 (투두·루틴 앱) |
| 2 | 기록 작성 폼 | F-03 | 본문 입력 + 인물·감정·강도 선택 + 글자 수 + 저장 CTA 위치, 키보드가 올라온 상태 |
| 3 | 인물(관계) 목록 + 추가 폼 | F-02 | 인물 카드 목록, 관계 유형 선택, 이름 입력 오류(중복·길이) |
| 4 | 인물 상세(밝은 화면) | F-09 | 프로필 + 지수 요약 + 선 그래프 + 최근 기록 목록을 합친 화면 |
| 5 | 약관·개인정보 동의 화면 | F-01·F-11 | "전체 동의" + 필수/선택 체크 + 상세 보기 화살표 + 하단 CTA (한국어) |
| 6 | 이메일 로그인·가입 폼(한국어) | F-01 | 입력창 오류 문구, 비밀번호 보기 토글, 하단 고정 버튼 |
| 7 | 인사이트·제안 상세 | F-07·F-08 | 경고 → 근거 수치 → 제안 목록 → "체크리스트에 담기" |
| 8 | 위기 안내 화면 | F-13 | 부드러운 톤의 안전 안내, 연락처 행, "확인했어요" |
| 9 | 한국어 오류·빈 상태 | 공통 | 네트워크 오류, 기록·인물·알림 없음: 일러스트 + 한 줄 + 버튼 |
| 10 | 계정·데이터 삭제 흐름 | F-11 | 탈퇴 안내 → 확인 체크 → 재인증 → 완료 |
| 11 | 스와이프 삭제·길게 누르기 메뉴 | 기록·체크리스트 | 목록 스와이프 삭제와 확인 방식 |
| 12 | 감정 캐릭터 8종 에셋 | 감정 선택·달력·기록 카드·그래프 | 기쁨·감사·설렘·평온·서운함·불안·분노·슬픔 각각의 정사각 PNG/SVG와 대표색 (사용자가 준비) |
