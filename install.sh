#!/usr/bin/env bash

# Exit on error, undefined variables, or pipe failures
set -euo pipefail
IFS=$'\n\t'

# --- PACKAGES LIST ---
# Core packages from official Arch repositories
packages=(
    niri fuzzel xdg-desktop-portal-gtk xdg-desktop-portal-gnome 
    kitty xwayland-satellite fastfetch cava rofi 
    ttf-jetbrains-mono-nerd quickshell nemo 
    greetd greetd-tuigreet python inotify-tools ddcutil libpulse
)

# AUR Packages (installed via yay)
pkgyay=(eww awww wallust wlr-randr hyprlock mpvpaper blueberry)

# --- SYSTEM UPDATE & BASE DEVEL ---
echo "Updating system and installing base-devel..."
sudo pacman -Syu --noconfirm
sudo pacman -S --needed base-devel git --noconfirm

# --- YAY INSTALLATION ---
# Install AUR helper if not already present
if ! command -v yay &> /dev/null; then
    echo "Installing yay (AUR helper)..."
    _tempdir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$_tempdir/yay"
    cd "$_tempdir/yay"
    makepkg -si --noconfirm
    cd - > /dev/null
fi

# --- INSTALL PACKAGES ---
echo "Installing packages..."
yay -S --needed --noconfirm "${pkgyay[@]}"
sudo pacman -S --needed --noconfirm "${packages[@]}"

# --- DOTFILES DEPLOYMENT ---
# Clone the repository if it doesn't exist
if [ ! -d "$HOME/dotfiles" ]; then
    echo "Cloning dotfiles..."
    git clone https://github.com/Kanjurito/dotfiles.git "$HOME/dotfiles"
fi

# Link or copy configuration folders to ~/.config
echo "Configuring dotfiles..."
mkdir -p ~/.config
cp -rv "$HOME/dotfiles"/{cava,eww,fastfetch,kitty,niri,rofi,swaylock,quickshell,wallust} ~/.config/

# --- GREETD SETUP ---
# Configure the login manager (tuigreet) to launch Niri
echo "Configuring greetd/tuigreet..."
sudo mkdir -p /etc/greetd
cat <<EOF | sudo tee /etc/greetd/config.toml
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --remember --cmd niri"
user = "greeter"
EOF

# --- FINALIZATION ---
config="$HOME/.config/niri/config.kdl"

read -r -p "Installation complete. Reboot now? (Y/n) : " reponse
if [[ "$reponse" == "y" || "$reponse" == "Y" ]]; then
    sudo systemctl reboot
else
    echo "Done! Please reboot manually to apply all changes."
    exit 0
fi
