#!/usr/bin/env bash
# Install the "Markdown White Preview" extension into ALL local VS Code profiles.
# macOS / Linux counterpart of install-extension.ps1 (same behavior, no PowerShell needed).
#
# Why per-profile: VS Code installs extensions into a global folder, but each
# profile decides which are *enabled*. `code --install-extension` only targets
# the default profile, so a custom profile (e.g. "ookami") won't see it unless
# installed with `--profile <name>`. This script loops every profile.
#
# Settings Sync does NOT carry this extension to other machines (it's not on the
# Marketplace), so run this once per machine after cloning dotfiles.
#
# Usage:
#   ./install-extension.sh              # build vsix if missing, install to all profiles
#   ./install-extension.sh --rebuild    # force rebuild the vsix first (after CSS edits)
#   ./install-extension.sh -r           # same as --rebuild
set -euo pipefail

REBUILD=0
case "${1:-}" in
    -r|--rebuild) REBUILD=1 ;;
    "") ;;
    *) echo "unknown arg: $1 (use -r/--rebuild)" >&2; exit 2 ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VSIX="$SCRIPT_DIR/md-white-preview-1.0.0.vsix"

if ! command -v code >/dev/null 2>&1; then
    echo "'code' CLI not found on PATH. In VS Code: Command Palette -> 'Shell Command: Install code command in PATH'." >&2
    exit 1
fi

if [[ "$REBUILD" -eq 1 || ! -f "$VSIX" ]]; then
    if ! command -v npx >/dev/null 2>&1; then
        echo "vsix missing and npx not available to build it. Install Node.js, or copy an existing vsix here." >&2
        exit 1
    fi
    echo "building vsix..."
    ( cd "$SCRIPT_DIR" && npx --yes @vscode/vsce package --allow-missing-repository --out "$(basename "$VSIX")" )
fi

# Resolve VS Code User dir per OS.
case "$(uname -s)" in
    Darwin) USER_DIR="$HOME/Library/Application Support/Code/User" ;;
    *)      USER_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/Code/User" ;;
esac

# Read named profiles from globalStorage/storage.json (prefer jq, fall back to python3).
PROFILES=()
GS="$USER_DIR/globalStorage/storage.json"
if [[ -f "$GS" ]]; then
    if command -v jq >/dev/null 2>&1; then
        while IFS= read -r name; do
            [[ -n "$name" ]] && PROFILES+=("$name")
        done < <(jq -r '.userDataProfiles[]?.name // empty' "$GS" 2>/dev/null || true)
    elif command -v python3 >/dev/null 2>&1; then
        while IFS= read -r name; do
            [[ -n "$name" ]] && PROFILES+=("$name")
        done < <(python3 -c 'import json,sys
try:
    d=json.load(open(sys.argv[1]))
except Exception:
    sys.exit(0)
for p in d.get("userDataProfiles",[]) or []:
    n=p.get("name")
    if n: print(n)' "$GS" 2>/dev/null || true)
    else
        echo "note: neither jq nor python3 found; installing into default profile only." >&2
    fi
fi

# Default profile first (no --profile flag), then every named profile.
echo "installing into default profile"
code --install-extension "$VSIX" --force

for p in "${PROFILES[@]:-}"; do
    [[ -z "$p" ]] && continue
    echo "installing into profile: $p"
    code --profile "$p" --install-extension "$VSIX" --force
done

echo "done. Reload VS Code (Command Palette -> Reload Window)."
