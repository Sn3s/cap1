#!/usr/bin/env bash
# Builds Flutter Web in Vercel's Linux build environment.
set -euo pipefail

# This commit is the Flutter SDK used to develop and verify this project
# locally. Pinning it makes Vercel builds reproducible instead of changing
# whenever Flutter's stable channel advances.
readonly FLUTTER_REF="fce807530a201ddbd18d66be2b3295bbe209f389"
readonly FLUTTER_DIR=".vercel/cache/flutter-${FLUTTER_REF}"

# FLUTTER_BIN is intentionally supported for local troubleshooting. Vercel
# leaves it unset, which makes this script fetch the pinned SDK into its build
# cache.
flutter_bin="${FLUTTER_BIN:-}"

if [[ -z "$flutter_bin" ]]; then
  if [[ ! -x "$FLUTTER_DIR/bin/flutter" ]]; then
    rm -rf -- "$FLUTTER_DIR"
    mkdir -p "$(dirname "$FLUTTER_DIR")"
    git clone --filter=blob:none --no-checkout \
      https://github.com/flutter/flutter.git "$FLUTTER_DIR"
    git -C "$FLUTTER_DIR" fetch --depth=1 origin "$FLUTTER_REF"
    git -C "$FLUTTER_DIR" checkout --detach "$FLUTTER_REF"
  fi
  flutter_bin="$FLUTTER_DIR/bin/flutter"
fi

"$flutter_bin" --disable-analytics
"$flutter_bin" config --enable-web
"$flutter_bin" pub get
"$flutter_bin" build web --release
