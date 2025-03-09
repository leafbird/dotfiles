
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

# zoxide
eval "$(zoxide init zsh)"

# rc 파일을 열고, 적용
alias rc='nvim ~/.zshrc'
alias s='source ~/.zshrc'

# 디렉토리 이동
function mc() {
  mkdir -p $1
  cd $1
}

# alias 설정
alias h='cd ~'
alias c='clear'
alias l='eza -lah' # or 'ls -lah'
alias lt='eza -lT'

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

batdiff() {
    git diff --name-only --relative --diff-filter=d | xargs bat --diff
}

fastfetch
