#!/usr/bin/env bash
#
# windows-familiarity.sh
# Configures a new GNOME desktop to feel more like Windows AND installs
# the essential compatibility/utility apps a Windows switcher expects.
#
# Usage:
#   ./windows-familiarity.sh           # Apply configuration + install apps
#   ./windows-familiarity.sh --restore # Revert GNOME settings to backup
#
set -euo pipefail

BACKUP_DIR="${HOME}/.config/windows-familiarity-backup"
THEME_NAME="Win11"
ICON_THEME="Win11"

EXTENSION_LIST=(
  "dash-to-panel@jderose9.github.com"
  "arcmenu@arcmenu.com"
  "blur-my-shell@aunetx"
  "user-theme@gnome-shell-extensions.gcampax.github.com"
)

# --- Helper Functions ---
log() { printf '\033[1;34m[INFO]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[WARN]\033[0m %s\n' "$*"; }
error() { printf '\033[1;31m[ERROR]\033[0m %s\n' "$*" >&2; }

detect_distro() {
  if command -v apt >/dev/null; then echo "debian";
  elif command -v dnf >/dev/null; then echo "fedora";
  elif command -v pacman >/dev/null; then echo "arch";
  else echo "unknown"; fi
}

install_package() {
  local pkg="$1"
  local distro
  distro=$(detect_distro)
  log "Installing package: ${pkg}"
  case "${distro}" in
    debian) sudo apt update && sudo apt install -y "${pkg}" ;;
    fedora) sudo dnf install -y "${pkg}" ;;
    arch)   sudo pacman -S --noconfirm "${pkg}" ;;
    *) warn "Unknown distribution. Please install '${pkg}' manually."; return 1 ;;
  esac
}

install_flatpak_app() {
  local app_id="$1"
  if ! command -v flatpak >/dev/null; then
    warn "Flatpak is not installed. Skipping ${app_id}."
    return 1
  fi
  log "Installing Flatpak app: ${app_id}"
  flatpak install -y --noninteractive flathub "${app_id}" || \
    warn "Could not install ${app_id} via Flatpak."
}

# --- Backup & Restore (unchanged) ---
backup_settings() {
  mkdir -p "${BACKUP_DIR}"
  log "Backing up current GNOME settings to ${BACKUP_DIR}"
  dconf dump /org/gnome/desktop/interface/ > "${BACKUP_DIR}/interface.dconf" 2>/dev/null || true
  dconf dump /org/gnome/desktop/wm/preferences/ > "${BACKUP_DIR}/wm-preferences.dconf" 2>/dev/null || true
  dconf dump /org/gnome/shell/extensions/dash-to-panel/ > "${BACKUP_DIR}/dash-to-panel.dconf" 2>/dev/null || true
  dconf dump /org/gnome/shell/extensions/arcmenu/ > "${BACKUP_DIR}/arcmenu.dconf" 2>/dev/null || true
  dconf dump /org/gnome/shell/extensions/user-theme/ > "${BACKUP_DIR}/user-theme.dconf" 2>/dev/null || true
}

restore_settings() {
  if [[ ! -d "${BACKUP_DIR}" ]]; then
    error "No backup found at ${BACKUP_DIR}. Cannot restore."
    exit 1
  fi
  log "Restoring GNOME settings from backup..."
  dconf load /org/gnome/desktop/interface/ < "${BACKUP_DIR}/interface.dconf" 2>/dev/null || true
  dconf load /org/gnome/desktop/wm/preferences/ < "${BACKUP_DIR}/wm-preferences.dconf" 2>/dev/null || true
  dconf load /org/gnome/shell/extensions/dash-to-panel/ < "${BACKUP_DIR}/dash-to-panel.dconf" 2>/dev/null || true
  dconf load /org/gnome/shell/extensions/arcmenu/ < "${BACKUP_DIR}/arcmenu.dconf" 2>/dev/null || true
  dconf load /org/gnome/shell/extensions/user-theme/ < "${BACKUP_DIR}/user-theme.dconf" 2>/dev/null || true
  for ext in "${EXTENSION_LIST[@]}"; do
    gnome-extensions disable "${ext}" 2>/dev/null || true
  done
  log "Restore complete. Log out and back in to apply fully."
  exit 0
}

# --- Prerequisites & Desktop Familiarity (extended) ---
install_prerequisites() {
  log "Installing core tools and Flatpak..."
  install_package gnome-tweaks || true
  install_package gnome-shell-extension-prefs || true
  install_package flatpak || true
  # Enable Flathub for easy graphical app installs
  if command -v flatpak >/dev/null; then
    flatpak remote-add --if-not-exists flathub \
      https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true
  fi
}

install_extensions() {
  # (Same extension installation logic as previous version)
  install_package gnome-shell-extension-dash-to-panel 2>/dev/null || true
  install_package gnome-shell-extension-arcmenu 2>/dev/null || true
  if command -v gnome-extensions >/dev/null; then
    for ext in "${EXTENSION_LIST[@]}"; do
      if ! gnome-extensions list --installed 2>/dev/null | grep -q "${ext}"; then
        log "Attempting to install ${ext} via gnome-extensions..."
        gnome-extensions install "${ext}" 2>/dev/null || \
          warn "Could not auto-install ${ext}. Install it manually from extensions.gnome.org."
      fi
    done
  fi
}

install_theme() {
  local theme_dir="${HOME}/.themes/${THEME_NAME}"
  if [[ -d "${theme_dir}" ]]; then return; fi
  local tmp_dir
  tmp_dir=$(mktemp -d)
  if git clone --depth 1 https://github.com/yeyushengfan258/Windows11-gtk-theme.git "${tmp_dir}/theme" 2>/dev/null; then
    (cd "${tmp_dir}/theme" && ./install.sh -d "${HOME}/.themes" -n "${THEME_NAME}" -t blue -c standard -s standard) || \
      warn "Theme install script failed. You can install it manually later."
  else
    warn "Could not download theme. You can install it manually from gnome-look.org."
  fi
  rm -rf "${tmp_dir}"
}

apply_gsettings() {
  log "Applying GNOME settings for a Windows-like feel..."
  gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close' 2>/dev/null || true
  gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com 2>/dev/null || true
  gsettings set org.gnome.desktop.interface gtk-theme "${THEME_NAME}" 2>/dev/null || true
  gsettings set org.gnome.desktop.interface icon-theme "${ICON_THEME}" 2>/dev/null || true
}

enable_extensions() {
  for ext in "${EXTENSION_LIST[@]}"; do
    gnome-extensions enable "${ext}" 2>/dev/null || \
      warn "Could not enable ${ext}. Enable it manually in the Extensions app."
  done
}

configure_taskbar() {
  local d2p_schema="org.gnome.shell.extensions.dash-to-panel"
  gsettings set "${d2p_schema}" panel-position 'BOTTOM' 2>/dev/null || true
  gsettings set "${d2p_schema}" panel-length 'FULL' 2>/dev/null || true
  gsettings set "${d2p_schema}" show-appmenu false 2>/dev/null || true
  gsettings set "${d2p_schema}" show-activities-button false 2>/dev/null || true
  gsettings set "${d2p_schema}" animate-appicons false 2>/dev/null || true
}

configure_start_menu() {
  local arc_schema="org.gnome.shell.extensions.arcmenu"
  gsettings set "${arc_schema}" menu-layout '11' 2>/dev/null || true
  gsettings set "${arc_schema}" menu-button-icon 'DistributorLogo' 2>/dev/null || true
}

# --- NEW: Install Office & Compatibility Tools ---
install_office_suite() {
  log "Installing LibreOffice (Word, Excel, PowerPoint equivalents)..."
  install_package libreoffice || true
  # Optional: OnlyOffice offers stronger .docx/.xlsx/.pptx compatibility
  # and a more modern ribbon-style UI. Uncomment to install via Flatpak.
  # install_flatpak_app "org.onlyoffice.desktopeditors"
}

install_compatibility_tools() {
  log "Installing Windows compatibility layer (Wine, Winetricks, Bottles)..."

  # Core Wine + Winetricks (native packages)
  install_package wine || true
  install_package winetricks || true

  # Bottles: the graphical, beginner-friendly way to run Windows apps.
  # The Flatpak version is recommended by the community[reference:0].
  install_flatpak_app "com.usebottles.bottles" || true
}

install_windows_utilities() {
  log "Installing familiar Windows-style utility apps..."

  # Media player (the universal VLC that Windows users already know)
  install_package vlc || true

  # Screenshot & annotation (ShareX/Snipping Tool replacement)[reference:1]
  install_package flameshot || true

  # Clipboard manager (a smarter Windows clipboard)[reference:2]
  install_package copyq || true

  # Phone integration (Microsoft Phone Link replacement)[reference:3]
  # KDE Connect works across GNOME and Windows/Android.
  install_package kdeconnect || true

  # Image editor (Paint / basic Photoshop replacement)[reference:4]
  install_package gimp || true

  # Archive manager with Windows-like 7-Zip support[reference:5]
  install_package p7zip-full 2>/dev/null || install_package p7zip || true
  install_package file-roller || true

  # System backup / snapshots (System Restore equivalent)[reference:6]
  install_package timeshift || true

  # File synchronization (a local Dropbox/OneDrive alternative)[reference:7]
  install_package syncthing || true

  # Simple text editor with Windows Notepad++-style features[reference:8]
  install_package geany || true
}

# --- Main Execution ---
main() {
  if [[ "${1:-}" == "--restore" ]]; then
    restore_settings
  fi

  log "Starting Windows familiarity setup + app installation."
  backup_settings
  install_prerequisites
  install_extensions
  install_theme
  apply_gsettings
  enable_extensions
  configure_taskbar
  configure_start_menu

  # New sections: productivity + compatibility + utilities
  install_office_suite
  install_compatibility_tools
  install_windows_utilities

  log "Setup complete!"
  log "Log out and back in (or restart GNOME Shell) for the desktop changes."
  log "Launch 'Bottles' to run Windows .exe apps graphically."
  log "To revert desktop settings later: $0 --restore"
}

main "$@"
