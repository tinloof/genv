#!/usr/bin/env sh
# genv installer — https://github.com/tinloof/genv
#
#   curl -fsSL https://raw.githubusercontent.com/tinloof/genv/main/install.sh | sh
#
# Environment overrides:
#   GENV_BIN_DIR   where to install genv   (default: $HOME/.local/bin)
#   GENV_REF       git ref to install from (default: main)
#   GENV_SRC       full URL/path to the genv script (default: the raw URL for GENV_REF)

set -eu

REPO="tinloof/genv"
REF="${GENV_REF:-main}"
BIN_DIR="${GENV_BIN_DIR:-$HOME/.local/bin}"
SRC="${GENV_SRC:-https://raw.githubusercontent.com/$REPO/$REF/genv}"
TARGET="$BIN_DIR/genv"

# Pick a downloader.
if command -v curl >/dev/null 2>&1; then
  fetch() { curl -fsSL "$1"; }
elif command -v wget >/dev/null 2>&1; then
  fetch() { wget -qO- "$1"; }
else
  echo "genv installer: need curl or wget on PATH" >&2
  exit 1
fi

# Download genv to a temp file, sanity-check it, then move into place.
echo "Installing genv from $SRC"
mkdir -p "$BIN_DIR"
tmp="$(mktemp)" || { echo "genv installer: mktemp failed" >&2; exit 1; }
trap 'rm -f "$tmp"' EXIT INT TERM
if ! fetch "$SRC" > "$tmp"; then
  echo "genv installer: download failed ($SRC)" >&2
  exit 1
fi
if ! head -n1 "$tmp" | grep -q '^#!'; then
  echo "genv installer: downloaded file is not a script — is the ref '$REF' correct?" >&2
  exit 1
fi
chmod +x "$tmp"
mv "$tmp" "$TARGET"
echo "✓ installed genv → $TARGET"

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
