# 기술 스택

리본(Re:Born)에서 **실제로 쓰는 기술**을 정리한 문서입니다. [SPEC.md](./SPEC.md)와 다른 내용이 있으면 이 문서를 따릅니다.
새 라이브러리를 추가하거나 바꿀 때는 PR에서 이 문서도 함께 고쳐 주세요.

## 확정

| 영역 | 사용 기술 | 비고 |
|---|---|---|
| 앱 | Flutter (stable 3.47.4), Dart `^3.12.0` | CI와 같은 버전 사용 |
| 대상 OS | Android 우선 | iOS는 MVP 이후 검토 (SPEC 9.1) |
| 인증 | Supabase Auth, 이메일 + 비밀번호 | 구글 로그인은 미정 (SPEC 11장 7번) |
| DB | Supabase PostgreSQL | 사용자별 접근은 RLS로 제한 |
| 클라이언트 SDK | `supabase_flutter` 2.17.2 | 초기화: `lib/main.dart`, 설정: `lib/core/config/supabase_config.dart` |
| 감정 분석·관계 지수 | Flutter 앱 내부 규칙 기반 계산 | 외부 AI·분석 API 없음 |
| DB 스키마 관리 | Supabase CLI 마이그레이션 | `supabase/migrations/` |
| 린트 | `flutter_lints` 6 | `analysis_options.yaml` |
| CI | GitHub Actions | `main` 대상 PR마다 `flutter analyze` + `flutter test` (`.github/workflows/flutter-ci.yml`) |

## 쓰지 않는 것

- **Firebase / Firestore**: SPEC의 `users/{uid}/entries/{entryId}` 같은 경로는 Firestore 시절 표기입니다. PostgreSQL 테이블 + `user_id` 컬럼 + RLS로 읽어 주세요.
- **외부 AI API**: 기록 본문을 외부로 보내지 않습니다 (SPEC 6.7).
- **별도 서버**: 계산은 앱에서, 저장은 Supabase에서 합니다.
- **SwiftUI, WidgetKit, ActivityKit**: SPEC 6장 스택에 적혀 있지만 MVP 범위가 아닙니다.

## 폴더 구조

```
lib/
  main.dart          앱 진입점, Supabase 초기화
  app/               앱 전체 설정 (라우팅, 테마)
  core/              공통 기반 (config, 상수, 유틸)
  features/<기능>/   기능별 화면·로직 (예: auth, people, entries, todos, insights, history)
  shared/            여러 기능이 같이 쓰는 위젯·모델
supabase/
  migrations/        DB 스키마·RLS 마이그레이션
docs/                명세서와 프로젝트 문서
```

## 보안 규칙

- 앱에는 Supabase **publishable key**만 둡니다. `service_role` 키나 비밀 키는 절대 커밋하지 않습니다.
- 모든 사용자 데이터 테이블에 RLS를 켜고, 본인 `user_id`의 행만 읽고 쓰게 합니다.

## 미정 (팀 결정 필요)

정해지면 위 "확정" 표로 옮겨 주세요.

| 항목 | 후보 | 비고 |
|---|---|---|
| 상태 관리 | Riverpod / Provider / Bloc / setState | 화면 개발 전에 결정 |
| 라우팅 | go_router / Navigator 기본 | |
| 그래프 (F-09) | fl_chart 등 | |
| 푸시 알림 (F-10) | FCM / 로컬 알림 / 미도입 | MVP 이후 확장 기능 |
| 오류 수집 (F-12) | 앱 내부 처리만 / 외부 도구 | MVP는 앱 내부 처리만 |
