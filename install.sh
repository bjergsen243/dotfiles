#!/bin/bash
set -e

echo "🔗 Installing dotfiles..."

ln -sf ~/dotfiles/zsh/zshrc.symlink ~/.zshrc
ln -sf ~/dotfiles/git/gitconfig.symlink ~/.gitconfig

chmod +x ~/dotfiles/bin/*

echo "✅ Done"
echo "Restart terminal or run: source ~/.zshrc"
