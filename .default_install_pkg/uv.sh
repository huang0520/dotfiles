#!/bin/bash

if command -v uv >/dev/null 2>&1; then
  uv tool install ruff

else
  echo "Not detect uv!"

fi
