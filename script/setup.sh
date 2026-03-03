#!/bin/bash
set -euo pipefail

DOTFILES="$HOME/dotfiles"

info() { printf '\033[34m[INFO]\033[0m %s\n' "$1"; }
warn() { printf '\033[33m[WARN]\033[0m %s\n' "$1"; }
ok()   { printf '\033[32m[ OK ]\033[0m %s\n' "$1"; }
err()  { printf '\033[31m[ERR ]\033[0m %s\n' "$1"; }

# --- 사전 조건 ---
if [ ! -d "$DOTFILES" ]; then
  err "dotfiles 디렉토리를 찾을 수 없습니다: $DOTFILES"
  exit 1
fi

if ! command -v stow >/dev/null 2>&1; then
  err "stow가 설치되어 있지 않습니다. 먼저 설치해주세요."
  exit 1
fi

# --- stow 패키지 ---
STOW_PACKAGES=(git zsh nvim ghostty kitty claude hyprland waybar gemini)

for pkg in "${STOW_PACKAGES[@]}"; do
  if [ -d "$DOTFILES/$pkg" ]; then
    stow --no-folding -R "$pkg" -d "$DOTFILES" -t "$HOME" 2>&1 && ok "stow: $pkg" || warn "stow: $pkg 실패"
  else
    warn "stow: $pkg 디렉토리 없음, 건너뜀"
  fi
done

# --- SSH config (stow 구조가 아니므로 별도 처리) ---
mkdir -p ~/.ssh
chmod 700 ~/.ssh

if [ -L ~/.ssh/config ]; then
  ok "ssh: 심링크 이미 존재"
elif [ -f ~/.ssh/config ]; then
  warn "ssh: config 파일이 이미 존재 (심링크 아님), 건너뜀"
else
  # 환경에 맞는 config 선택
  echo ""
  info "SSH config를 선택하세요:"
  echo "  1) home"
  echo "  2) office"
  printf "  선택 [1/2]: "
  read -r ssh_choice
  case "$ssh_choice" in
    1) ssh_variant="config-home" ;;
    2) ssh_variant="config-office" ;;
    *) warn "ssh: 잘못된 선택, 건너뜀"; ssh_variant="" ;;
  esac

  if [ -n "$ssh_variant" ] && [ -f "$DOTFILES/ssh/$ssh_variant" ]; then
    ln -s "$DOTFILES/ssh/$ssh_variant" ~/.ssh/config
    ok "ssh: $ssh_variant 연결"
  elif [ -n "$ssh_variant" ]; then
    warn "ssh: $ssh_variant 파일을 찾을 수 없음"
  fi
fi

# --- PowerShell (선택) ---
if command -v pwsh >/dev/null 2>&1; then
  pwsh "$DOTFILES/pwsh/Setup.ps1" && ok "pwsh: 설정 완료" || warn "pwsh: 설정 실패"
else
  info "pwsh 미설치, 건너뜀"
fi
