#!/usr/bin/env bash
# Install markdown-white.css + .vscode/settings.json into a repo.
#
# Usage:
#   ./install-to-repo.sh              # current directory
#   ./install-to-repo.sh <repo-path>
#
# Copies CSS to <repo>/.vscode/markdown-white.css and merges
# "markdown.styles": [".vscode/markdown-white.css"] into
# <repo>/.vscode/settings.json (preserves other keys).

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CSS_SRC="$SCRIPT_DIR/markdown-white.css"
TARGET="${1:-.}"

if [ ! -f "$CSS_SRC" ]; then
  echo "CSS not found: $CSS_SRC" >&2
  exit 1
fi
if [ ! -d "$TARGET" ]; then
  echo "target directory not found: $TARGET" >&2
  exit 1
fi

TARGET="$(cd "$TARGET" && pwd)"
VS_DIR="$TARGET/.vscode"
CSS_DST="$VS_DIR/markdown-white.css"
SETTINGS="$VS_DIR/settings.json"

mkdir -p "$VS_DIR"
cp "$CSS_SRC" "$CSS_DST"
echo "wrote: $CSS_DST"

command -v python3 >/dev/null 2>&1 || { echo "python3 required" >&2; exit 1; }

python3 - "$SETTINGS" <<'PY'
import json, re, sys, pathlib
p = pathlib.Path(sys.argv[1])
data = {}
if p.exists():
    raw = p.read_text(encoding="utf-8")
    raw = re.sub(r"/\*.*?\*/", "", raw, flags=re.S)
    raw = re.sub(r"(^|\s)//[^\n]*", r"\1", raw)
    raw = re.sub(r",(\s*[}\]])", r"\1", raw)
    if raw.strip():
        data = json.loads(raw)
desired = [".vscode/markdown-white.css"]
if data.get("markdown.styles") == desired:
    print(f"unchanged: {p}")
    sys.exit(0)
data["markdown.styles"] = desired
p.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print(f"wrote: {p}")
PY
