#!/bin/sh
# Claude Code status line script
# Mirrors a starship-style prompt with Claude session info

input=$(cat)

user=$(whoami)
host=$(hostname -s)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Shorten home directory to ~
home_dir="$HOME"
short_cwd="${cwd/#$home_dir/\~}"

# Git branch (skip optional lock)
git_branch=""
if git -C "$cwd" rev-parse --git-dir --no-optional-locks > /dev/null 2>&1; then
  git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

# Context usage indicator with visual gauge bar (10 blocks wide)
ctx_info=""
if [ -n "$used" ]; then
  used_int=$(printf "%.0f" "$used")
  filled=$(( used_int / 10 ))
  empty=$(( 10 - filled ))
  bar=""
  i=0
  while [ $i -lt $filled ]; do
    bar="${bar}█"
    i=$(( i + 1 ))
  done
  while [ $i -lt 10 ]; do
    bar="${bar}░"
    i=$(( i + 1 ))
  done
  ctx_info=" ctx:${used_int}% ${bar}"
fi

# Build git segment
git_seg=""
if [ -n "$git_branch" ]; then
  git_seg=" ($git_branch)"
fi

printf "\033[32m%s@%s\033[0m \033[34m%s\033[0m\033[33m%s\033[0m \033[36m[%s%s]\033[0m" \
  "$user" "$host" "$short_cwd" "$git_seg" "$model" "$ctx_info"
