#!/bin/bash

if command -v uv >/dev/null 2>&1; then
  uv tool install ruff
  uv tool install "python-lsp-server" --with "pylsp-rope"
  uv tool install basedpyright

else
  echo "Not detect uv!"

fi

uv tool upgrade --all
