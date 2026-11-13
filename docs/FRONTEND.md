# 프론트엔드 구조

이 문서는 `frontend-integration`의 현재 Flutter 구현을 설명합니다. 기능 요구사항은 [SPEC.md](./SPEC.md), 디자인 값은 [DESIGN_SYSTEM.md](./DESIGN_SYSTEM.md), 사용 기술은 [TECH_STACK.md](./TECH_STACK.md)를 봅니다.

## 브랜치 경계

`frontend-integration`에는 Flutter 화면, 모델, 순수 Dart 분석 로직, 메모리 저장소, Supabase SDK 초기화만 둡니다. 서버 코드, HTTP API 클라이언트, Supabase Auth·DB 사용 코드와 DB 마이그레이션은 포함하지 않습니다. `main`에는 기존 서버 코드가 있으므로 이 브랜치 전체를 `main`에 병합하지 않습니다.

## 코드 구조

- 기능 코드는 `lib/features/<기능>/`의 `models/`, `data/`, `presentation/`에 둡니다.
- 화면은 Repository 인터페이스를 사용합니다. 각 Repository provider는 메모리 구현을 주입하며 샘플 데이터는 `lib/features/analysis/data/sample_data.dart`에서 만듭니다.
- `AnalysisService`가 기록 저장 → 감정 분석 → 관계 지수 → 인사이트 계산을 연결합니다. 분석·지수·패턴 판정은 UI와 저장소에서 분리된 순수 Dart 코드입니다.
- 홈 요약은 `lib/features/analysis/home_summary_builder.dart`에서 인물·기록·인사이트·체크리스트 데이터를 조립합니다.
- Supabase URL과 publishable key는 `lib/core/config/supabase_config.dart`에 있고, `lib/main.dart`에서 SDK를 초기화합니다. 화면은 Supabase에 요청하지 않습니다.

## 화면 흐름

- 시작 시 로고 스플래시를 약 1.2초 보여 준 뒤 로그인 목업 화면으로 이동합니다.
- 이메일·비밀번호 형식과 가입 동의를 화면에서 검증합니다. 통과하면 샘플 홈으로 이동합니다. 실제 계정 생성이나 세션 저장은 하지 않습니다.
- 로그아웃은 로그인 목업 화면으로 이동합니다. 화면 데이터는 메모리에만 있어 앱을 다시 시작하면 샘플 데이터로 초기화됩니다.
- 하단 탭은 투데이·관계·기록·전체 4개입니다. 각 화면은 Repository 계약을 통해 샘플 데이터를 표시하고 편집합니다.

## 확인

PR 전에 `flutter analyze`와 `flutter test`를 실행합니다. iOS와 Android 화면 변경은 가능한 기기에서 각각 확인하고 결과를 PR에 기록합니다.
