#!/bin/bash

# GitHub repo URL
REPO="https://github.com/helix-editor/helix"

# Get system architecture
ARCH=$(uname -m)

# Map architecture to expected GitHub release naming
case "$ARCH" in
  x86_64) ARCH="x86_64" ;;
  aarch64) ARCH="aarch64" ;;
  armv7l) ARCH="armv7" ;;
  *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

# Function to normalize version (e.g., "24.7" -> "24.07")
normalize_version() {
  echo "$1" | awk -F. '{printf "%d.%02d", $1, $2}'
}

# Function to compare versions
compare_versions() {
  # Usage: compare_versions <version1> <version2>
  # Returns: 0 if equal, 1 if version1 > version2, 2 if version1 < version2
  if [ "$1" = "$2" ]; then
    return 0
  fi

  local IFS=.
  local i v1=($1) v2=($2)

  for ((i=0; i<${#v1[@]} || i<${#v2[@]}; i++)); do
    local n1=${v1[i]:-0}
    local n2=${v2[i]:-0}
    if ((10#n1 > 10#n2)); then
      return 1
    elif ((10#n1 < 10#n2)); then
      return 2
    fi
  done

  return 0
}

# Check if helix is installed and get its version
if command -v hx &> /dev/null; then
  INSTALLED_VERSION_RAW=$(hx --version | awk '{print $2}')
  INSTALLED_VERSION=$(normalize_version "$INSTALLED_VERSION_RAW")
  echo "Helix is installed: version $INSTALLED_VERSION_RAW (normalized: $INSTALLED_VERSION)"
else
  INSTALLED_VERSION="0.00"
  echo "Helix is not installed."
fi

# Fetch latest release info
echo "Fetching latest release for $REPO..."
LATEST_RELEASE=$(curl -s "https://api.github.com/repos/helix-editor/helix/releases/latest")

if [ $? -ne 0 ]; then
  echo "Failed to fetch release info from GitHub."
  exit 1
fi

# Extract version number and normalize it
LATEST_VERSION_RAW=$(echo "$LATEST_RELEASE" | grep '"tag_name"' | cut -d '"' -f 4 | tr -d 'v')
LATEST_VERSION=$(normalize_version "$LATEST_VERSION_RAW")

if [ -z "$LATEST_VERSION" ]; then
  echo "Failed to extract version information."
  exit 1
fi

echo "Latest version available: $LATEST_VERSION_RAW (normalized: $LATEST_VERSION)"

# Compare installed version with latest version
compare_versions "$INSTALLED_VERSION" "$LATEST_VERSION"
VERSION_COMPARE=$?

if [ $VERSION_COMPARE -eq 0 ]; then
  echo "Helix is up to date (version $INSTALLED_VERSION_RAW)."
  exit 0
elif [ $VERSION_COMPARE -eq 1 ]; then
  echo "Helix is newer than the latest release. No action needed."
  exit 0
else
  echo "A newer version of Helix is available: $LATEST_VERSION_RAW (installed: $INSTALLED_VERSION_RAW)."
fi

# Construct expected package name
PACKAGE="helix-v${LATEST_VERSION_RAW}-${ARCH}-linux.tar.xz"

# Extract download URL for the matching package
DOWNLOAD_URL=$(echo "$LATEST_RELEASE" | grep "browser_download_url" | grep "$PACKAGE" | cut -d '"' -f 4)

if [ -z "$DOWNLOAD_URL" ]; then
  echo "No suitable binary found for architecture: $ARCH."
  exit 1
fi

# Download the file
FILENAME=$(basename "$DOWNLOAD_URL")
echo "Downloading $FILENAME..."
curl -L "$DOWNLOAD_URL" -o "$FILENAME"

if [ $? -ne 0 ]; then
  echo "Failed to download $FILENAME."
  exit 1
fi

# Extract the tarball
echo "Extracting $FILENAME..."
tar -xf "$FILENAME"

if [ $? -ne 0 ]; then
  echo "Failed to extract $FILENAME."
  exit 1
fi

# Get the extracted directory name
EXTRACTED_DIR="helix-v${LATEST_VERSION_RAW}-${ARCH}-linux"

if [ ! -d "$EXTRACTED_DIR" ]; then
  echo "Extraction failed: Directory $EXTRACTED_DIR not found."
  exit 1
fi

# Ensure target directories exist
mkdir -p ~/.local/bin
mkdir -p ~/.config/helix

# Move hx binary to ~/.local/bin
HX_PATH="$HOME/.local/bin/hx"
if [ -f "$HX_PATH" ]; then
  echo "$HX_PATH already exists. Overwriting..."
  rm -f "$HX_PATH"
fi
echo "Moving hx to ~/.local/bin..."
mv "${EXTRACTED_DIR}/hx" "$HX_PATH"

if [ $? -ne 0 ]; then
  echo "Failed to move hx to ~/.local/bin."
  exit 1
fi

# Move runtime to ~/.config/helix
RUNTIME_PATH="$HOME/.config/helix/runtime"
if [ -d "$RUNTIME_PATH" ]; then
  echo "$RUNTIME_PATH already exists. Overwriting..."
  rm -rf "$RUNTIME_PATH"
fi
echo "Moving runtime to ~/.config/helix..."
mv "${EXTRACTED_DIR}/runtime" "$RUNTIME_PATH"

if [ $? -ne 0 ]; then
  echo "Failed to move runtime to ~/.config/helix."
  exit 1
fi

# Cleanup
echo "Cleaning up..."
rm -rf "$FILENAME" "$EXTRACTED_DIR"

echo "Helix updated successfully to version $LATEST_VERSION_RAW!"


