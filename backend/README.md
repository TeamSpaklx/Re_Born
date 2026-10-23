# Re:Born Spring Boot Backend

현재는 일기 CRUD와 날짜 범위 조회의 기본 API 골격입니다.

## 실행 전 환경변수

```sh
export SUPABASE_DB_URL='jdbc:postgresql://<host>:5432/postgres?sslmode=require'
export SUPABASE_DB_USERNAME='postgres'
export SUPABASE_DB_PASSWORD='<database-password>'
```

실행:

```sh
mvn spring-boot:run
```

API:

- `GET /health`
- `POST /api/diaries`
- `POST /api/diaries/analyze` (본문을 OpenAI로 보내 분석하고 감정·점수를 DB에 저장)
- `GET /api/diaries?from=2026-10-01T00:00:00Z&to=2026-11-01T00:00:00Z`

OpenAI 분석을 사용하려면 서버 실행 전에 API 키를 설정합니다.

```sh
export OPENAI_API_KEY='your-openai-api-key'
mvn spring-boot:run
```

분석 API 요청 예시:

```json
{
  "person_id": null,
  "body": "오늘 친구와 만나서 즐거웠고 고마운 마음이 들었다.",
  "consentToExternalAnalysis": true
}
```

이 요청은 일기 본문을 OpenAI로 전송합니다. 앱에서는 전송 전에 사용자의 동의를 받아야 합니다.

## 다음 작업

1. Supabase JWT를 검증해 `auth.uid()`가 실제 사용자와 연결되도록 구성
2. 일기 분석 provider 구현 및 분석 결과 저장
3. Flutter Repository를 HTTP API 구현으로 교체

DB 비밀번호와 AI API 키는 소스 코드나 커밋에 넣지 않습니다.
