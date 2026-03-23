#!/bin/bash
set -e

echo "🔗 Installing dotfiles..."

# symlinks
ln -sf ~/dotfiles/zsh/zshrc.symlink ~/.zshrc
ln -sf ~/dotfiles/git/gitconfig.symlink ~/.gitconfig
mkdir -p ~/.config
ln -sf ~/dotfiles/config/starship.toml ~/.config/starship.toml

chmod +x ~/dotfiles/bin/*

# brew dependencies
if command -v brew &>/dev/null; then
  echo "📦 Installing brew packages..."
  brew install --quiet \
    eza bat fd zoxide fzf starship \
    zsh-autosuggestions zsh-syntax-highlighting \
    2>/dev/null || true
else
  echo "⚠️  Homebrew not found. Install it first: https://brew.sh"
fi

echo "✅ Done"
echo "Restart terminal or run: source ~/.zshrc"
