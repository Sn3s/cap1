#!/usr/bin/env bash
set -euo pipefail

device="${1:-}"
shift || true

if [[ -n "$device" ]]; then
  flutter run -d "$device" "$@"
else
  flutter run "$@"
fi
