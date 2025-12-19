#!/usr/bin/env bash
set -e

# -----------------------------
# Arch + KDE Dotfiles Installer
# -----------------------------
# Author: Raunak Dubey
# -----------------------------

# -----------------------------
# Colors
# -----------------------------
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# -----------------------------
# Paths
# -----------------------------
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$BASE_DIR/.." && pwd)"

# -----------------------------
# Helpers
# -----------------------------
backup_and_symlink() {
    local src="$1"
    local dst="$2"

    if [ -f "$dst" ] || [ -L "$dst" ]; then
        local backup="${dst}.backup.$(date +%Y%m%d%H%M%S)"
        echo -e "${YELLOW}Backing up $dst → $backup${NC}"
        mv "$dst" "$backup"
    fi

    ln -sf "$src" "$dst"
    echo -e "${GREEN}Linked $src → $dst${NC}"
}

require_sudo() {
    if ! sudo -v; then
        echo "Sudo access is required. Aborting."
        exit 1
    fi
}

# -----------------------------
# Core Apps
# -----------------------------
install_core_apps() {
    require_sudo

    echo -e "${GREEN}Installing core system packages...${NC}"
    sudo pacman -S --needed \
        git base-devel curl wget zsh networkmanager

    if ! systemctl is-active --quiet NetworkManager; then
        sudo systemctl enable --now NetworkManager
    fi

    if ! command -v yay &>/dev/null; then
        echo -e "${GREEN}Installing yay (AUR helper)...${NC}"
        tmpdir="$(mktemp -d)"
        git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
        pushd "$tmpdir/yay"
        makepkg -si
        popd
        rm -rf "$tmpdir"
    else
        echo -e "${GREEN}yay already installed.${NC}"
    fi

    echo -e "${GREEN}Installing user applications...${NC}"
    yay -S --needed brave-bin visual-studio-code-bin kitty starship
}

# -----------------------------
# KDE Assets
# -----------------------------
install_kde_assets() {
    echo -e "${GREEN}Installing KDE theme assets...${NC}"

    COLOR_DIR="$HOME/.local/share/color-schemes"
    PLASMA_DIR="$HOME/.local/share/plasma/desktoptheme"
    AURORAE_DIR="$HOME/.local/share/aurorae/themes"

    mkdir -p "$COLOR_DIR" "$PLASMA_DIR" "$AURORAE_DIR"

    if ls "$BASE_DIR/colors/"*.colors &>/dev/null; then
        cp "$BASE_DIR/colors/"*.colors "$COLOR_DIR/"
        echo -e "${GREEN}Color schemes installed.${NC}"
    else
        echo -e "${YELLOW}No color schemes found, skipping.${NC}"
    fi

    if [ -f "$BASE_DIR/plasma/Sweet-Plasma.tar.gz" ]; then
        tar -xzf "$BASE_DIR/plasma/Sweet-Plasma.tar.gz" -C "$PLASMA_DIR/"
        echo -e "${GREEN}Plasma theme installed.${NC}"
    else
        echo -e "${YELLOW}Plasma theme archive missing, skipping.${NC}"
    fi

    if [ -f "$BASE_DIR/aurorae/MacVentura-Dark.tar.gz" ]; then
        tar -xzf "$BASE_DIR/aurorae/MacVentura-Dark.tar.gz" -C "$AURORAE_DIR/"
        echo -e "${GREEN}Window decoration installed.${NC}"
    else
        echo -e "${YELLOW}Window decoration archive missing, skipping.${NC}"
    fi
}

# -----------------------------
# Main
# -----------------------------
echo -e "${GREEN}Starting dotfiles installation...${NC}"

echo -e "${GREEN}Linking shell dotfiles...${NC}"
backup_and_symlink "$DOTFILES_DIR/shell/.zshrc" "$HOME/.zshrc"
backup_and_symlink "$DOTFILES_DIR/shell/.bashrc" "$HOME/.bashrc"

install_kde_assets

read -rp "Install core applications (yay, VS Code, Brave, Kitty)? [y/N]: " RESP
if [[ "${RESP,,}" == "y" ]]; then
    install_core_apps
else
    echo -e "${YELLOW}Skipping core applications.${NC}"
fi

echo ""
echo "======================================="
echo " Installation complete 🎉"
echo " Log out & log back in to apply shell"
echo " Apply KDE themes via System Settings"
echo "======================================="
