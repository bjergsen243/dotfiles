#!/bin/bash
set -e

DOTFILES="$HOME/dotfiles"

echo "🔗 Installing dotfiles..."

# symlinks (POSIX — works on macOS, Linux, WSL)
ln -sf "$DOTFILES/zsh/zshrc.symlink"      "$HOME/.zshrc"
ln -sf "$DOTFILES/git/gitconfig.symlink"  "$HOME/.gitconfig"
mkdir -p "$HOME/.config"
ln -sf "$DOTFILES/config/starship.toml"   "$HOME/.config/starship.toml"
mkdir -p "$HOME/.claude/hooks"
ln -sf "$DOTFILES/claude/hooks/statusline.js" "$HOME/.claude/hooks/statusline.js"

chmod +x "$DOTFILES/bin/"*

# package install — detect platform
if command -v brew &>/dev/null; then
  echo "📦 Installing brew packages..."
  brew install --quiet \
    git zsh jq uv \
    eza bat fd zoxide fzf starship ripgrep git-delta \
    zsh-autosuggestions zsh-syntax-highlighting \
    2>/dev/null || true
  echo "🔤 Installing JetBrains Mono Nerd Font..."
  brew install --cask --quiet font-jetbrains-mono-nerd-font 2>/dev/null || true

elif command -v apt-get &>/dev/null; then
  echo "📦 Installing apt packages..."
  sudo apt-get update -qq
  sudo apt-get install -y \
    git zsh jq unzip \
    bat fd-find zoxide fzf ripgrep git-delta \
    zsh-autosuggestions zsh-syntax-highlighting \
    2>/dev/null || true

  # eza: only in Ubuntu 24.04+, fail gracefully
  sudo apt-get install -y eza 2>/dev/null || \
    echo "⚠️  eza not in apt — see https://github.com/eza-community/eza/blob/main/INSTALL.md"

  # starship: not in apt, use official installer
  if ! command -v starship &>/dev/null; then
    echo "📦 Installing starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
  fi

  # uv: not in apt, use official installer
  if ! command -v uv &>/dev/null; then
    echo "📦 Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
  fi

  # JetBrains Mono Nerd Font (Linux desktop / WSLg GUI)
  if [ ! -d "$HOME/.local/share/fonts/JetBrainsMono" ]; then
    echo "🔤 Installing JetBrains Mono Nerd Font..."
    mkdir -p "$HOME/.local/share/fonts/JetBrainsMono"
    tmp_font_zip=$(mktemp -t jbmono.XXXXXX.zip)
    curl -fL -o "$tmp_font_zip" \
      https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
    unzip -oq "$tmp_font_zip" -d "$HOME/.local/share/fonts/JetBrainsMono"
    rm -f "$tmp_font_zip"
    command -v fc-cache &>/dev/null && fc-cache -f >/dev/null
  fi

  # WSL: terminal font is configured on Windows, not Linux
  if grep -qi microsoft /proc/version 2>/dev/null; then
    echo "ℹ️  WSL detected — terminal font is configured on Windows side."
    echo "   Install JetBrainsMono Nerd Font on Windows: https://www.nerdfonts.com/font-downloads"
    echo "   Then in Windows Terminal: Settings → WSL profile → Font → JetBrainsMono Nerd Font"
  fi

  # apt names differ from binaries — symlink for compat
  mkdir -p "$HOME/.local/bin"
  command -v batcat &>/dev/null && ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
  command -v fdfind &>/dev/null && ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"

else
  echo "⚠️  No supported package manager found (brew or apt-get)"
  echo "   Install manually: git zsh jq uv eza bat fd zoxide fzf starship ripgrep git-delta"
  echo "                    zsh-autosuggestions zsh-syntax-highlighting"
fi

# bun + nvm: official installers append to ~/.zshrc, but our zshrc.symlink is in
# the dotfiles repo and bun/nvm setup already lives in zsh/env.zsh. Snapshot
# zshrc.symlink before, restore after, to keep the repo file clean.
zshrc_backup=$(mktemp)
cp "$DOTFILES/zsh/zshrc.symlink" "$zshrc_backup"

if ! command -v bun &>/dev/null; then
  echo "📦 Installing bun..."
  curl -fsSL https://bun.sh/install | bash || true
fi

if [ ! -d "$HOME/.nvm" ]; then
  echo "📦 Installing nvm..."
  PROFILE=/dev/null bash -c 'curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash' || true
fi

if ! cmp -s "$zshrc_backup" "$DOTFILES/zsh/zshrc.symlink"; then
  echo "ℹ️  Reverting installer modifications to zshrc.symlink (bun/nvm already wired in env.zsh)"
  cp "$zshrc_backup" "$DOTFILES/zsh/zshrc.symlink"
fi
rm -f "$zshrc_backup"

# set zsh as default shell if current shell isn't zsh
if command -v zsh &>/dev/null && [ "$(basename "$SHELL")" != "zsh" ]; then
  echo "🐚 Setting zsh as default shell..."
  chsh -s "$(command -v zsh)" || echo "⚠️  chsh failed — run manually: chsh -s \$(command -v zsh)"
fi

echo "✅ Done"
echo "Restart terminal or run: source ~/.zshrc"
