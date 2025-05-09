
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

function sshconfig() {
  local selection=$(grep -E "^Host\s+" ~/.ssh/config | sed -E 's/^Host /ssh /' | fzf)
  [[ -n "$selection" ]] && eval "$selection"
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

batdiff() {
    git diff --name-only --relative --diff-filter=d | xargs bat --diff
}

listvms() {
  sh ~/dotfiles/pve/list_vms.sh
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

fastfetch
