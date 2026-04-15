#!/bin/bash

# install.sh - Installs backup.sh to /usr/local/bin as 'bkp'

set -e

# Target installation directory
INSTALL_DIR="/usr/local/bin"
SOURCE_FILE="src/backup.sh"
TARGET_NAME="bkp"

# Check if source exists
if [[ ! -f "$SOURCE_FILE" ]]; then
    echo "Error: Source file $SOURCE_FILE not found." >&2
    exit 1
fi

echo "Installing $SOURCE_FILE to $INSTALL_DIR/$TARGET_NAME..."

# Use sudo for privileged installation
sudo cp "$SOURCE_FILE" "$INSTALL_DIR/$TARGET_NAME"
sudo chmod +x "$INSTALL_DIR/$TARGET_NAME"

echo "Installation complete. You can now use the '$TARGET_NAME' command."
