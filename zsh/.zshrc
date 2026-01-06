# ~/.zshrc - managed by dotfiles
# =====================================

# History
export HISTSIZE=10000
export SAVEHIST=10000
setopt inc_append_history
setopt share_history
setopt hist_ignore_dups
setopt hist_reduce_blanks

# Completion
autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Colors
autoload -Uz colors
colors

# Git info (vcs)
autoload -Uz vcs_info
zstyle ':vcs_info:git:*' formats '%F{cyan}git(%b)%f'
zstyle ':vcs_info:*' enable git
precmd() { vcs_info }

setopt prompt_subst

# Prompt (timestamp + colors)
PROMPT='
%F{yellow}[%D{%H:%M:%S}]%f %F{green}%n@%m%f %F{blue}%~%f ${vcs_info_msg_0_}
%F{magenta}❯%f '

# Right prompt (error code)
RPROMPT='%(?..%F{red}✗ %?%f)'

# Aliases
alias ll='ls -lah'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gco='git checkout'
alias gp='git pull'
alias gl='git log --oneline --graph --decorate'

# QoL
setopt auto_cd
setopt correct
setopt no_beep

# Editor
export EDITOR="code --wait"

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
