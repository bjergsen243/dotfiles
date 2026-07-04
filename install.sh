#!/usr/bin/env bash
set -Eeuo pipefail

DOTFILES="${DOTFILES:-$HOME/code/dotfiles}"
LOCAL_BIN="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config"

log() {
  printf '\n%s\n' "$1"
}

warn() {
  printf '⚠️  %s\n' "$1" >&2
}

require_file() {
  local path="$1"

  if [[ ! -e "$path" ]]; then
    echo "❌ Required file not found: $path" >&2
    exit 1
  fi
}

ensure_path() {
  mkdir -p "$LOCAL_BIN"

  case ":$PATH:" in
    *":$LOCAL_BIN:"*) ;;
    *)
      export PATH="$LOCAL_BIN:$PATH"
      ;;
  esac
}

safe_link() {
  local source="$1"
  local target="$2"

  require_file "$source"
  mkdir -p "$(dirname "$target")"
  ln -sfn "$source" "$target"
}

install_apt_packages() {
  log "📦 Installing Ubuntu packages..."

  sudo apt-get update -qq

  sudo apt-get install -y \
    ca-certificates \
    curl \
    git \
    zsh \
    jq \
    unzip \
    fontconfig \
    bat \
    fd-find \
    fzf \
    ripgrep \
    git-delta \
    zoxide \
    zsh-autosuggestions \
    zsh-syntax-highlighting

  # Ubuntu package availability may vary by repo configuration.
  if apt-cache show eza >/dev/null 2>&1; then
    sudo apt-get install -y eza
  else
    warn "eza is not available from your enabled apt repositories."
    warn "Install it separately from the official eza instructions if needed."
  fi
}

install_starship() {
  if command -v starship >/dev/null 2>&1; then
    return
  fi

  log "📦 Installing Starship..."

  curl -fsSL https://starship.rs/install.sh \
    | sh -s -- --yes --bin-dir "$LOCAL_BIN"
}

install_uv() {
  if command -v uv >/dev/null 2>&1; then
    return
  fi

  log "📦 Installing uv..."

  curl -LsSf https://astral.sh/uv/install.sh | sh

  # uv installer normally installs here.
  export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
}

install_nerd_font() {
  local font_dir="$HOME/.local/share/fonts/JetBrainsMono"
  local zip_file

  if [[ -d "$font_dir" ]] && find "$font_dir" -type f \( -name '*.ttf' -o -name '*.otf' \) -print -quit | grep -q .; then
    return
  fi

  log "🔤 Installing JetBrains Mono Nerd Font..."

  mkdir -p "$font_dir"
  zip_file="$(mktemp -t JetBrainsMonoNerdFont.XXXXXX.zip)"

  trap 'rm -f "$zip_file"' RETURN

  curl -fL \
    -o "$zip_file" \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"

  unzip -oq "$zip_file" -d "$font_dir"

  if command -v fc-cache >/dev/null 2>&1; then
    fc-cache -f "$HOME/.local/share/fonts" >/dev/null
  fi
}

install_bun() {
  if command -v bun >/dev/null 2>&1 || [[ -x "$HOME/.bun/bin/bun" ]]; then
    return
  fi

  log "📦 Installing Bun..."

  # Bun installer may update shell profile. Temporarily disable profile detection.
  BUN_INSTALL="$HOME/.bun" \
  SHELL="$(command -v bash)" \
  curl -fsSL https://bun.sh/install | bash
}

install_nvm() {
  if [[ -d "$HOME/.nvm" ]]; then
    return
  fi

  log "📦 Installing NVM..."

  PROFILE=/dev/null \
    bash -c 'curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash'
}

configure_compat_commands() {
  mkdir -p "$LOCAL_BIN"

  if command -v batcat >/dev/null 2>&1; then
    ln -sfn "$(command -v batcat)" "$LOCAL_BIN/bat"
  fi

  if command -v fdfind >/dev/null 2>&1; then
    ln -sfn "$(command -v fdfind)" "$LOCAL_BIN/fd"
  fi
}

set_default_shell() {
  local zsh_path

  zsh_path="$(command -v zsh || true)"

  [[ -n "$zsh_path" ]] || return 0
  [[ "$(basename "${SHELL:-}")" == "zsh" ]] && return 0

  if ! grep -qxF "$zsh_path" /etc/shells; then
    warn "$zsh_path is not listed in /etc/shells; cannot safely run chsh."
    return 0
  fi

  log "🐚 Setting zsh as default shell..."

  chsh -s "$zsh_path" || warn "chsh failed. Run manually: chsh -s $zsh_path"
}

main() {
  require_file "$DOTFILES/zsh/zshrc.symlink"
  require_file "$DOTFILES/git/gitconfig.symlink"
  require_file "$DOTFILES/config/starship.toml"

  ensure_path

  log "🔗 Installing dotfiles..."

  safe_link "$DOTFILES/zsh/zshrc.symlink" "$HOME/.zshrc"
  safe_link "$DOTFILES/git/gitconfig.symlink" "$HOME/.gitconfig"
  safe_link "$DOTFILES/config/starship.toml" "$CONFIG_DIR/starship.toml"
  safe_link "$DOTFILES/claude/hooks/statusline.js" "$HOME/.claude/hooks/statusline.js"

  if compgen -G "$DOTFILES/bin/*" >/dev/null; then
    chmod +x "$DOTFILES/bin/"*
  fi

  if command -v brew >/dev/null 2>&1; then
    log "📦 Installing Homebrew packages..."

    brew install \
      git zsh jq uv \
      eza bat fd zoxide fzf starship ripgrep git-delta \
      zsh-autosuggestions zsh-syntax-highlighting

    brew install --cask font-jetbrains-mono-nerd-font || true

  elif command -v apt-get >/dev/null 2>&1; then
    install_apt_packages
    configure_compat_commands
    install_starship
    install_uv
    install_nerd_font

    if grep -qiE 'microsoft|wsl' /proc/version 2>/dev/null; then
      echo "ℹ️  WSL detected — configure JetBrainsMono Nerd Font in Windows Terminal."
    fi
  else
    warn "No supported package manager found."
  fi

  install_bun
  install_nvm
  set_default_shell

  echo
  echo "✅ Done"
  echo "Restart terminal, or run:"
  echo "exec zsh"
}

main "$@"