# 프론트엔드 구조와 데이터 계약

`frontend-integration`의 Flutter 화면과 메모리 저장소, 향후 데이터 연결에 필요한 인터페이스를 정리한 문서입니다. 이 브랜치에는 Supabase SDK 초기화만 있고 Auth·DB 연결과 서버 코드는 없습니다.
화면 디자인 값은 [DESIGN_SYSTEM.md](./DESIGN_SYSTEM.md), 사용하는 기술은 [TECH_STACK.md](./TECH_STACK.md), 기능 정의는 [SPEC.md](./SPEC.md)를 봅니다.

## 1. 폴더 규칙

```
lib/features/<기능>/
  models/         데이터 모양 (순수 Dart, Flutter·Supabase를 모름)
  data/           Repository 인터페이스 + 메모리 구현
  presentation/   화면, 상태(provider), 이 기능 전용 위젯
test/features/<기능>/   lib과 같은 구조
```

- 화면은 **Repository 인터페이스만** 봅니다. Supabase를 직접 부르지 않습니다.
- 프론트는 먼저 메모리 가짜 구현(`FakeXxxRepository`)으로 화면을 완성합니다.
- 백엔드는 같은 인터페이스를 구현한 `SupabaseXxxRepository`를 만들고, provider 한 줄만 바꿔 교체합니다. 그래서 **프론트와 백엔드는 서로 다른 파일을 건드립니다.**
- 감정 점수·키워드·감정 수치 통계·연속 기록 계산은 UI·DB를 모르는 **순수 Dart 함수**로 만들고 단위 테스트를 붙입니다 (`lib/features/analysis/`).

## 2. 화면 구성

| 탭 | 내용 | 디자인 | 지금 상태 |
|---|---|---|---|
2026-11-28 회의로 인물 기능을 없애고 관계 탭을 분석 탭으로 바꿨습니다(SPEC 0장).

| 탭 | 내용 | 디자인 | 지금 상태 |
|---|---|---|---|
| 홈 (`/today`) | 인사, 기록 카드(전: 기록 유도 / 후: 연속 기록 + 오늘 일기의 AI 코멘트), 이번 주 감정 흐름, 오늘 해볼까요?(최근 일기의 AI 제안) | Figma 있음(관계 신호 섹션은 뺌) | 구현됨 |
| 분석 (`/analysis`) | 기간(1주·1달), 감정 수치 그래프(날짜별 평균 점수 −5~+5), 감정 분포, 강도 1~5단계 분포, 최근 AI 코멘트 (F-09) | 레퍼런스 해석(Figma 없음, 추정) | 구현됨 |
| 기록 (`/record`) | 달력 / 목록 / 체크리스트 칸. 작성(감정·강도 1~5단계 기준표·본문), 저장 직후 결과 화면(AI 코멘트·제안 담기), 상세, 밀어서 삭제 (F-03, F-04) | 레퍼런스 해석 | 구현됨 |
| 마이 (`/all`) | 프로필·요약(총 기록·연속 기록·최장 연속), 설정(앱 사용: 알림·알림 설정·화면 모드·앱 잠금 / AI 코멘트: 말투 / 계정: 로그아웃·기록 전체 삭제·계정 삭제 / 도움: 도움받을 곳) (F-10, F-11) | 레퍼런스 해석(아이콘 목록형 설정) | 구현됨 |

탭 위로 쌓이는 화면: 스플래시, 로그인, 알림 목록·설정, 계정 삭제(재인증), 기록 작성·결과(`/record/:id/result`)·상세, 위기 안내(시트). 홈의 "체크리스트 보기"는 `AppRoutes.checklist`(`/record?view=checklist`)로 기록 탭 체크리스트 칸을 엽니다.

**이메일 로그인·가입:** 로그인 화면(`/login`)에서 이메일·비밀번호로 로그인하고, "이메일로 회원가입"(`/signup`)에서 이메일·닉네임·비밀번호·비밀번호 확인을 한 화면에 받아 가입합니다(`AuthActions.signIn`/`signUp`, 메모리 구현). 가입하면 바로 로그인 상태로 투데이에 갑니다(설치 후 첫 로그인이면 앞에 끝 화면이 한 번 끼어듭니다). 동의 화면·약관 안내는 2026-11-28에 뺐습니다. 계정 삭제는 확인 체크 + 비밀번호 재입력입니다. 실제 연결은 백엔드가 Supabase Auth Email provider를 켠 뒤 provider 한 줄 교체.

**프로필 사진:** 전체 탭 프로필 행 → 프로필 편집 시트(사진 찍기·앨범에서 선택·기본 캐릭터로 되돌리기·닉네임). 사진 경로는 `AppSettings.profileImagePath`에 메모리로만 저장되어 앱을 다시 켜면 기본 캐릭터로 돌아갑니다(백엔드가 스토리지 연결 시 교체). 사진이 없으면 인물·사용자 모두 감정 캐릭터 7종 중 고정 배정된 하나가 임시 프로필입니다.

**알림 권한·리마인드:** `NotificationService`(`core/platform/notification_service.dart`). 가입 마지막 "알림 켜기"와 알림 설정의 리마인드 토글이 OS 권한을 요청하고, 허용되면 매일 정해진 시각(기본 21:00)에 로컬 알림을 예약합니다. 거부되면 토글이 켜지지 않고 안내만 나옵니다. 설정이 메모리 저장이라 앱을 켤 때 `syncReminder()`가 저장된 설정대로 예약을 맞춥니다(켜져 있지 않으면 남은 예약 취소). 알림 문구에는 기록 내용이 들어가지 않습니다.

**홈 인사말:** `GreetingPool`(8개 문구)에서 앱을 켤 때 한 번 뽑습니다(`greetingIndexProvider`). 출석 체크 패널은 `HomeLayout.showAttendance`(false)로 숨겨 둡니다. "오늘 해볼까요?"는 이미 체크리스트에 있는 제안(완료 포함)을 빼고 두 장을 보여 주고, 담으면 원이 채워졌다가 0.7초 뒤 다음 제안이 옵니다.

**시작 화면:** 앱은 스플래시(`/splash`, Figma `805:953`: 흰 배경, 가운데 로고 160, 아래 "TeamSpaklx")로 시작합니다. 스플래시 뒤의 이동은 `splash_screen.dart`의 `_goNext()` 한 곳에서 정합니다. 로그인한 상태면 최소 1초(홈 데이터가 준비될 때까지, 최대 3초) 보여 준 뒤 투데이(`/today`)로, 아니면 1초 뒤 로그인(`/login`)으로 서서히 넘어갑니다. 설치 후 처음 켠 것이면(`IntroStore.seen == false`) 로그인 앞에 인트로 온보딩(`/intro`)이 한 번 끼어듭니다(아래 인트로 항목). 시간 값은 Figma에 없는 추정값입니다. 시작할 때 저장된 설정대로 기록 리마인드 예약도 맞춥니다(`syncReminder`).

**인증 흐름(F-01):**
- 로그인 화면(`/login`)은 RE:BORN 워드마크(Figma `8877:1929` 크기·좌우 여백) 아래에 이메일·비밀번호 입력, 로그인 버튼, "이메일로 회원가입" 링크가 있습니다. 이메일 로그인 화면은 Figma에 없어 공통 컴포넌트(`AppTextField`·`PasswordField`·`CtaButton`)로 구성했습니다. 소셜 로그인(구글·카카오)은 2026-11-27에 뺐습니다.
- 가입 화면(`/signup`)은 한 화면입니다(별도 동의·첫 인물·알림 안내 단계 없음).
- **인트로 온보딩(`/intro`, Figma `8877:1945`):** 설치 후 최초 1회만 스플래시와 로그인 사이에 보입니다. "시작하기"를 누르면 `IntroStore.markSeen()`(`shared_preferences`의 `intro_seen`)으로 기록하고 로그인으로 갑니다. 로그아웃·계정 삭제 뒤에도 다시 보이지 않고, 이미 로그인된 상태로 켜면 건너뜁니다. Figma의 A/B 시안(진행 막대)은 실험안이라 만들지 않았습니다.
- **인트로 끝 화면(`/start`, Figma `8877:1965`):** 설치 후 첫 로그인·가입 직후, 투데이로 가기 전에 한 번만 보입니다(`goHomeAfterAuth`가 `IntroStore.startSeen`을 보고 갈림). "시작하기"를 누르면 `markStartSeen()`(`intro_start_seen`)으로 기록하고 투데이로 갑니다. 검은 배경이고, Figma 메모대로 분홍 버튼 글자는 흰색 대신 어두운 색(`onStartCta`)입니다.
- 로그아웃·계정 삭제 뒤에는 로그인 화면으로 갑니다.
- 예외 처리 (`LoginScreen`, `SignupScreen`):

  | 상황 | 처리 |
  |---|---|
  | 이메일 형식·비밀번호 길이·확인 불일치·닉네임 | 입력창 아래 안내, 요청 보내지 않음 |
  | 이메일·비밀번호 불일치(`invalidCredentials`) | 비밀번호 아래 안내 |
  | 이미 가입된 이메일(`emailTaken`) | 가입 화면 이메일 아래 안내 |
  | 네트워크 오류 | 토스트 안내, 다시 누를 수 있음 |
  | 알 수 없는 오류 | 일반 토스트 + `AppErrorLog`(`login`·`signup`) |
  | 처리 중 | 버튼을 막고 "로그인 중…"/"가입 중…" 표시(연타 방지) |
- **로그인 유지(임시):** 인증은 메모리 구현(`InMemoryAuthRepository`)이지만, `main.dart`가 `PrefsAuthSessionStore`(`shared_preferences`의 `auth_session_email`)를 넘겨서 앱을 다시 켜도 로그인 상태가 유지됩니다. 저장하는 것은 이메일뿐이고 비밀번호는 저장하지 않습니다. 가입한 계정 자체는 메모리에만 있어 다시 켜면 데모 계정만 남고, 기록 데이터도 샘플로 돌아갑니다.
- **Supabase Auth를 붙일 때:** `main.dart`의 `authRepositoryProvider` override 한 줄을 Supabase 구현(`signInWithPassword`·`signUp`)으로 바꾸고, `auth_session_store.dart`는 지웁니다(세션은 SDK가 저장). Supabase에서 이메일 인증(Confirm email)을 켜면 가입 직후 세션이 없으므로 "메일을 확인해 주세요" 상태가 추가로 필요합니다.
- 시연용 이메일 계정은 `demo@reborn.app` / `reborn1234`입니다(메모리에만 저장). 알림은 앱 안 목록(AI 코멘트 도착, 24시간 지난 것은 읽음으로 봄)만 구현했고 기기 푸시(F-10 확장)는 없습니다.

## 3. 홈 화면 데이터 모양

홈 화면 하나가 `HomeSummary`를 받아 그립니다. 필드 이름과 의미를 백엔드와 맞춥니다.

**당겨서 새로고침:** 투데이를 아래로 당기면 `homeSummaryProvider`를 다시 읽습니다(`AppRefreshControl`). 새로고침 중에도 지금 내용은 그대로 보이고, 실패하면 내용을 유지한 채 "새로고침하지 못했어요" 토스트를 띄우고 `AppErrorLog`(`home-refresh`)에 남깁니다. 처음 불러올 때의 실패만 오류 화면(`HomeErrorView`)을 보여 줍니다. 지금은 메모리 저장소라 새로고침해도 바뀌는 게 없고, Supabase를 연결하면 서버의 최신 값을 가져옵니다.

```dart
class HomeSummary {
  String nickname;              // "규리" → 인사말 "규리님, 오늘도 즐거운 하루 보내세요!"
  DateTime today;               // 날짜 표시 "9월 13일 목요일"
  bool todayRecorded;           // true면 After(기록 완료 카드), false면 Before(기록 유도 카드)
  RecordStreak streak;          // After의 "N일 연속"
  WeeklyEmotionFlow weeklyEmotion;       // "이번 주 감정 흐름" 그래프
  List<ActionSuggestion> suggestions;    // "오늘 해볼까요?" 카드들(최대 2장)
  bool suggestionsDone;         // 제안을 모두 담았으면 true
  String? todayEntryId;         // "오늘 기록 보기"
  String? todayComment;         // After 카드의 AI 코멘트(없으면 null)
  bool todayCommentPending;     // 코멘트를 받는 중
}
```

### RecordStreak — 연속 기록 (출석 체크)

```dart
class RecordStreak {
  int current;   // 현재 연속 기록 일수 (예: 6)
  int longest;   // 최장 연속 기록 일수 (예: 20)
}
```

- **DB 컬럼을 새로 만들지 않습니다.** 기록(`entries`)의 작성 날짜만으로 앱에서 계산합니다.
- 계산 규칙(프론트가 함수로 구현): 날짜(자정 기준, 기기 시간대)별로 기록이 1건 이상 있으면 그날을 "기록한 날"로 보고, 오늘(또는 어제까지)부터 거꾸로 연속된 날 수가 `current`, 지금까지 가장 긴 연속이 `longest`.
- 출석 알약은 6개입니다. Figma에는 "6일 연속 / 최장 20일 · 6/20일" 모양만 있고 알약 채움 규칙이 없습니다 → 임시로 `min(current, 6)`개를 채움(확인 필요).

### WeeklyEmotionFlow — 이번 주 감정 흐름

```dart
class WeeklyEmotionFlow {
  int month;                  // "✦ 9월"
  List<double?> days;         // 월~일 7개, 0.0~1.0 또는 null(막대 없음)
  int? peakIndex;             // 가장 높은 요일 (이모지가 얹힘), null이면 이모지 없음
  String? peakEmoji;          // "😁"
  String summary;             // "긍정적인 감정이 조금씩 증가하고 있어요."
  String? summaryEmphasis;    // 밑줄 강조 부분 "조금씩 증가"
}
```

- 막대 높이 = `value × 75.806px`(Figma의 가장 높은 막대). 값이 `null`이면 막대를 그리지 않습니다(일요일).
- `value` = 그날 일기 점수(−5~+5) 평균을 `(평균 + 5) / 10`으로 0~1로 바꾼 값입니다(`weekly_emotion_builder.dart`, 임시 규칙).
- `summary` 문장도 어떤 규칙으로 만들지(증가/감소/유지) 정해야 합니다.

### ActionSuggestion — 오늘 해볼까요?

```dart
class ActionSuggestion {
  String id;
  String entryId;   // 제안이 나온 일기(카드를 누르면 그 일기 상세)
  String title;     // "내일 30분 휴식 시간 정해 두기"
  String reason;    // 그 일기의 AI 코멘트
  bool added;       // 방금 담아서 원이 채워진 상태
}
```

- AI 코멘트가 있는 가장 최근 일기의 제안(SPEC F-08) 중 아직 체크리스트에 없는 것(완료 포함)을 앞에서 두 장 보여 줍니다.
- 원을 누르면 F-04 체크리스트 항목이 `source = suggestion`, `entryId`로 생깁니다.

### AI 코멘트 (`AiCommentService`)

```dart
abstract interface class AiCommentService {
  Future<AiFeedback> analyze(Entry entry, {required CommentTone tone});
}
class AiFeedback { String comment; List<String> suggestions; DateTime createdAt; }
enum CommentTone { warm /* 다정하게 */, plain /* 담백하게 */ }
```

- **교체 지점:** `lib/app/data_providers.dart`의 `aiCommentServiceProvider`. 지금은 `FakeAiCommentService`(감정 방향 × 강도 구간 × 말투로 앱 안 문장 풀에서 고름, 0.8초 지연, 제안 3개)입니다. 백엔드 API가 나오면 그 API를 부르는 구현으로 한 줄 바꿉니다. **외부 AI API 키는 앱에 넣지 않습니다.**
- 흐름(`AnalysisService` + `RecordActions`): 저장 → 규칙 분석(점수·키워드, `pending`) → 결과 화면으로 이동 → 뒤에서 `requestFeedback` → 도착하면 `done` + 화면 갱신. 실패하면 `failed`와 "다시 분석"(`retryAnalysis`). 일기를 고치면 코멘트를 지우고 다시 받습니다.
- 코멘트는 결과 화면·기록 상세(`AiFeedbackCard`)와 홈 기록 완료 카드에 보이고, 분석 탭 "최근 AI 코멘트"와 알림 목록에도 나옵니다.

### 감정 강도 (`IntensityLevel`)

1~5단계 기준표(감지됨·의식됨·영향 있음·크게 영향·압도됨, SPEC 0장)는 `lib/features/entries/models/intensity_level.dart` 한 곳에 있습니다. 작성 화면 `IntensitySelector`는 단계마다 번호·이름·기준 설명을 세로로 보여 주고, 목록·상세는 점 5개와 단계 이름을 씁니다. 점수 = 감정 방향 × 강도(−5~+5).

## 4. Repository 인터페이스

```dart
abstract interface class HomeRepository {
  Future<HomeSummary> fetchHome(DateTime today);
}
```

- 프론트: `FakeHomeRepository`(샘플 데이터, 지연 시간 설정 가능, Before/After 둘 다 만들 수 있게 `todayRecorded`를 주입)
- 백엔드: `SupabaseHomeRepository` — entries·people·insights·todos를 읽어 위 모양으로 조립. 계산(연속 기록, 신호 판정)은 프론트가 만든 순수 함수를 호출하거나 같은 규칙을 따릅니다.
- 교체: `homeRepositoryProvider`의 한 줄(`FakeHomeRepository()` → `SupabaseHomeRepository(...)`).
- 오류: 불러오기에 실패하면 예외를 던지고, 화면이 오류 화면과 "다시 시도" 버튼을 보여줍니다(SPEC의 재시도 규칙).

> **2026-10-23 갱신:** 아래 4장의 `HomeRepository.fetchHome`은 **없어졌습니다.** 홈 요약은 `lib/features/analysis/home_summary_builder.dart`(`buildHomeSummary`)가 저장소들에서 앱 안에서 조립합니다(백엔드는 4-1장의 저장소만 구현). `FakeHomeRepository`도 없어지고 샘플은 `sample_data.dart`에 있습니다.

## 4-1. 저장소 계약 (백엔드가 구현할 것) — 2026-10-22 갱신

점수·키워드·통계 계산은 **앱(순수 Dart)** 이 하고, 백엔드는 **저장소(읽기·쓰기 + RLS)와 AI 코멘트 API**를 구현합니다(2026-11-28 갱신).
위 4장의 `HomeRepository`는 홈 화면 연결 작업에서 없어지고, 홈 요약은 아래 저장소들에서 앱이 조립합니다.

| 인터페이스 (파일) | 테이블 | 하는 일 |
|---|---|---|
| `EntriesRepository` (`lib/features/entries/data/entries_repository.dart`) | `entries` (+ `ai_feedback`) | 일기 목록·조회·추가(pending)·수정(분석 결과·AI 코멘트 포함)·삭제 |
| `TodosRepository` (`lib/features/todos/data/todos_repository.dart`) | `todos` | 체크리스트 목록·추가(`entryId`)·수정(완료)·삭제 |
| `SettingsRepository` (`lib/features/settings/data/settings_repository.dart`) | `profiles` | 닉네임·사진·알림 설정·AI 코멘트 말투 |
| `AiCommentService` (`lib/features/ai_comment/data/ai_comment_service.dart`) | (백엔드 API) | 일기 → 코멘트·행동 제안 |

- **교체 지점은 한 곳:** `lib/app/data_providers.dart`의 provider 한 줄씩(`InMemory…` → `Supabase…`). 화면과 분석 코드는 건드리지 않습니다.
- 메모리 구현과 샘플 데이터(`lib/features/analysis/data/sample_data.dart`)는 백엔드 연결 전 시연용입니다.
- 일기 저장 → 규칙 분석 → AI 코멘트 순서는 `AnalysisService`(`lib/features/analysis/analysis_service.dart`)가 처리합니다.
- 분석 규칙은 `lib/features/analysis/`의 순수 함수(`emotion_analyzer`, `emotion_stats_builder`, `weekly_emotion_builder`, `home_summary_builder`, `crisis_checker`, `record_streak_calculator`)입니다.

## 4-2. 앱 내부 오류 처리 (F-12, P-11)

- `main.dart`가 `installErrorHandlers`로 처리되지 않은 오류를 `AppErrorLog`(최근 50건, 메모리)에 남깁니다. 배포판에서는 위젯 오류가 빨간 화면 대신 안내 문구로 보입니다.
- 기록에는 **오류 종류·위치·호출 스택만** 남고 오류 메시지는 버립니다(메시지에 일기 본문이 섞일 수 있음). 사용자에게 보여 줘도 안전한 문구는 `AppException`으로 던집니다.
- 저장·분석·체크리스트 저장이 실패하면 오류를 기록하고 화면에는 안내와 재시도를 보여 줍니다(`AnalysisService.onError`, 작성 화면, 체크리스트).
- 외부 분석 도구로는 보내지 않습니다(확장 기능). 나중에 보낸다면 이 기록만 보냅니다.

## 4-3. 앱 잠금 (로그인 없이 기기 인증)

- 마이 > 앱 사용 > '앱 잠금'으로 켭니다(기본 꺼짐, 켤 때 한 번 인증 성공해야 켜짐). 켜짐 여부만 `shared_preferences`에 저장하고 `main.dart`가 첫 프레임 전에 읽습니다.
- `AppLockGate`(`lib/features/security/presentation/app_lock_gate.dart`)가 `MaterialApp.builder`에서 모든 화면을 감싸고, 잠긴 동안 `LockScreen`을 **덮기만** 합니다. 라우트를 바꾸지 않으므로 잠금을 풀면 보던 화면 그대로입니다. 잠긴 동안 뒤 화면은 그리지 않고(`Offstage`, 상태는 유지) 터치·스크린 리더에서도 빠지고, Android 뒤로 버튼도 막습니다(`AppLockBackGuard`, 라우터보다 먼저 불리도록 `main.dart`에서 `runApp` 전에 등록). 단, 탭 첫 화면처럼 닫을 화면이 없으면 Android가 뒤로 버튼을 직접 처리해 앱이 백그라운드로 나가고, 다시 열면 또 인증합니다.
- 언제 잠그나: 앱을 처음 열 때, 백그라운드(홈 화면·다른 앱)에 다녀올 때. 앱 전환 화면(inactive)에서는 로고로 덮기만 하고 바로 돌아오면 인증 없이 풀립니다. 시스템 인증 창이 떠 있는 동안(iOS는 이때 inactive가 됨)은 생명주기를 무시합니다.
- 인증 실패·취소·생체 인증 잠김이면 "인증에 실패하거나 비밀번호를 잊으셨나요?" 버튼이 나오고, 누르면 기기 암호(PIN)도 허용하는 시스템 인증 창을 다시 띄웁니다. 자동으로 반복해서 띄우지는 않습니다.
- 기기 화면 잠금이 없어져 인증 자체가 불가능하면(`noCredentialsSet`) 잠금을 끄고 들여보냅니다(영영 못 들어가는 일 방지).
- **앱이 일부러 다른 화면을 띄울 때**(사진·카메라, OS 권한 창)는 `ref.read(appLockControllerProvider.notifier).suspendWhile(() => ...)`로 감쌉니다. 안 감싸면 돌아올 때 잠금이 걸리거나 권한 창 뒤가 로고로 가려집니다.
- 인증 수단 호출은 `DeviceAuthService`(`lib/core/platform/device_auth_service.dart`) 한 곳에서만 하고, 테스트는 `deviceAuthServiceProvider`·`appLockStoreProvider`를 가짜로 바꿉니다(`test/features/security/app_lock_test.dart`).
- **TODO (Supabase 로그인이 연결되면):** 실패 버튼에 "계정으로 잠금 풀기"(재로그인)를 추가하고, 로그아웃·계정 삭제 시 잠금 설정을 지웁니다.

## 5. 화면 공통 규칙

- 글자 크기 배율 1.0 고정, 세로 방향만. 라이트/다크는 설정의 "화면 모드"로 고릅니다(`themeModeProvider`, 저장은 `ThemeModeStore`의 `theme_mode`). 기본값은 기기 설정 따르기(`ThemeMode.system`)라 기기에서 라이트·다크를 바꾸면 앱도 바로 바뀝니다. 예전 `dark_mode`(bool)가 켬이면 다크로 이어받고, 끔(예전 기본값)이면 기기 설정을 따릅니다. 색은 `context.colors`로만 읽습니다.
- **쌓이는 화면 등록:** 탭 위로 쌓이는 새 화면은 `lib/app/router.dart`에서 `pageBuilder: (context, state) => _swipe(state, 화면)`으로 등록합니다(`SwipeBackPage`). 그래야 iOS·Android 모두 화면 어디서나 오른쪽으로 밀어 뒤로 갈 수 있습니다. 밀어서 나가면 안 되는 화면(저장 중 등)은 `PopScope(canPop: false)`로 막습니다.
- **로딩 상태:** 데이터를 불러오는 동안 빈 화면을 두지 않고 스켈레톤(`lib/shared/widgets/skeleton.dart`)으로 내용 자리를 보여 줍니다. 홈은 Figma 홈 스켈레톤(`834:2351`)을 그대로 옮긴 `HomeSkeleton`, 목록은 `SkeletonList`(아이콘형·아바타형 카드)를 씁니다. 한 화면에 `SkeletonPulse`는 하나만 둡니다.
- **토스트:** 저장·완료 같은 성공 알림은 `showAppToast(context, 문구, success: true)`(체크 표시), 오류·권한·안내 문구는 `success` 없이 씁니다.
- 디자인(Figma)이 없는 화면은 `docs/design/references/INDEX.md`의 레퍼런스를 해석해 `docs/DESIGN_SYSTEM.md`의 컴포넌트로 만들고, Figma가 나오면 Figma 기준으로 고칩니다.
- **햅틱 피드백:** `lib/core/utils/app_haptics.dart`만 씁니다(`HapticFeedback`을 화면에서 직접 부르지 않음). 탭이 다른 탭으로 바뀔 때 `selection()`, 버튼·링크를 누를 때 `tap()`(가벼운 톡). 같은 탭 다시 누르기, 동작 없는 요소(알림, 카드 등)에는 울리지 않습니다.
- iOS와 Android 둘 다 잘 동작해야 합니다. 플랫폼 전용 설정은 항상 양쪽을 같이 처리합니다.
- 상태 관리·라우팅 라이브러리는 앱 뼈대 작업에서 확정하고 [TECH_STACK.md](./TECH_STACK.md)에 기록합니다(추천: `flutter_riverpod`, `go_router`).
