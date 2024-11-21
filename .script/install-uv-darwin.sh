#!/bin/zsh

if command -v uv >/dev/null 2>&1; then
  echo "uv is already installed. Updating to the latest version..."
  brew upgrade uv
else
  echo "uv is not installed. Installing now..."
  brew install uv
fi
