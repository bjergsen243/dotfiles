# autosuggestions & syntax highlighting — search common prefixes
# (Apple Silicon brew, Intel brew, apt, Linuxbrew)
_load_zsh_plugin() {
  local name=$1
  for prefix in /opt/homebrew/share /usr/local/share /usr/share /home/linuxbrew/.linuxbrew/share; do
    if [[ -f "$prefix/$name/$name.zsh" ]]; then
      source "$prefix/$name/$name.zsh"
      return
    fi
  done
}
_load_zsh_plugin zsh-autosuggestions
_load_zsh_plugin zsh-syntax-highlighting
unset -f _load_zsh_plugin
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# zoxide (smarter cd)
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"
