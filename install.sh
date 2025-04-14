#!/bin/bash

# Destination for the executable
INSTALL_DIR="$HOME/.local/bin"

# Check if the directory exists
if [ ! -d "$INSTALL_DIR" ]; then
  echo "Creating installation directory: $INSTALL_DIR"
  mkdir -p "$INSTALL_DIR"
fi

# Copy the script to the local bin
cp -r bin/* "$INSTALL_DIR"

# Make the scripts executable
chmod +x "$INSTALL_DIR/gat"
chmod +x "$INSTALL_DIR/common.sh"

echo "Installation complete. You can now run 'gat' from the terminal."
