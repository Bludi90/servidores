#!/usr/bin/env bash
set -euo pipefail

keep_pkgs=(network-manager openssh-server ufw sudo)
echo "[INFO] Mantendré: ${keep_pkgs[*]}"

DM=""
if [[ -f /etc/X11/default-display-manager ]]; then
  DM=$(basename "$(cat /etc/X11/default-display-manager 2>/dev/null || true)" || true)
fi
echo "[INFO] Display manager detectado: ${DM:-<desconocido>}"

# Paquetes a purgar según DM / escritorio más común
PKGS_COMMON="xorg xserver-xorg* xwayland xinit x11-apps x11-utils x11-xserver-utils"
case "$DM" in
  gdm3)    PKGS_DESK="task-gnome-desktop gnome-core gnome-shell gdm3" ;;
  sddm)    PKGS_DESK="task-kde-desktop kde-standard plasma-desktop sddm" ;;
  lightdm) PKGS_DESK="task-xfce-desktop xfce4 xfce4-goodies lightdm" ;;
  lxdm)    PKGS_DESK="task-lxde-desktop lxde lxdm" ;;
  *)       PKGS_DESK="task-gnome-desktop gnome-core gnome-shell gdm3 task-kde-desktop kde-standard plasma-desktop sddm task-xfce-desktop xfce4 xfce4-goodies lightdm task-lxde-desktop lxde lxdm" ;;
esac

echo "[INFO] Purgando (si están instalados): $PKGS_DESK $PKGS_COMMON"
sudo apt-get -y purge $PKGS_DESK $PKGS_COMMON || true

echo "[INFO] Autoremove + limpieza…"
sudo apt -y autoremove --purge
sudo apt -y clean

echo "[INFO] Asegurando red y ssh:"
sudo apt -y install "${keep_pkgs[@]}"
sudo systemctl enable --now ssh
sudo ufw allow 22/tcp >/dev/null 2>&1 || true
sudo ufw reload >/dev/null 2>&1 || true

echo "[OK] GUI eliminada. Objetivo de arranque: texto (multi-user.target)"
