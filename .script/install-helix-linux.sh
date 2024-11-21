#!/bin/bash

# 定義 PPA 名稱
PPA_NAME="ppa:maveonair/helix-editor"

# 檢查是否已添加 PPA
if ! grep -q "^deb .*$PPA_NAME" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
    echo "Adding PPA: $PPA_NAME"
    sudo add-apt-repository -y "$PPA_NAME"
else
    echo "PPA $PPA_NAME already exists. Skipping..."
fi

# 更新 apt 並升級/安裝 helix
echo "Updating package list and ensuring helix is installed/upgraded..."
sudo apt install -y --upgrade helix
