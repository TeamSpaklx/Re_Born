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
- `GET /api/diaries?from=2026-10-01T00:00:00Z&to=2026-11-01T00:00:00Z`

## 다음 작업

1. Supabase JWT를 검증해 `auth.uid()`가 실제 사용자와 연결되도록 구성
2. 일기 분석 provider 구현 및 분석 결과 저장
3. Flutter Repository를 HTTP API 구현으로 교체

DB 비밀번호와 AI API 키는 소스 코드나 커밋에 넣지 않습니다.
