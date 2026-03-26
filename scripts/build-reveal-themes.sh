#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CSS_DIR="$ROOT_DIR/docs/css"
LOCAL_SASS="$ROOT_DIR/.codex-tools/node_modules/.bin/sass"
SASS_BIN=""

usage() {
  cat <<EOF
Build reveal.js theme SCSS files into CSS.

Usage:
  ./scripts/build-reveal-themes.sh
  ./scripts/build-reveal-themes.sh signal_ledger
  ./scripts/build-reveal-themes.sh theme_quantum_cosmos.scss
  ./scripts/build-reveal-themes.sh docs/css/theme_signal_ledger.scss
  ./scripts/build-reveal-themes.sh --list
  ./scripts/build-reveal-themes.sh --help

Behavior:
  - Builds all canonical theme_*.scss files in docs/css when no theme is given
  - Skips copy files such as "theme_* - Copy.scss" in the default build
  - Reuses local Sass from ./.codex-tools when available
  - Falls back to a global "sass" binary if one is installed
  - If Sass is missing but npm is available, attempts a local install in ./.codex-tools
EOF
}

list_themes() {
  find "$CSS_DIR" -maxdepth 1 -type f -name 'theme_*.scss' ! -name '* - Copy.scss' | sort
}

print_relpath() {
  local path="$1"
  printf '%s\n' "${path#"$ROOT_DIR"/}"
}

ensure_sass() {
  if [[ -x "$LOCAL_SASS" ]]; then
    SASS_BIN="$LOCAL_SASS"
    return 0
  fi

  if command -v sass >/dev/null 2>&1; then
    SASS_BIN="$(command -v sass)"
    return 0
  fi

  if ! command -v npm >/dev/null 2>&1; then
    cat >&2 <<EOF
Error: Sass is not installed.

Required tool:
  - Sass

Fix one of these:
  - install Sass globally so "sass" is on your PATH
  - or install a local copy with:
      npm install --no-save --prefix ./.codex-tools sass
EOF
    return 1
  fi

  echo "Sass not found. Installing a local copy in ./.codex-tools..." >&2

  if npm install --no-save --prefix "$ROOT_DIR/.codex-tools" sass; then
    if [[ -x "$LOCAL_SASS" ]]; then
      SASS_BIN="$LOCAL_SASS"
      return 0
    fi
  fi

  cat >&2 <<EOF
Error: Sass could not be installed automatically.

Required tool:
  - Sass

Try again with:
  npm install --no-save --prefix ./.codex-tools sass
EOF
  return 1
}

resolve_theme() {
  local input="$1"
  local candidate

  if [[ -f "$input" ]]; then
    printf '%s\n' "$input"
    return 0
  fi

  for candidate in \
    "$CSS_DIR/$input" \
    "$CSS_DIR/$input.scss" \
    "$CSS_DIR/theme_$input" \
    "$CSS_DIR/theme_$input.scss"
  do
    if [[ -f "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  return 1
}

build_theme() {
  local source="$1"
  local output

  output="${source%.scss}.css"

  if [[ "$source" != *.scss ]]; then
    echo "Skipping non-SCSS file: $(print_relpath "$source")" >&2
    return 0
  fi

  echo "Building $(print_relpath "$source") -> $(print_relpath "$output")"
  "$SASS_BIN" "$source" "$output" --no-source-map
}

main() {
  local -a sources=()
  local resolved
  local theme

  case "${1:-}" in
    --help|-h)
      usage
      exit 0
      ;;
    --list)
      list_themes | while IFS= read -r theme; do
        print_relpath "$theme"
      done
      exit 0
      ;;
  esac

  ensure_sass

  if [[ $# -eq 0 ]]; then
    while IFS= read -r resolved; do
      sources+=("$resolved")
    done < <(list_themes)
  else
    for resolved in "$@"; do
      if ! resolved="$(resolve_theme "$resolved")"; then
        echo "Error: could not find theme source for '$resolved'." >&2
        echo "Run './scripts/build-reveal-themes.sh --list' to see available themes." >&2
        exit 1
      fi

      sources+=("$resolved")
    done
  fi

  if [[ ${#sources[@]} -eq 0 ]]; then
    echo "Error: no buildable theme SCSS files were found in $(print_relpath "$CSS_DIR")." >&2
    exit 1
  fi

  for resolved in "${sources[@]}"; do
    build_theme "$resolved"
  done
}

main "$@"
