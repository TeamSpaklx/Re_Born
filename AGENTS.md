# AGENTS.md

AI 코딩 도구(Codex, Claude Code 등)가 이 레포에서 작업할 때 따르는 공통 규칙입니다. 사람 팀원도 같은 규칙을 따릅니다.

## 프로젝트

리본(Re:Born): 감정·행동 기록을 인물별로 모아 관계 지수와 인사이트를 보여 주는 Flutter 앱입니다.

- 기능 명세와 파이프라인: [docs/SPEC.md](docs/SPEC.md)
- 실제로 쓰는 기술과 폴더 구조: [docs/TECH_STACK.md](docs/TECH_STACK.md). SPEC과 다르면 TECH_STACK을 따릅니다.

기능을 구현할 때는 SPEC의 기능 ID(F-xx)와 테스트 ID(T-xx)를 확인하고, PR에 해당 ID를 적어 주세요.

## 명령어

```sh
flutter pub get    # 의존성 설치
flutter analyze    # 린트 (CI에서 실행)
flutter test       # 테스트 (CI에서 실행)
```

PR을 올리기 전에 `flutter analyze`와 `flutter test`가 통과해야 합니다. `main`은 CI 통과 없이 머지되지 않습니다.

## 코드 규칙

- 기능 코드는 `lib/features/<기능>/`에, 여러 기능이 같이 쓰는 코드는 `lib/shared/`, 공통 설정은 `lib/core/`에 둡니다.
- 감정 분석·관계 지수·패턴 감지(F-05~F-07)는 UI·DB와 분리된 순수 Dart 함수로 작성하고 단위 테스트를 붙입니다.
- DB 스키마와 RLS 변경은 `supabase/migrations/`에 마이그레이션 파일로 남깁니다. 대시보드에서만 바꾸지 않습니다.

## UI 규칙

- 디자인 기준은 Figma이고, 값은 [docs/DESIGN_SYSTEM.md](docs/DESIGN_SYSTEM.md)에 정리되어 있습니다. 화면을 만들 때 Figma에 접속하지 말고 이 문서와 `docs/design/`의 스크린샷을 기준으로 합니다.
- 색·글자·모서리·간격·에셋 경로는 `lib/app/theme/`의 상수(`context.colors`, `AppTextStyles`, `AppRadii`, `AppSpacing`, `AppAssets`)만 사용합니다. 화면 코드에 `Color(0x...)`, 글자 크기, 경로 문자열을 직접 쓰지 않습니다.
- 글자 크기 배율 1.0·라이트 모드·세로 방향 고정입니다(다크 모드는 나중에 추가 예정이라 색은 반드시 `context.colors`로 읽습니다).
- 하단 탭은 4개(투데이/관계/기록/전체)이고, 디자인이 없는 화면은 흰 배경의 빈 화면으로 둡니다.
- 새 화면의 데이터 모양과 Repository 규칙은 [docs/FRONTEND.md](docs/FRONTEND.md)를 따릅니다.

## 하지 말 것

- **Firebase / Firestore를 쓰지 않습니다.** SPEC의 `users/{uid}/entries/...` 같은 경로는 PostgreSQL 테이블로 읽습니다.
- **외부 AI API를 쓰지 않고**, 기록 본문을 외부로 보내지 않습니다.
- **Supabase `service_role` / secret 키를 코드나 커밋에 넣지 않습니다.** 앱에는 publishable key만 둡니다.
- **RLS 없는 테이블을 만들지 않습니다.** 모든 사용자 데이터 테이블은 본인 `user_id`의 행만 접근하게 합니다.
- **TECH_STACK.md에 없는 패키지를 마음대로 추가하지 않습니다.** 필요하면 PR에서 이유를 적고 TECH_STACK.md도 함께 고칩니다.

## Git 규칙

- `main`에 직접 push하지 않습니다. 최신 `main`에서 브랜치를 따서 PR로 머지합니다.
- 브랜치 이름: `종류/짧은-설명` (예: `feat/login-screen`, `fix/entry-save`, `docs/spec-update`)
- 커밋 메시지: `feat:` / `fix:` / `refactor:` / `chore:` / `docs:` / `test:` 접두사 + 한국어 설명
- PR 본문은 `.github/pull_request_template.md` 형식을 따릅니다.
- 커밋 메시지와 PR 본문에 AI 도구 표기(`Co-Authored-By: Claude ...`, `Generated with ...` 등)를 넣지 않습니다.

## 문서 규칙

- 새로 만드는 문서(.md)는 `docs/`에 둡니다. 예외: `README.md`, `AGENTS.md`, `CLAUDE.md`(루트), `.github/` 안의 템플릿.
- 명세를 바꿀 때는 docx가 아니라 `docs/SPEC.md`를 PR로 수정합니다.
