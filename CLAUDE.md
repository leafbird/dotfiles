# Dotfiles

Windows, macOS, Linux를 지원하는 개인 dotfiles 저장소.
Unix 계열은 GNU Stow, Windows는 mklink 심링크로 설정 파일을 관리한다.

## 셋업 스크립트

- `script/setup.sh` — Linux/macOS용. stow 패키지 적용 + SSH config 선택 + pwsh 설정.
- `script/setup.bat` — Windows용. mklink로 개별 심링크 생성.

## Stow 패키지 구조

stow 패키지는 홈 디렉토리 기준의 경로를 그대로 유지한다. 
(예: `claude/.claude/settings.json` → `~/.claude/settings.json`)
`setup.sh`에서 `--no-folding` 옵션으로 적용한다.

| 패키지 | 대상 경로 | 설명 |
|--------|-----------|------|
| `git` | `~/.gitconfig` | Git 설정 (user: choisungki, VSCode diff/merge) |
| `zsh` | `~/.zshrc` | Zsh 설정 (oh-my-zsh, plugins, nvm) |
| `nvim` | `~/.config/nvim/` | Neovim (lazy.nvim, 16+ 플러그인, Lua 기반) |
| `ghostty` | `~/.config/ghostty/` | Ghostty 터미널 (Gruvbox Dark, Hack Nerd Font) |
| `kitty` | `~/.config/kitty/` | Kitty 터미널 |
| `claude` | `~/.claude/` | Claude Code CLI (settings, statusline, CLAUDE.md) |
| `gemini` | `~/.gemini/` | Gemini CLI |
| `hyprland` | `~/.config/hypr/` | Hyprland WM + hyprlock (Linux) |
| `waybar` | `~/.config/waybar/` | Waybar 상태바 (Linux) |

## Stow가 아닌 패키지

| 디렉토리 | 설명 |
|-----------|------|
| `ssh/` | SSH config (home/office 분리). setup 스크립트에서 선택하여 심링크. |
| `vim/` | Vim/GVim 설정 (`_vimrc`, `_gvimrc`). Windows용. |
| `pwsh/` | PowerShell 프로필 + Setup.ps1. 별도 스크립트로 설정. |
| `osx/` | macOS 전용 (Karabiner, Terminal 테마, agnoster 테마) |
| `wsl/` | `.wslconfig` |
| `visual studio/` | VS/SSMS 설정, 코딩 스타일 ruleset |
| `pve/` | Proxmox VE VM 목록 스크립트 |
| `notes/` | 시스템 세팅 가이드, todo |

## 규칙

- 새 설정을 추가할 때 Unix용이면 stow 패키지 구조를 따른다.
- Windows에서도 사용하는 설정이면 `setup.bat`에 mklink 항목을 함께 추가한다.
- 인증 정보, 토큰 등 민감 데이터는 `.gitignore`에 등록하여 커밋하지 않는다.
- `.zshrc.local` 같은 `.local` 파일로 머신별 오버라이드를 지원한다.
