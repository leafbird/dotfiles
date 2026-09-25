
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions zsh-completions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# User configuration

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

export EDITOR='nvim'
alias vi=nvim
alias vim=nvim

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# zsh-completions
autoload -U compinit && compinit

# user-local bin (for starship 등 사용자 디렉토리 설치 도구들)
export PATH="$HOME/.local/bin:$PATH"

# starship
eval "$(starship init zsh)"

# fzf setting
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source <(fzf --zsh)

# -- use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments ($@) to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200'   "$@" ;;
    export|unset) fzf --preview "eval 'echo \$'{}"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview 'bat -n --color=always --line-range :500 {}' "$@" ;;
  esac
}

# zoxide
eval "$(zoxide init zsh)"

# rc 파일을 열고, 적용
alias rc='nvim ~/.zshrc'
alias s='source ~/.zshrc'

# 디렉토리 이동 - midnight commander와 겹쳐서 주석처리.
# function mc() {
#   mkdir -p $1
#   cd $1
# }

# alias 설정
alias h='cd ~'
alias c='clear'
alias l='eza -lah' # or 'ls -lah'
alias lt='eza -lT'

function sshset() {
  local fileType=$1
  local source
  local target="$HOME/.ssh/config"

  # fileType 확인
  case $fileType in
    office)  source="$HOME/dotfiles/ssh/config-office" ;;
    home)    source="$HOME/dotfiles/ssh/config-home" ;;
    *)
      echo "Invalid file type. Use 'office' or 'home'."
      return 1
      ;;
  esac

  # 심볼릭 링크 생성
  echo "Creating symlink to: $source"
  if [ -L $target ] || [ -f $target ]; then
    rm -f "$target"
  fi
  ln -s "$source" "$target"
}

# ★ Host 줄은 별칭을 여러 개 갖는다 (`Host pve-deb debian-13-test`).
#   `^Host ` 를 `ssh ` 로만 바꾸면 `ssh pve-deb debian-13-test` 가 되고,
#   ssh 는 두 번째 토큰을 **원격에서 실행할 명령**으로 읽는다.
#   → 접속은 되는데 `bash: debian-13-test: command not found` 가 뜬다.
#   그래서 **첫 별칭만** 쓴다. 와일드카드 항목(`Host *`)은 접속 대상이 아니라 제외.
function sshconfig() {
  local selection=$(grep -E '^Host[[:space:]]+' ~/.ssh/config \
    | sed -E 's/^Host[[:space:]]+([^[:space:]]+).*/\1/' \
    | grep -v '[*?]' \
    | sed 's/^/ssh /' \
    | fzf)
  [[ -n "$selection" ]] && eval "$selection"
}

# ssh 로컬 포트 포워딩 (터널)
#
#   tun                 # 기본값: moku 1455 (openclaw 로그인 콜백)
#   tun n150 8006       # 다른 호스트/포트
#   tun moku 8384 9384  # 로컬은 9384 로 받기 (포트 충돌 회피)
#   tun ls              # 열려 있는 터널 목록
#   tun close [포트|all] # 닫기 (인자 없으면 전부)
#
# ★ 원격 리스너의 바인딩 주소를 먼저 조회해서 목적지를 자동으로 맞춘다.
#   IPv6 루프백([::1])에만 붙어 있는 서비스에 127.0.0.1 로 포워딩하면
#   터널은 열리는데 연결만 거절돼서 원인 찾기가 아주 성가시다. (2026-08-31 openclaw 로그인)
#
# ★ ls/close 는 명령줄 모양이 아니라 SetEnv 표식(ZTUN=1)으로 터널을 식별한다.
#   터미널 통합(ghostty 등)이 ssh 인자 앞에 -o 옵션을 끼워넣기 때문에
#   'ssh -f -N ...' 같은 패턴 매칭은 환경에 따라 조용히 깨진다.
function tun() {
  local mark='SetEnv=ZTUN=1'
  local host="${1:-moku}"

  if [[ "$host" == "ls" ]]; then
    pgrep -fl "$mark" || echo "열려 있는 터널 없음"
    return 0
  fi

  if [[ "$host" == "close" ]]; then
    local what="${2:-all}"
    local pattern="$mark"
    [[ "$what" != "all" ]] && pattern="${mark}.*-L ${what}:"

    local pids=(${(f)"$(pgrep -f "$pattern")"})
    if (( ${#pids[@]} == 0 )); then
      echo "닫을 터널 없음"
      return 0
    fi
    kill $pids && echo "터널 닫음: ${#pids[@]}개"
    return 0
  fi

  local port="${2:-1455}"
  local lport="${3:-$port}"

  # 이미 로컬 포트가 물려 있으면 중단 (ExitOnForwardFailure 가 잡아주지만 메시지를 명확히)
  if lsof -nP -iTCP:"$lport" -sTCP:LISTEN >/dev/null 2>&1; then
    echo "로컬 ${lport} 포트가 이미 사용 중이다. 'tun ls' 로 확인하거나 세 번째 인자로 다른 로컬 포트를 줘라."
    return 1
  fi

  # 원격에서 해당 포트를 듣고 있는 주소를 조회 → 127.0.0.1 / [::1] 판별
  local bind
  bind=$(ssh -o ConnectTimeout=8 "$host" \
    "ss -ltnH 2>/dev/null | awk '{print \$4}' | grep -E ':${port}\$' | head -1" 2>/dev/null)

  local target
  case "$bind" in
    "")        target="127.0.0.1"
               echo "주의: ${host} 에서 ${port} 를 듣는 프로세스를 못 찾았다. 127.0.0.1 로 가정하고 연다." ;;
    \[*)       target="[::1]" ;;
    *)         target="127.0.0.1" ;;
  esac

  if ssh -f -N -o "$mark" -o ExitOnForwardFailure=yes -L "${lport}:${target}:${port}" "$host"; then
    echo "터널 열림: localhost:${lport} → ${host} ${target}:${port}"
    echo "  http://localhost:${lport}"
    echo "  닫기: tun close ${lport}"
  else
    echo "터널 실패: ${host} ${target}:${port}"
    return 1
  fi
}

function pathlist() {
# alias로 만들면 $PATH가 미리 evaluate 되면서 alias 자체에 고정되어 버린다.
# alias pathlist="echo '$PATH' | tr ':' '\n'"
  echo "$PATH" | tr ':' '\n'
}

# note taking
function note() {
  echo "$(date) $*" >> ~/notes.txt
  echo "Note '$*' saved." >> ~/notes.txt
  echo " " >> ~/notes.txt
}

function notes() {
  if [ -f ~/notes.txt ]; then
    cat ~/notes.txt
  else
    echo "No notes found."
  fi
}

# what is my ip
function myip() {
  curl http://ipecho.net/plain; echo
}

# google
alias google='{read -r arr; open "https://www.google.com/search?q=${arr}"} <<<'

# web
web() {
  url="$*"

  # "http://" 또는 "https://"가 없으면 "https://"를 추가
  if [[ ! "$url" =~ ^(http://|https://) ]]; then
    url="https://$url"
  fi

  # macOS와 Linux에서 적절한 명령 사용
  if [[ "$OSTYPE" == "darwin"* ]]; then
    open "$url"
  else
    xdg-open "$url" &>/dev/null
  fi
}


# git add, commit, push
# $1: commit message
# $2: branch name
#
# gitacp "commit message" "branch name"
# gitacp "update README.md" "main"
function gitacp() {
  git add .
  git commit -m "$1"
  git push origin $2
}

alias gs='git rev-parse --git-dir > /dev/null 2>&1 && git status || eza'
alias ga='git add'
alias gaa='git add .'
alias gpo='git push -u origin'
alias gc='git commit -m'
alias gco='git checkout'
alias gb='git branch'
alias gba='git branch --all'
alias gbd='git branch -D'
alias gcp='git cherry-pick'
alias gd='git diff -w'
alias gu='git reset --soft HEAD~1'
alias gpr='git remote prune origin'
alias ff='gpr && git pull --ff-only'
alias grd='git fetch origin && git rebase origin/$(git rev-parse --abbrev-ref HEAD)'
alias gbb='git-switchbranch'
alias gbf='git branch | head -1 | xargs' # top branch
alias git-current-branch="git branch | grep \* | cut -d ' ' -f2"
alias grc='git rebase --continue'
alias gra='git rebase --abort'
alias gl='git log --oneline --graph --all'

if [[ "$OSTYPE" == "darwin"* ]]; then
  alias listen='sudo lsof -iTCP -sTCP:LISTEN -n -P'
else
  alias listen='netstat -tlnp'
fi

# git CLI 가 diff 생성, bat 은 하이라이트만 (bat --diff 의 libgit2 통합은 Windows 에서 unstaged 변경을 못 잡음)
batdiff() {
    git diff "$@" | bat --language=diff
}

listvms() {
  sh ~/dotfiles/pve/list_vms.sh
}

# quick note — 클립보드 내용을 임시폴더에 md 로 저장하고 glow 로 띄운다 (Windows 판은 pwsh 프로필의 qn)
qn() {
  local dir="${TMPDIR:-/tmp}/qn"
  local file="$dir/$(date +%Y%m%d-%H%M%S).md"
  mkdir -p "$dir"

  if [[ "$OSTYPE" == "darwin"* ]]; then
    pbpaste > "$file"
  elif [[ -n "$WSL_DISTRO_NAME" ]]; then
    powershell.exe -NoProfile -Command '[Console]::OutputEncoding=[Text.Encoding]::UTF8; Get-Clipboard -Raw' | tr -d '\r' > "$file"
  elif [[ -n "$WAYLAND_DISPLAY" ]]; then
    wl-paste --no-newline > "$file"
  else
    xclip -selection clipboard -o > "$file"
  fi

  if [[ ! -s "$file" ]]; then
    echo "qn: 클립보드가 비어 있습니다"
    rm -f "$file"
    return 1
  fi
  glow -p -w $(( COLUMNS - 2 )) "$file"
}

# WSL: share ssh key
if [[ -n "$WSL_DISTRO_NAME" ]]; then
  # Configure ssh forwarding
  export SSH_AUTH_SOCK=$HOME/.ssh/agent.sock
  # need `ps -ww` to get non-truncated command for matching
  # use square brackets to generate a regex match for the process we want but that doesn't match the grep command running it!
  ALREADY_RUNNING=$(ps -auxww | grep -q "[n]piperelay.exe -ei -s //./pipe/openssh-ssh-agent"; echo $?)
  if [[ $ALREADY_RUNNING != "0" ]]; then
      if [[ -S $SSH_AUTH_SOCK ]]; then
          # not expecting the socket to exist as the forwarding command isn't running (http://www.tldp.org/LDP/abs/html/fto.html)
          echo "removing previous socket..."
          rm $SSH_AUTH_SOCK
      fi
      echo "Starting SSH-Agent relay..."
      # setsid to force new session to keep running
      # set socat to listen on $SSH_AUTH_SOCK and forward to npiperelay which then forwards to openssh-ssh-agent on windows
      (setsid socat UNIX-LISTEN:$SSH_AUTH_SOCK,fork EXEC:"npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork &) >/dev/null 2>&1
  fi
fi

# k8s
export KUBECONFIG=$HOME/.kube/config
# kubectl이 설치된 경우에만 alias 설정.
if command -v kubectl &> /dev/null; then
  source <(kubectl completion zsh)
  alias k='kubectl'
  complete -o default -F __start_kubectl k
fi

# Generated for envman. Do not edit.
if [ -d "$HOME/.config/envman" ] && [ -s "$HOME/.config/envman/load.sh" ]; then
  source "$HOME/.config/envman/load.sh"
fi

# nvm - node version manager
if [ -d "$HOME/.nvm" ]; then
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
elif [ -s "/opt/homebrew/opt/nvm/nvm.sh" ]; then
  export NVM_DIR="$HOME/.nvm"
  [ ! -d "$NVM_DIR" ] && mkdir "$NVM_DIR"
  \. "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
fi

# claude code
alias cc='claude --dangerously-skip-permissions'
alias cdx='codex --dangerously-bypass-approvals-and-sandbox'

# OpenClaw Completion
if command -v openclaw &> /dev/null; then
  [[ -f "$HOME/.openclaw/completions/openclaw.zsh" ]] && source "$HOME/.openclaw/completions/openclaw.zsh"
fi

# 머신별 로컬 설정 (git에 안 올라감)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

if [[ -f ~/ff.jsonc ]]; then
  fastfetch -c ~/ff.jsonc
else
  fastfetch
fi
