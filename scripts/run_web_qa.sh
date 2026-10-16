#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
exec flutter run -d chrome --web-hostname 127.0.0.1 \
  --dart-define=SHELLBY_WEB_QA=true
