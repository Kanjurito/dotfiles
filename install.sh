#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

packages=(niri fuzzel xdg-desktop-portal-gtk xdg-desktop-portal-gnome kitty xwayland-satellite fastfetch cava rofi ttf-jetbrains-mono-nerd quickshell nautilus greetd greetd-tuigreet)

pkgyay=(eww swww wallust wlr-randr)

sudo pacman -Syu --noconfirm
sudo pacman -S --needed base-devel git --noconfirm

if ! command -v yay &> /dev/null; then
    _tempdir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$_tempdir/yay"
    cd "$_tempdir/yay"
    makepkg -si --noconfirm
    cd - > /dev/null
fi

yay -S --needed --noconfirm "${pkgyay[@]}"
sudo pacman -S --needed --noconfirm "${packages[@]}"

if [ ! -d "$HOME/dotfiles" ]; then
    git clone https://github.com/Kanjurito/dotfiles.git "$HOME/dotfiles"
fi
mkdir -p ~/.config
cp -rv "$HOME/dotfiles"/{cava,eww,fastfetch,kitty,niri,quickshell,wallust,waybar} ~/.config/

echo "greetd configuration..."
sudo mkdir -p /etc/greetd
cat <<EOF | sudo tee /etc/greetd/config.toml
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --remember --cmd niri"
user = "greeter"
EOF
echo "Auto-configuring Niri outputs..."

config="$HOME/.config/niri/config.kdl"


read -r -p "Installation complete,reboot (Y/n) ? : " reponse
if [[ "$reponse" == "y" || "$reponse" == "Y" ]]; then
    sudo systemctl reboot
else
    exit 1
fi
