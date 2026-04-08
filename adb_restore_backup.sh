#!/usr/bin/env bash

set -euo pipefail

BACKUP_FOLDER="${1:?Usage: $0 <name_of_folder_in_backups>}"
PACKAGE="${BACKUP_FOLDER%%_*}"

adb root

sleep 1

echo "[INFO] Stopping app"
adb shell am force-stop "$PACKAGE"

echo "[INFO] Cleaning existing data"

adb shell rm -rf /data/data/$PACKAGE
adb shell rm -rf /data/user_de/0/$PACKAGE
adb shell rm -rf /sdcard/Android/data/$PACKAGE
adb shell rm -rf /sdcard/Android/media/$PACKAGE
adb shell rm -rf /sdcard/Android/obb/$PACKAGE

push_and_extract(){
  local tar="$1"
  local destination="$2"

  echo "[INFO] Pushing and extracting ./backups/$BACKUP_FOLDER/$tar ..."

  adb push ./backups/$BACKUP_FOLDER/$tar /sdcard/$tar 2>/dev/null || {
    echo "  [Warning] $tar failed or not found, skipping."
    return
  }

  adb shell "tar -xzpf /sdcard/$tar -C '$destination'"
  adb shell rm /sdcard/$tar
}

push_and_extract data-data.tar.gz /data/data/
push_and_extract user-de-0.tar.gz /data/user_de/0/
push_and_extract android-data.tar.gz /sdcard/Android/data/
push_and_extract android-media.tar.gz /sdcard/Android/media/
push_and_extract android-obb.tar.gz /sdcard/Android/obb/

echo "[FINISH] Backup restored."

