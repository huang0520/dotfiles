#!/bin/bash

if command -v uv >/dev/null 2>&1; then
  echo "uv is already installed. Updating to the latest version..."
  uv self update
else
  echo "uv is not installed. Installing now..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# Update completions
echo "update uv and uvx completions..."
mkdir -p ~/.zfunc
uv generate-shell-completion zsh > ~/.zfunc/_uv
uvx generate-shell-completion zsh > ~/.zfunc/_uvx