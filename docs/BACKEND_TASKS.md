# 백엔드 할 일 (김규리, 고희경)

프론트가 MVP 화면과 앱 안의 분석 로직까지 만들어 두었습니다. 지금 앱은 **메모리 저장소 + 샘플 데이터**로 돌아가고,
백엔드 두 분이 할 일은 **그 저장소를 Supabase(PostgreSQL)로 바꾸는 것**입니다. 화면과 분석 코드는 건드리지 않습니다.

- 기능 명세: [SPEC.md](./SPEC.md) · 데이터 계약: [FRONTEND.md](./FRONTEND.md) 4-1장 · 기술: [TECH_STACK.md](./TECH_STACK.md)
- 규칙: `main`에 직접 push하지 않고 브랜치 → PR ([AGENTS.md](../AGENTS.md)). 커밋 메시지는 `feat:`/`fix:` 등 + 한국어. 비밀 키는 커밋하지 않습니다(앱에는 publishable key만).
- 지원 OS: Android + iOS. Windows 기기는 Android만, Mac 기기는 둘 다 확인합니다(SPEC 11장 3번).

## 0. 시작 전에 알아둘 것

1. **분석·지수·인사이트 계산은 앱이 합니다.** 서버 함수나 트리거로 만들지 않습니다(SPEC 6.4). 백엔드는 저장·조회·권한만 맡습니다.
2. 로그인 화면은 아직 없습니다(디자인 대기). 그래서 **개발 중에는 임시 인증**이 필요합니다. 아래 "임시 인증" 참고.
3. 코드 어디를 바꾸나: 저장소 구현 파일을 새로 만들고 `lib/app/data_providers.dart`의 provider 한 줄씩만 바꿉니다.
4. 새 패키지가 필요하면 PR에서 이유를 적고 `docs/TECH_STACK.md`도 고칩니다.

## 1. 고희경 — 데이터베이스·인증·보안 (먼저 시작)

### 1-1. Supabase 프로젝트
- 무료 플랜 프로젝트 2개 제한으로 기존 프로젝트가 멈춘 적이 있습니다. 새로 만들거나 복구한 뒤 `lib/core/config/supabase_config.dart`의 URL·publishable key를 갱신합니다(PR).

### 1-2. 테이블 만들기 (`supabase/migrations/`에 SQL 마이그레이션 파일로, 대시보드에서만 바꾸지 않기)
모든 테이블에 `user_id uuid not null references auth.users on delete cascade default auth.uid()`를 두고 **RLS를 켭니다**(RLS 없는 테이블 금지, AGENTS.md).

| 테이블 | 컬럼 (앱 모델 ↔ 컬럼) | 비고 |
|---|---|---|
| `profiles` | `user_id`(PK), `nickname text`, `consent_privacy bool`, `consent_ai_analysis bool`, `consent_analytics bool`, `created_at` | 앱 `AppSettings`·`Consents` |
| `people` | `id`(uuid PK), `user_id`, `name text`(1~20자), `relation_type text` (`friend`/`family`/`teacher`/`coworker`/`other`), `memo text null`, `created_at` | 같은 사용자 안에서 `name` 중복 불가(unique `user_id, name`) |
| `entries` | `id`, `user_id`, `body text`(1~2000자), `person_id uuid null → people`, `emotion text`, `intensity smallint`(1~3), `score smallint`(−3~3), `created_at`, `analysis_status text`(`pending`/`done`/`failed`), `analysis_keywords text[]`, `analyzed_at timestamptz null` | `emotion` 값은 아래 감정 7종 영문 키 |
| `index_history` | `person_id → people`, `date date`, `user_id`, `index smallint`(0~100), `entry_count int`, PK(`person_id, date`) | **앱이 쓰는 값**(SPEC 6.2는 "서버"라고 되어 있으나 앱 계산으로 정리됨) |
| `insights` | `id`, `user_id`, `type text`(`negative_trend`/`recovery`), `person_id`, `message text`, `evidence_index_from smallint`, `evidence_index_to smallint`, `evidence_neg_count int null`, `created_at`, `read bool` | 앱이 계산해서 저장 |
| `todos` | `id`, `user_id`, `title text`(1~100자), `person_id null`, `done bool`, `done_at null`, `source text`(`manual`/`suggestion`), `insight_id uuid null`, `created_at` | |

- **감정 키(앱 `Emotion` enum 이름, 2026-10-24 캐릭터 시안에 맞춰 7종으로 변경):** `joy`(기쁨, +1), `sadness`(슬픔, −1), `neutral`(무표정, 0), `anger`(화남, −1), `anxiety`(불안함, −1), `love`(사랑, +1), `excited`(신남, +1). 예전 키 `gratitude`·`excitement`·`calm`·`hurt`는 없어졌습니다(CHECK 제약이 있다면 새 키로). 이 7종과 극성은 **제안값**이라 팀 확정 시 같이 바꿉니다.
- 인물을 지울 때 그 인물의 기록을 어떻게 할지는 아직 미정(SPEC 11장 8번). 앱은 `entries.person_id`를 null로 두는 쪽(기록 유지)을 기본으로 합니다 → 외래키는 `on delete set null` 제안.

### 1-3. RLS 정책 (테이블마다)
- `select / insert / update / delete` 모두 `using (user_id = auth.uid())`, `insert`는 `with check (user_id = auth.uid())`.
- 확인(필수): **T-05**(계정 A의 데이터가 B에게 안 보임), **T-35**(타인 uid 경로 읽기·쓰기 시도 거부).
- 인사이트·지수 이력은 앱이 쓰므로 일반 사용자 권한으로 쓰기를 허용합니다(서버 전용 쓰기 아님). 대신 본인 행만.

### 1-4. 인증
- 이메일 + 비밀번호(Supabase Auth). 가입·로그인 화면은 디자인 후 프론트가 만듭니다.
- **임시 인증(개발용):** 로그인 화면이 나오기 전까지 앱이 시작할 때 `signInAnonymously()` 또는 고정 테스트 계정으로 로그인하게 하는 코드를 `lib/main.dart`(또는 별도 `lib/core/auth/`)에 추가하는 작은 PR을 먼저 만들어 주세요. 이 방식으로 RLS를 확인할 수 있습니다. 나중에 로그인 화면으로 교체합니다.
- 계정 삭제(F-11): 재인증 → 사용자 데이터 삭제 → Auth 계정 삭제. Auth 계정 삭제는 클라이언트 키로 안 되므로 **Edge Function 등 안전한 방법**이 필요합니다(secret key를 앱에 넣지 않음). 방식을 정해 알려 주세요.

## 2. 김규리 — 저장소 구현과 분석 규칙 검토

### 2-1. 저장소 구현 (고희경이 테이블을 만든 뒤)
아래 인터페이스를 구현한 `Supabase…Repository` 클래스를 각 기능 폴더의 `data/`에 만들고(`supabase_flutter`의 `Supabase.instance.client` 사용), `lib/app/data_providers.dart`의 provider에서 교체합니다. 메서드 설명은 인터페이스 파일의 주석을 따릅니다.

| 인터페이스 | 파일 | 만들 클래스 |
|---|---|---|
| `PeopleRepository` | `lib/features/people/data/people_repository.dart` | `SupabasePeopleRepository` |
| `EntriesRepository` | `lib/features/entries/data/entries_repository.dart` | `SupabaseEntriesRepository` |
| `TodosRepository` | `lib/features/todos/data/todos_repository.dart` | `SupabaseTodosRepository` |
| `InsightsRepository`, `IndexHistoryRepository` | `lib/features/insights/data/insights_repository.dart` | `SupabaseInsightsRepository`, `SupabaseIndexHistoryRepository` |
| `SettingsRepository` | `lib/features/settings/data/settings_repository.dart` | `SupabaseSettingsRepository` |

- 메모리 구현(`in_memory_*.dart`)을 참고하세요. 목록 정렬(기록·인사이트·체크리스트는 최근순, 지수 이력은 날짜 오름차순)과 `deleteAll`·`deleteForPerson`의 동작이 같아야 합니다.
- 실패하면 예외를 그대로 던지세요. 앱이 안내와 재시도를 처리합니다(`AnalysisService`는 분석 중 예외를 `failed`로 표시).
- 테스트: 인터페이스 단위로 메모리 구현과 같은 동작인지 확인하는 테스트를 `test/features/<기능>/data/`에 추가해 주세요.
- 한 번에 다 하기 어려우면 **기록(`entries`)과 인물(`people`) → 체크리스트 → 인사이트·지수 → 설정** 순서로 PR을 나눠도 됩니다. 중간에도 앱은 나머지를 메모리로 계속 씁니다.

### 2-2. 분석 규칙 검토·조정 (선택, 구현은 끝나 있음)
앱 안의 규칙은 **제안값**입니다. 값과 문구를 확정하거나 고쳐 주세요(수정은 PR, 테스트도 같이).
- `lib/features/analysis/relation_index.dart`: 최근 7일 가중치 2 · 이전 7일 1, 14일 안 3건 미만이면 "데이터 부족", `index = round((평균+3)/6×100)`
- `lib/features/analysis/insight_detector.dart`: 부정 추세(최근 10일 점수 ≤ −1이 3건 이상 + 지수 10점 하락), 회복 추세(14일 전보다 10점 상승), 7일 중복 방지
- `lib/features/analysis/emotion_analyzer.dart`: 키워드 목록, `suggestion_pool.dart`: 제안 문구, `crisis_checker.dart`: 위기 표현 키워드(**연락처·목록은 출시 전 공식 기관 안내로 확인**)
- 시나리오 데이터 3종으로 임계값을 한 번 조정하고 확정하는 일은 SPEC 8장 7번의 결정 사항입니다.

## 3. 두 사람이 함께 정할 것
1. 인물 삭제 시 그 인물의 기록은 지울지 남길지(SPEC 11장 8번). 앱 기본은 "남기고 인물 없음으로".
2. 감정 점수 범위: 앱은 **−3~+3**(극성 × 강도)로 통일했습니다. SPEC F-03의 −1~+1과 불일치(SPEC "변환 중 발견한 불일치" 4번) → 확정 후 SPEC을 PR로 고쳐 주세요.
3. 오프라인 저장(T-13): 필요한지, 하면 어떻게 할지.
4. 계정 삭제 방식(Edge Function 등).

## 4. 완료 기준
- [ ] 테이블 6개 + RLS, 마이그레이션 파일이 `supabase/migrations/`에 있다
- [ ] T-05(타 계정 데이터 안 보임), T-35(타인 경로 접근 거부) 통과
- [ ] 저장소 6개가 Supabase로 동작하고 앱을 다시 켜도 데이터가 남는다(T-10, T-15)
- [ ] 임시 인증이 있어 로그인 화면 없이도 위 확인이 가능하다
- [ ] `flutter analyze`, `flutter test` 통과, 비밀 키 커밋 없음

## 5. 막히면
프론트(이윤재)에게 PR 링크와 함께 알려 주세요. 화면·분석 코드와 저장소 계약(FRONTEND.md 4-1장)이 맞지 않으면 계약을 먼저 맞춥니다.
