autoload -Uz colors vcs_info
colors

zstyle ':vcs_info:git:*' formats '%F{cyan}git(%b)%f'
zstyle ':vcs_info:*' enable git

setopt prompt_subst

# execution time
preexec() {
  TIMER=${EPOCHREALTIME}
}

precmd() {
  vcs_info
  if [[ -n "$TIMER" ]]; then
    ELAPSED=$(printf "%.2f" $(echo "$EPOCHREALTIME - $TIMER" | bc))
    [[ "$ELAPSED" != "0.00" ]] && CMD_TIME="⏱ ${ELAPSED}s"
    unset TIMER
  fi
}

PROMPT='
%F{yellow}[%D{%H:%M:%S}]%f %F{green}%n@%m%f %F{blue}%~%f ${vcs_info_msg_0_}
%F{magenta}❯%f '

RPROMPT='%F{cyan}${CMD_TIME}%f %(?..%F{red}✗ %?%f)'
