#!/bin/bash

set -e

REPO="siguici/gat"
BRANCH="main"
INSTALL_DIR="$HOME/.local/bin"
TMP_DIR=$(mktemp -d)

echo "📥 Downloading $REPO..."

curl -sL "https://github.com/$REPO/archive/$BRANCH.tar.gz" | tar xz -C "$TMP_DIR"
SRC_DIR="$TMP_DIR/gat-$BRANCH"

echo "📁 Installing to $INSTALL_DIR..."

mkdir -p "$INSTALL_DIR"
cp "$SRC_DIR/bin/gat" "$INSTALL_DIR/gat"
cp "$SRC_DIR/bin/common.sh" "$INSTALL_DIR/common.sh"
chmod +x "$INSTALL_DIR/gat" "$INSTALL_DIR/common.sh"

echo "✅ gat is now installed in $INSTALL_DIR"
echo "👉 Make sure $INSTALL_DIR is in your \$PATH"
