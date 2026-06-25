#!/usr/bin/env sh
# genv installer — https://github.com/tinloof/genv
#
#   curl -fsSL https://genv.tinloof.com/install.sh | sh
#
# Environment overrides:
#   GENV_BIN_DIR   where to install genv     (default: $HOME/.local/bin)
#   GENV_REF       git ref for the fallback  (default: main)
#   GENV_SRC       explicit URL/path to the genv script (skips the defaults)

set -eu

REPO="tinloof/genv"
REF="${GENV_REF:-main}"
BIN_DIR="${GENV_BIN_DIR:-$HOME/.local/bin}"
TARGET="$BIN_DIR/genv"
RAW="https://raw.githubusercontent.com/$REPO/$REF/genv"

# Where to fetch genv from: an explicit GENV_SRC, else the branded domain with
# the GitHub raw URL as an automatic fallback (works before/independent of DNS).
if [ -n "${GENV_SRC:-}" ]; then
  SOURCES="$GENV_SRC"
else
  SOURCES="https://genv.tinloof.com/genv $RAW"
fi

if command -v curl >/dev/null 2>&1; then
  fetch() { curl -fsSL "$1"; }
elif command -v wget >/dev/null 2>&1; then
  fetch() { wget -qO- "$1"; }
else
  echo "genv installer: need curl or wget on PATH" >&2
  exit 1
fi

mkdir -p "$BIN_DIR"
tmp="$(mktemp)" || { echo "genv installer: mktemp failed" >&2; exit 1; }
trap 'rm -f "$tmp"' EXIT INT TERM

# Try each source in order; accept the first that downloads and looks like a script.
got=""
for src in $SOURCES; do
  if fetch "$src" > "$tmp" 2>/dev/null && head -n1 "$tmp" | grep -q '^#!'; then
    got="$src"
    break
  fi
done
if [ -z "$got" ]; then
  echo "genv installer: could not download genv (tried: $SOURCES)" >&2
  exit 1
fi

chmod +x "$tmp"
mv "$tmp" "$TARGET"
echo "✓ installed genv → $TARGET  (from $got)"

# Is the install dir on PATH?
case ":$PATH:" in
  *":$BIN_DIR:"*) : ;;
  *)
    echo
    echo "⚠ $BIN_DIR is not on your PATH. Add this to your shell profile, then restart your shell:"
    echo "    export PATH=\"$BIN_DIR:\$PATH\""
    ;;
esac

# genv wraps the GitHub CLI — nudge if it's missing or unauthenticated (non-fatal).
if ! command -v gh >/dev/null 2>&1; then
  echo
  echo "Note: genv needs the GitHub CLI (gh). Install it: https://cli.github.com"
elif ! gh auth status >/dev/null 2>&1; then
  echo
  echo "Note: gh is installed but not authenticated. Run: gh auth login"
fi

echo
echo "Done. Run: genv --help"
