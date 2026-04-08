#!/usr/bin/env bash

set -euo pipefail

PACKAGE="${1:?Usage: $0 <package_id_of_app>}"
OUT_DIR="${2:-./backups}/${PACKAGE}_$(date +"%Y-%m-%d_%H-%M-%S")"

mkdir -p "$OUT_DIR"

adb root

sleep 1

echo "[INFO] Stopping app"
adb shell am force-stop "$PACKAGE"

pull_dir_tar() {
  local dir="$1"
  local label="$2"
  local tarball="$OUT_DIR/${label}.tar.gz"

  echo "[INFO] Archiving and pulling $dir$PACKAGE ..."

  adb shell "tar -czpf /sdcard/${PACKAGE}_${label}_backup.tar.gz -C '${dir}' '${PACKAGE}'" 2>/dev/null || {
    echo "  [Warning] $dir$PACKAGE failed or not found, skipping."
    return
  }

  adb pull "/sdcard/${PACKAGE}_${label}_backup.tar.gz" "$tarball"
  adb shell "rm -f /sdcard/${PACKAGE}_${label}_backup.tar.gz"
}

pull_dir_tar "/data/data/"            "data-data"
pull_dir_tar "/data/user_de/0/"       "user-de-0"
pull_dir_tar "/sdcard/Android/data/"  "android-data"
pull_dir_tar "/sdcard/Android/media/" "android-media"
pull_dir_tar "/sdcard/Android/obb/"   "android-obb"

echo "[FINISH] Done. Backup saved to $OUT_DIR"
