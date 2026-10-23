# 프론트엔드 구조와 백엔드 계약

프론트(Flutter 앱)가 어떤 모양으로 코드를 짜는지, 그리고 **백엔드·분석 담당(김규리, 고희경)이 프론트와 맞춰야 하는 데이터 모양**을 정리한 문서입니다.
화면 디자인 값은 [DESIGN_SYSTEM.md](./DESIGN_SYSTEM.md), 사용하는 기술은 [TECH_STACK.md](./TECH_STACK.md), 기능 정의는 [SPEC.md](./SPEC.md)를 봅니다.

## 1. 폴더 규칙

```
lib/features/<기능>/
  models/         데이터 모양 (순수 Dart, Flutter·Supabase를 모름)
  data/           Repository 인터페이스 + Fake 구현 + Supabase 구현
  presentation/   화면, 상태(provider), 이 기능 전용 위젯
test/features/<기능>/   lib과 같은 구조
```

- 화면은 **Repository 인터페이스만** 봅니다. Supabase를 직접 부르지 않습니다.
- 프론트는 먼저 메모리 가짜 구현(`FakeXxxRepository`)으로 화면을 완성합니다.
- 백엔드는 같은 인터페이스를 구현한 `SupabaseXxxRepository`를 만들고, provider 한 줄만 바꿔 교체합니다. 그래서 **프론트와 백엔드는 서로 다른 파일을 건드립니다.**
- 감정 분석·관계 지수·패턴 감지·연속 기록 계산은 UI·DB를 모르는 **순수 Dart 함수**로 만들고 단위 테스트를 붙입니다 (`lib/features/<기능>/models/` 또는 `domain/`).

## 2. 화면 구성

| 탭 | 내용 | 디자인 | 지금 상태 |
|---|---|---|---|
| 투데이 (홈) | 오늘 기록, 관계 신호, 주간 감정 그래프, 행동 제안 | Figma 있음 | Before(기록 전) 구현됨, After(기록 완료·출석 체크)는 구현 예정 |
| 관계 | 인물 목록, 인물별 지수 히스토리 (F-02, F-09) | 없음 | 흰 빈 화면 |
| 기록 | 기록 작성·목록 (F-03) | 없음 | 흰 빈 화면 |
| 전체 | 체크리스트, 설정, 계정 (F-04, F-11) | 없음 | 흰 빈 화면 |

로그인·회원가입(F-01)은 디자인이 나올 때까지 제외합니다. 앱은 스플래시 화면(`/splash`)에서 시작해 홈 데이터가 준비되면(최소 0.8초, 최대 3초) 홈으로 서서히 넘어가고, 로그인이 들어오면 스플래시가 로그인 여부로 로그인/홈 중 한 곳으로 보냅니다.

## 3. 홈 화면 데이터 모양

홈 화면 하나가 `HomeSummary`를 받아 그립니다. 필드 이름과 의미를 백엔드와 맞춥니다.

```dart
class HomeSummary {
  String nickname;              // "규리" → 인사말 "규리님, 오늘도 즐거운 하루 보내세요!"
  DateTime today;               // 날짜 표시 "9월 13일 목요일"
  bool todayRecorded;           // true면 After(기록 완료 카드), false면 Before(기록 유도 카드)
  RecordStreak streak;          // After의 출석 체크
  List<RelationSignal> relationSignals;  // "최근 관계 신호" 카드들
  WeeklyEmotionFlow weeklyEmotion;       // "이번 주 감정 흐름" 그래프
  List<ActionSuggestion> suggestions;    // "오늘 해볼까요?" 카드들
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

### RelationSignal — 최근 관계 신호

```dart
class RelationSignal {
  String personId;
  String personName;          // "지민"
  RelationType relationType;  // friend / family / teacher / coworker / other → 칩 글자 "친구"
  String message;             // "최근 대화가 조금 줄었어요"
  int daysSinceLastRecord;    // "마지막 기록 5일 전"
}
```

- SPEC F-07(부정 패턴 감지·인사이트)의 결과에서 만듭니다. `message`는 SPEC 문구 원칙대로 **계산 가능한 사실만** 씁니다(정의 없는 "피로도 40%" 같은 수치 금지).
- 홈에는 신호가 몇 개 나오는지 Figma에 1개만 있습니다(→ 여러 개일 때 세로로 쌓고, "전체 보기"에서 전체 목록, 확인 필요).

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
- ⚠️ **확인 필요: `value`가 무엇의 수치인지 SPEC에 없습니다.** 후보: (a) 그날 기록 감정 점수의 평균을 0~1로 환산, (b) 그날 기록 수. 감정 점수 범위(−1~+1 vs −3~+3, SPEC 불일치 #4)와 함께 정해야 합니다. 정해지기 전에는 프론트가 가짜 값으로 그립니다.
- `summary` 문장도 어떤 규칙으로 만들지(증가/감소/유지) 정해야 합니다.

### ActionSuggestion — 오늘 해볼까요?

```dart
class ActionSuggestion {
  String id;
  String personId;
  String title;     // "지민님에게 가볍게 안부 묻기"
  String reason;    // "최근 대화가 조금 줄었어요"
  bool done;        // 오른쪽 원 체크 여부 (F-04 체크리스트와 연결)
}
```

- SPEC F-08(행동·대화 시점 제안)의 고정 문구 풀에서 고릅니다(문구 풀은 앱 안 파일, SPEC 11장 9번 제안).
- 체크하면 F-04 체크리스트 항목이 `source = suggestion`으로 생깁니다.

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

MVP 데이터 처리는 SPEC 6.4대로 **분석·지수·인사이트 계산은 앱(순수 Dart)** 이 하고, 백엔드는 **저장소(읽기·쓰기 + RLS)** 만 구현합니다.
위 4장의 `HomeRepository`는 홈 화면 연결 작업에서 없어지고, 홈 요약은 아래 저장소들에서 앱이 조립합니다.

| 인터페이스 (파일) | 테이블 | 하는 일 |
|---|---|---|
| `PeopleRepository` (`lib/features/people/data/people_repository.dart`) | `people` | 인물 목록·추가·수정·삭제·전체 삭제 |
| `EntriesRepository` (`lib/features/entries/data/entries_repository.dart`) | `entries` | 기록 목록(인물별)·조회·추가(pending)·수정·삭제 |
| `TodosRepository` (`lib/features/todos/data/todos_repository.dart`) | `todos` | 체크리스트 목록·추가·수정(완료)·삭제 |
| `InsightsRepository` (`lib/features/insights/data/insights_repository.dart`) | `insights` | 인사이트 목록·조회·저장·읽음 처리 |
| `IndexHistoryRepository` (같은 파일) | `index_history` | 인물·날짜별 지수 목록·덮어쓰기·삭제 |
| `SettingsRepository` (`lib/features/settings/data/settings_repository.dart`) | `profiles` | 닉네임·동의 |

- **교체 지점은 한 곳:** `lib/app/data_providers.dart`의 provider 한 줄씩(`InMemory…` → `Supabase…`). 화면과 분석 코드는 건드리지 않습니다.
- 메모리 구현과 샘플 데이터(`lib/features/analysis/data/sample_data.dart`)는 백엔드 연결 전 시연용입니다.
- 기록 저장 → 분석 → 지수 → 인사이트 순서는 `AnalysisService`(`lib/features/analysis/analysis_service.dart`)가 저장소 호출 순서로 처리하므로, 백엔드는 이 로직을 만들지 않아도 됩니다.
- 분석 규칙은 `lib/features/analysis/`의 순수 함수(`emotion_analyzer`, `relation_index`, `insight_detector`, `suggestion_pool`, `crisis_checker`, `record_streak_calculator`)이고 임계값은 **제안값**입니다(팀 테스트로 조정).

## 4-2. 앱 내부 오류 처리 (F-12, P-11)

- `main.dart`가 `installErrorHandlers`로 처리되지 않은 오류를 `AppErrorLog`(최근 50건, 메모리)에 남깁니다. 배포판에서는 위젯 오류가 빨간 화면 대신 안내 문구로 보입니다.
- 기록에는 **오류 종류·위치·호출 스택만** 남고 오류 메시지는 버립니다(메시지에 기록 본문·인물 이름이 섞일 수 있음). 사용자에게 보여 줘도 안전한 문구는 `AppException`으로 던집니다.
- 저장·분석·체크리스트 저장이 실패하면 오류를 기록하고 화면에는 안내와 재시도를 보여 줍니다(`AnalysisService.onError`, 작성 화면, 체크리스트).
- 외부 분석 도구로는 보내지 않습니다(확장 기능). 나중에 보낸다면 이 기록만 보냅니다.

## 5. 화면 공통 규칙

- 글자 크기 배율 1.0 고정, 라이트 모드만, 세로 방향만. 다크 모드는 나중에 추가하므로 색은 `context.colors`로만 읽습니다.
- 디자인이 없는 화면은 흰 배경의 빈 `Scaffold`로 둡니다(제목·문구 없이).
- **햅틱 피드백:** `lib/core/utils/app_haptics.dart`만 씁니다(`HapticFeedback`을 화면에서 직접 부르지 않음). 탭이 다른 탭으로 바뀔 때 `selection()`, 버튼·링크를 누를 때 `tap()`(가벼운 톡). 같은 탭 다시 누르기, 동작 없는 요소(알림, 카드 등)에는 울리지 않습니다.
- iOS와 Android 둘 다 잘 동작해야 합니다. 플랫폼 전용 설정은 항상 양쪽을 같이 처리합니다.
- 상태 관리·라우팅 라이브러리는 앱 뼈대 작업에서 확정하고 [TECH_STACK.md](./TECH_STACK.md)에 기록합니다(추천: `flutter_riverpod`, `go_router`).
