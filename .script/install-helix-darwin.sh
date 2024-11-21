#!/bin/zsh

# 定義軟件名稱
PACKAGE="helix"

# 檢查是否已安裝該軟件
if brew list --formula | grep -q "^$PACKAGE\$"; then
    echo "$PACKAGE is already installed. Upgrading to the latest version..."
    brew upgrade $PACKAGE
else
    echo "$PACKAGE is not installed. Installing now..."
    brew install $PACKAGE
fi
