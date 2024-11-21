#!/bin/bash

# Check if pyenv is installed
if command -v pyenv >/dev/null 2>&1; then
  echo "pyenv is already installed. Updating to the latest version..."
  # Update pyenv and its plugins
  pyenv update
else
  echo "pyenv is not installed. Installing now..."
  # Install pyenv
  curl https://pyenv.run | bash
fi

echo "Operation completed successfully!"

