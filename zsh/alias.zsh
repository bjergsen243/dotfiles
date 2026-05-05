# files
alias ls='eza --icons'
alias ll='eza -lah --icons --git'
alias lt='eza --tree --level=2 --icons'
alias cat='bat --paging=never'

# navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# git
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gcm='git commit -m'
alias gco='git checkout'
alias gl='git log --oneline --graph --decorate'
alias gp='git pull'
alias gP='git push origin HEAD'
alias gpf='git push -u origin HEAD'
alias gpsafe='git pull --rebase && git push origin HEAD'
alias gd='git diff'
alias gb='git branch'
alias gpl='git stash && git checkout main && git pull origin && git stash pop'
# search
alias rg='rg --smart-case'
alias rgf='rg --files | rg'

# git stash
alias gst='git stash push -m'
alias gstp='git stash pop'

# claude code accounts
alias claude1='CLAUDE_CONFIG_DIR=~/.claude-account1 claude'
alias claude2='CLAUDE_CONFIG_DIR=~/.claude-account2 claude'
alias cc='claude-auto'

# shortcuts
alias c='clear'
alias h='history | tail -30'
alias ports='lsof -i -P -n | grep LISTEN'
alias ip='curl -s ifconfig.me'
alias reload='source ~/.zshrc'

