#!/bin/bash

# Check if pipx is installed
if command -v pipx >/dev/null 2>&1; then
  echo "pipx is already installed. Upgrading to the latest version..."
  # Upgrade pipx
  python3 -m pip install --user --upgrade pipx
else
  echo "pipx is not installed. Installing now..."
  # Install pipx
  python3 -m pip install --user pipx
fi

echo "Operation completed successfully!"

