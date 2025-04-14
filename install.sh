#!/usr/bin/env bash

set -e

REPO="siguici/gat"
INSTALL_DIR="$HOME/.local/bin"
VERSION="latest"
TMP_DIR=$(mktemp -d)
BINARY_NAME="gat"

# --- 🧠 Helper: Fetch latest release ---
function get_latest_release() {
  curl -s "https://api.github.com/repos/$REPO/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/'
}

# --- 💾 Download archive ---
function download_release_archive() {
  local version="$1"
  echo "📥 Downloading release archive for $version..." >&2
  curl -sL "https://github.com/$REPO/archive/refs/tags/$version.tar.gz" | tar xz -C "$TMP_DIR"
  echo "$TMP_DIR/gat-${version#v}"
}

# --- 💾 Fallback to main branch archive ---
function download_main_archive() {
  echo "📥 No release found, downloading main branch..." >&2
  curl -sL "https://github.com/$REPO/archive/refs/heads/main.tar.gz" | tar xz -C "$TMP_DIR"
  echo "$TMP_DIR/gat-main"
}

# --- 📦 Install the binary ---
function install_binary() {
  local src_dir="$1"
  mkdir -p "$INSTALL_DIR"
  cp "$src_dir/bin/$BINARY_NAME" "$INSTALL_DIR/"
  chmod +x "$INSTALL_DIR/$BINARY_NAME"
  echo "✅ Installed '$BINARY_NAME' to $INSTALL_DIR"
}

# --- 🔄 Parse arguments ---
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --version) VERSION="$2"; shift ;;
    --dir) INSTALL_DIR="$2"; shift ;;
    *) echo "❌ Unknown option: $1" && exit 1 ;;
  esac
  shift
done

# --- 🔧 Determine version to download ---
if [[ "$VERSION" == "latest" ]]; then
  VERSION=$(get_latest_release || true)
fi

if [[ -z "$VERSION" ]]; then
  SRC_DIR=$(download_main_archive)
else
  SRC_DIR=$(download_release_archive "$VERSION" || download_main_archive)
fi

# --- 🚀 Install ---
install_binary "$SRC_DIR"

# --- 📌 Reminder ---
echo ""
echo "🛠  Make sure '$INSTALL_DIR' is in your PATH."
echo "ℹ️  You can now run '$BINARY_NAME --help'"
