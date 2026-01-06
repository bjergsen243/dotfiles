#!/bin/bash
set -e

echo "🔗 Linking dotfiles..."

ln -sf ~/dotfiles/zsh/.zshrc ~/.zshrc
ln -sf ~/dotfiles/git/.gitconfig ~/.gitconfig

chmod +x ~/dotfiles/bin/*

echo "✅ Dotfiles installed"
echo "Please restart your terminal or run 'source ~/.zshrc' to apply changes."