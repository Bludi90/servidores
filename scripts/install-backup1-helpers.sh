#!/usr/bin/env bash
set -Eeuo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="$REPO_DIR/scripts/backup1"
SUDOERS_DIR="$SRC_DIR/sudoers"

install -o root -g root -m 0750 "$SRC_DIR/backup1-safe-poweroff" /usr/local/sbin/backup1-safe-poweroff
install -o root -g root -m 0750 "$SRC_DIR/backup1-zfs-restore-helper" /usr/local/sbin/backup1-zfs-restore-helper

install -o root -g root -m 0440 "$SUDOERS_DIR/alejandro-backup1-poweroff" /etc/sudoers.d/alejandro-backup1-poweroff
install -o root -g root -m 0440 "$SUDOERS_DIR/alejandro-backup1-zfs-restore-helper" /etc/sudoers.d/alejandro-backup1-zfs-restore-helper

visudo -cf /etc/sudoers.d/alejandro-backup1-poweroff
visudo -cf /etc/sudoers.d/alejandro-backup1-zfs-restore-helper

echo "OK: backup1 helpers instalados"
ls -l /usr/local/sbin/backup1-safe-poweroff /usr/local/sbin/backup1-zfs-restore-helper
ls -l /etc/sudoers.d/alejandro-backup1-poweroff /etc/sudoers.d/alejandro-backup1-zfs-restore-helper
