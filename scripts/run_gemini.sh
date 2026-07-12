#!/usr/bin/env bash
set -euo pipefail

device="${1:-}"
shift || true

if [[ ! -f "config/gemini.local.json" ]]; then
  echo "Missing config/gemini.local.json. Create it with GEMINI_API_KEY first." >&2
  exit 1
fi

if [[ -n "$device" ]]; then
  flutter run -d "$device" --dart-define-from-file=config/gemini.local.json "$@"
else
  flutter run --dart-define-from-file=config/gemini.local.json "$@"
fi
