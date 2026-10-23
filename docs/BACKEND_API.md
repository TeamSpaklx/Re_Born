# 백엔드 API 연동

API는 Supabase access token을 `Authorization: Bearer <token>` 헤더로 받습니다. 각 SQL은 token의 `sub` 사용자 ID로 범위를 제한합니다.

## API 경로

| 저장소 | 경로 | 지원 작업 |
|---|---|---|
| 상태 | `/health` | `GET` |
| 프로필 | `/api/me` | `GET`, `PUT` |
| 인물 | `/api/people` | 목록·생성 `GET`/`POST`, 전체 삭제 `DELETE` |
| 인물 | `/api/people/{id}` | 수정·삭제 `PATCH`/`DELETE` |
| 기록 | `/api/entries` | 목록(선택 `personId` 필터)·생성·전체 삭제 `GET`/`POST`/`DELETE` |
| 기록 | `/api/entries/{id}` | 단건 조회·수정·삭제 `GET`/`PUT`/`DELETE` |
| 체크리스트 | `/api/todos` | 목록·생성·전체 삭제 `GET`/`POST`/`DELETE` |
| 체크리스트 | `/api/todos/{id}` | 수정·삭제 `PUT`/`DELETE` |
| 인사이트 | `/api/insights` | 목록(선택 `personId` 필터)·인물별/전체 삭제 `GET`/`DELETE` |
| 인사이트 | `/api/insights/{id}` | 단건 조회·저장(upsert) `GET`/`PUT` |
| 인사이트 | `/api/insights/{id}/read` | 읽음 처리 `PATCH` |
| 관계 지수 | `/api/index-history?personId={id}&from={date}` | 목록, 날짜 오름차순 `GET` |
| 관계 지수 | `/api/index-history` | 지수 upsert `PUT`, 인물별/전체 삭제 `DELETE` |
| 관계 지수 | `/api/index-history/{personId}/{date}` | 특정 날짜 삭제 `DELETE` |

기록 DTO는 앱 모델과 동일한 `body`, `person_id`, `emotion`, `intensity`, `score`, `created_at`, `analysis_status`, `analysis_keywords`, `analyzed_at` 필드를 씁니다. 인사이트 유형은 `negative_trend`/`recovery`, 체크리스트 출처는 `manual`/`suggestion`입니다.

기존 `/api/diaries` 및 `/api/diaries/analyze`는 호환을 위해 유지합니다. 새 Flutter 기록 Repository는 `/api/entries`를 사용합니다.

OpenAPI 문서는 `/v3/api-docs`, Swagger UI는 `/swagger`에서 볼 수 있습니다.

## Flutter 실행

기본은 기존 메모리 Repository입니다. 실제 API로 연결하려면 `USE_BACKEND_API=true`를 정의해 실행합니다. 로그인 UI가 없는 개발 단계에서는 debug 빌드에서만 테스트 access token 정의를 허용합니다.

Android 에뮬레이터 예시:

```sh
flutter run \
  --dart-define=USE_BACKEND_API=true \
  --dart-define=BACKEND_BASE_URL=http://10.0.2.2:8000 \
  --dart-define=BACKEND_ACCESS_TOKEN=<test-access-token>
```

iOS 시뮬레이터에서는 `BACKEND_BASE_URL=http://127.0.0.1:8000`을 사용합니다. 실제 기기에서는 컴퓨터의 같은 네트워크 주소 또는 HTTPS로 접근 가능한 서버 주소를 지정합니다. `BACKEND_ACCESS_TOKEN`은 debug 전용이며 저장소에 넣거나 배포 빌드에 전달하지 마세요. 앱에 실제 Supabase 로그인이 구현되면 client는 현재 세션 token을 자동으로 사용합니다.

`BackendApiClient`는 응답 오류를 `BackendApiException`으로 전달합니다. Repository는 오류를 삼키지 않으며 기존 화면의 오류/재시도 흐름이 처리합니다.
