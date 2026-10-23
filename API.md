# Re:Born API 명세

> 프론트엔드 Repository 계약(`docs/FRONTEND.md`), 기능 명세(`docs/SPEC.md`), 백엔드 작업 문서(`docs/BACKEND_TASKS.md`)를 기준으로 작성한 MVP API 계약입니다.
>
> 분석·관계 지수·인사이트 판정은 MVP에서 앱 내부의 순수 Dart 로직이 담당합니다. 서버는 인증, 본인 데이터의 저장·조회·수정·삭제를 담당합니다.

## 1. 기본 규칙

- Base URL: `https://<backend-host>`
- Content-Type: `application/json`
- 시간: ISO 8601 문자열, UTC 권장. 예: `2026-10-24T09:30:00Z`
- 날짜: `YYYY-MM-DD`
- 인증: `Authorization: Bearer <Supabase access token>`
- 모든 리소스는 토큰의 사용자(`auth.uid()`) 소유 데이터만 반환·변경합니다.
- 클라이언트가 `userId`를 path나 body로 전달하지 않습니다. 서버가 토큰에서 결정합니다.
- 성공 응답은 리소스 또는 배열을 반환하고, 삭제·읽음 처리 등은 `204 No Content`를 사용합니다.

공통 오류 형식:

```json
{
  "timestamp": "2026-10-24T09:30:00Z",
  "status": 400,
  "code": "VALIDATION_ERROR",
  "message": "요청 값을 확인해 주세요.",
  "details": { "body": "내용을 입력해 주세요." }
}
```

| 상태 | 의미 |
|---|---|
| 400 | JSON 또는 입력값 오류 |
| 401 | access token 누락·만료·유효하지 않음 |
| 403 | 다른 사용자의 리소스 접근 시도 |
| 404 | 리소스 없음 |
| 409 | 중복 이름 등 상태 충돌 |
| 422 | 형식은 맞지만 업무 규칙 위반 |
| 500 | 서버 오류 |

## 2. 인증 및 계정

회원가입·로그인은 Supabase Auth SDK/OAuth를 사용합니다. Spring API가 비밀번호를 받거나 저장하지 않습니다.

| 기능 | 방식 | 설명 |
|---|---|---|
| 이메일 회원가입 | Supabase Auth `signUp` | 가입 후 `profiles`를 생성하거나 최초 프로필 저장 시 생성 |
| 이메일 로그인 | Supabase Auth `signInWithPassword` | access token 발급 |
| Google/Kakao 로그인 | Supabase OAuth | 확장 기능. 현재 문서의 MVP 필수 범위는 이메일 인증 |
| 로그아웃 | Supabase Auth `signOut` | 클라이언트 세션 종료 |
| 계정 삭제 | `DELETE /api/account` | 재인증 완료 후 데이터 삭제와 Auth 계정 삭제를 안전한 서버/Edge Function에서 수행 |

## 3. 프로필·설정 API

### `GET /api/profile`

현재 사용자의 프로필과 동의·알림 설정을 조회합니다.

응답 `200`:

```json
{
  "userId": "uuid",
  "nickname": "희경",
  "consentPrivacy": true,
  "consentAiAnalysis": true,
  "consentAnalytics": false,
  "createdAt": "2026-10-24T09:30:00Z"
}
```

### `PUT /api/profile`

보낼 필드만 갱신할 수 있습니다. `nickname`은 앱 정책에 맞게 길이 제한을 둡니다. 알림 설정은 현재 로컬 알림 설정 범위이므로 이 API의 저장 대상이 아닙니다.

```json
{"nickname":"희경","consentPrivacy":true,"consentAiAnalysis":false,"consentAnalytics":false}
```

응답 `200`: `GET /api/profile`과 같은 객체.

### `DELETE /api/account`

재인증된 세션에서만 호출해야 합니다. 현재 Spring API는 `profiles`, `people`, `entries`, `index_history`, `insights`, `todos`의 사용자 데이터를 삭제하고 `204`를 반환합니다. Supabase Auth 계정 삭제는 service-role 키를 백엔드에 넣지 않기 위해 별도 Edge Function 연동이 필요합니다.

### `POST /api/account/reauthenticate`

Supabase 클라이언트에서 비밀번호 재인증을 완료한 뒤 새 access token을 전달합니다. 서버는 JWT의 `auth_time`이 최근 5분 이내인지 확인하고 성공 시 `200`을 반환합니다. 서버는 비밀번호를 저장하거나 직접 처리하지 않습니다.

```json
{"reauthenticated":true,"expiresInSeconds":300}
```

## 4. 인물 API (F-02)

### `GET /api/people`

응답 `200`:

```json
[{"id":"uuid","name":"하은","relationType":"friend","memo":null,"createdAt":"2026-10-24T09:30:00Z"}]
```

### `POST /api/people`

요청: `name` 1~20자, `relationType`은 `friend | family | teacher | coworker | other`, `memo` 선택.

```json
{"name":"하은","relationType":"friend","memo":"학교 친구"}
```

응답 `201`: 생성된 인물. 같은 사용자 안에서 이름이 중복되면 `409 DUPLICATE_PERSON_NAME`.

### `PATCH /api/people/{personId}`

요청 예: `{"name":"하은","relationType":"friend","memo":"친한 친구"}`  
응답 `200`: 갱신된 인물.

### `DELETE /api/people/{personId}`

인물은 삭제하되 관련 기록은 기본적으로 보존하고 `entries.personId`를 `null`로 설정합니다. 관련 `index_history`와 인사이트는 삭제합니다. 응답 `204`.

## 5. 기록 API (F-03, F-05, F-13)

### `GET /api/entries`

쿼리:

| 파라미터 | 필수 | 설명 |
|---|---:|---|
| `personId` | 아니오 | 특정 인물 기록만 조회 |
| `from` | 아니오 | 포함 시작 시각 |
| `to` | 아니오 | 미포함 종료 시각 |

최근 작성순으로 반환합니다. 응답 `200`:

```json
[{"id":"uuid","body":"오늘 고맙다는 말을 들었다","personId":"uuid","emotion":"joy","intensity":2,"score":2,"createdAt":"2026-10-24T09:30:00Z","analysisStatus":"done","analysis":{"keywords":["고마움"],"analyzedAt":"2026-10-24T09:30:01Z"}}]
```

### `GET /api/entries/{entryId}`

응답 `200`: 기록 1건. 타 사용자 기록은 `404` 또는 `403`으로 차단합니다(구현에서 한 가지로 통일).

### `POST /api/entries`

본문 1~2000자, `emotion` 7종(`joy`, `sadness`, `neutral`, `anger`, `anxiety`, `love`, `excited`), `intensity` 1~3, `createdAt`은 미래 불가, `personId`는 선택입니다. `score = emotion 극성 × intensity`를 서버에서도 검증합니다.

```json
{"body":"오늘 고맙다는 말을 들었다","personId":"uuid","emotion":"joy","intensity":2,"createdAt":"2026-10-24T09:30:00Z"}
```

응답 `201`: `analysisStatus: "pending"`인 생성 결과. 위기 표현이 감지되어도 기록 저장은 진행하고, 안내 여부는 앱이 판단합니다.

### `PATCH /api/entries/{entryId}`

본문·인물·감정·강도·작성 시각을 갱신합니다. 감정 또는 본문이 바뀌면 `score`를 재검증하고 분석 결과를 비우며 `analysisStatus`를 `pending`으로 되돌립니다. 응답 `200`.

### `DELETE /api/entries/{entryId}`

기록과 연결된 분석 결과를 삭제합니다. 이후 앱이 해당 인물의 지수·인사이트를 재계산합니다. 응답 `204`.

### `POST /api/entries/{entryId}/analysis/retry`

실패한 분석의 재시도용 선택 API입니다. MVP 규칙 기반 분석을 앱에서 수행하는 경우 필수 API가 아니며, 서버가 분석을 맡는 경우에만 사용합니다. 응답 `200`: 갱신된 기록.

## 6. 체크리스트 API (F-04)

### `GET /api/todos`

최근 생성순으로 반환합니다.

### `POST /api/todos`

제목 1~100자, `source`는 `manual | suggestion`, `personId`·`insightId` 선택.

```json
{"title":"내일 가볍게 말을 걸기","personId":"uuid","source":"suggestion","insightId":"uuid","createdAt":"2026-10-24T09:30:00Z"}
```

응답 `201`: 생성된 체크리스트 항목.

### `PATCH /api/todos/{todoId}`

```json
{"title":"내일 가볍게 말을 걸기","done":true}
```

`done=true`이면 서버가 `doneAt`을 기록하고, `false`이면 `doneAt=null`로 설정합니다. 응답 `200`.

### `DELETE /api/todos/{todoId}`

응답 `204`.

## 7. 관계 지수·인사이트 저장 API

계산은 앱이 수행하지만, 계산 결과를 재실행 후에도 표시할 수 있도록 저장합니다.

### `GET /api/people/{personId}/index-history?from=YYYY-MM-DD`

날짜 오름차순으로 반환합니다.

```json
[{"personId":"uuid","date":"2026-10-24","index":67,"entryCount":4}]
```

### `PUT /api/people/{personId}/index-history/{date}`

```json
{"index":67,"entryCount":4}
```

`index`는 0~100, `entryCount`는 0 이상입니다. 같은 인물·날짜는 덮어씁니다. 응답 `200`.

### `DELETE /api/people/{personId}/index-history/{date}`

데이터 부족 상태가 되면 해당 날짜를 삭제합니다. 응답 `204`.

### `GET /api/insights?personId={personId}`

최근 생성순으로 반환합니다.

```json
[{"id":"uuid","type":"negative_trend","personId":"uuid","message":"최근 10일 동안 부정적인 기록이 3건 있어요.","evidence":{"indexFrom":72,"indexTo":60,"negCount":3},"createdAt":"2026-10-24T09:30:00Z","read":false}]
```

`type`은 `negative_trend | recovery`입니다. `evidence`에는 계산 가능한 수치만 포함합니다.

### `GET /api/insights/{insightId}`

인사이트 상세를 반환합니다.

### `PATCH /api/insights/{insightId}/read`

읽음 처리 후 `204`.

### `POST /api/entries/{entryId}/analysis/retry`

기록 소유권을 확인한 뒤 규칙 기반 분석을 다시 실행하고 `analysisStatus`를 `done`으로 갱신합니다. 외부 AI API에는 본문을 전송하지 않습니다.

### 알림 설정

`GET /api/profile`, `PUT /api/profile`의 다음 필드로 저장합니다.

```json
{"notificationInsight":true,"notificationReminder":false,"reminderTime":"21:00"}
```

### `POST /api/insights`

앱에서 판정한 인사이트를 저장합니다. 중복 방지는 앱 규칙(같은 인물·유형 최근 7일)을 따릅니다. 응답 `201`.

## 8. 현재 Spring 백엔드 구현 상태

현재 구현된 엔드포인트는 다음 두 개입니다.

| 엔드포인트 | 현재 상태 | 보완 필요 |
|---|---|---|
| `GET /health` | 구현됨 | 운영 상태 확인용 |
| `POST /api/entries` | 구현됨 | JWT 인증, 소유 인물 확인, score 검증 |
| `GET /api/entries` | 구현됨 | JWT 인증, `user_id` 조건, personId 필터 |
| `GET/PUT /api/profile` | 구현됨 | 프로필·동의 상태 저장 |
| `DELETE /api/account` | 부분 구현 | 사용자 데이터 삭제 완료, Auth 계정 삭제는 Edge Function 필요 |

기존 `/api/diaries`와 `DiaryService`는 제거했고 `/api/entries`로 통일했습니다. Spring JDBC는 DB 세션의 `auth.uid()`에 의존하지 않고, 검증된 JWT의 `sub`를 모든 SQL의 `user_id` 조건으로 사용합니다.

우선 구현 순서:

1. Supabase access token 검증과 사용자 컨텍스트 연결
2. `entries` API를 `/api/entries` 계약으로 확장
3. `people` API와 외래키/RLS 적용
4. todos, index-history, insights, profile API 추가
5. 타 계정 접근(`T-05`, `T-35`)과 입력·재시도 테스트 작성

## 9. 기능·테스트 연결

| API 영역 | 기능 ID | 주요 테스트 ID |
|---|---|---|
| 인증·프로필·계정 삭제 | F-01, F-11 | T-01~T-05, T-30~T-31 |
| 인물 | F-02 | T-06~T-09 |
| 기록 | F-03, F-13 | T-10~T-14, T-33~T-34 |
| 분석 상태 | F-05 | T-18~T-21 |
| 체크리스트 | F-04 | T-15~T-17 |
| 지수·인사이트 | F-06~F-09 | T-22~T-28 |
| 알림 | F-10 | T-29 |

