#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
env_file="$root_dir/.env"

if [[ -f "$env_file" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$env_file"
  set +a
fi

device="${1:-}"
shift || true

defines=()
if [[ -n "${GEMINI_API_KEY:-}" ]]; then
  defines+=(--dart-define="GEMINI_API_KEY=$GEMINI_API_KEY")
fi
if [[ -n "${GEMINI_PROXY_URL:-}" ]]; then
  defines+=(--dart-define="GEMINI_PROXY_URL=$GEMINI_PROXY_URL")
elif [[ -n "${GEMINI_API_KEY:-}" ]]; then
  defines+=(--dart-define="GEMINI_PROXY_URL=")
fi
defines+=(--dart-define="GEMINI_MODEL=${GEMINI_MODEL:-gemini-3.1-flash-lite}")

if [[ -n "$device" ]]; then
  flutter run -d "$device" "${defines[@]}" "$@"
else
  flutter run "${defines[@]}" "$@"
fi
