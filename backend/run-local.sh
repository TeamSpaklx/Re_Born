#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="$PROJECT_DIR/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "오류: .env 파일을 찾을 수 없습니다: $ENV_FILE" >&2
  exit 1
fi

# .env의 변수를 현재 셸과 Maven 프로세스에 전달합니다.
set -a
source "$ENV_FILE"
set +a

cd "$SCRIPT_DIR"
exec mvn spring-boot:run
