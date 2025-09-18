#!/usr/bin/env bash

set -euo pipefail

FONT_DIR="$HOME/.local/share/fonts"
LOG_FILE="./install-fonts.log"
mkdir -p "$FONT_DIR"

echo "[$(date)] Starting font installation..." | tee "$LOG_FILE"

shopt -s nullglob
FONT_FILES=( *.ttf *.otf *.TTF *.OTF )
shopt -u nullglob

if [ ${#FONT_FILES[@]} -eq 0 ]; then
  echo "[$(date)] No font files found in $(pwd)" | tee -a "$LOG_FILE"
  exit 1
fi

for font in "${FONT_FILES[@]}"; do
  echo "[$(date)] Installing: $font" | tee -a "$LOG_FILE"
  if cp -v "$font" "$FONT_DIR/" >>"$LOG_FILE" 2>&1; then
    echo "[$(date)] Successfully installed $font" | tee -a "$LOG_FILE"
  else
    echo "[$(date)] ERROR: Failed to install $font" | tee -a "$LOG_FILE"
  fi
done

echo "[$(date)] Updating font cache..." | tee -a "$LOG_FILE"
if fc-cache -f "$FONT_DIR" >>"$LOG_FILE" 2>&1; then
  echo "[$(date)] Font cache updated successfully." | tee -a "$LOG_FILE"
else
  echo "[$(date)] ERROR: Failed to update font cache." | tee -a "$LOG_FILE"
  exit 2
fi

echo "[$(date)] Font installation complete." | tee -a "$LOG_FILE"