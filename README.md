# 🜸 Niri Dotfiles — Complete Wayland Setup

Personal configuration for **Niri**, **Waybar**, **Fastfetch**, **Eww**, and soon **Alacritty** + **Quickshell**.  
This repository contains everything needed to reproduce my lightweight, fast, and cohesive Wayland environment.

---

## 📸 Screenshots

### 🧊 Fastfetch
<img width="1919" height="1079" alt="fastfetch screenshot" src="https://github.com/user-attachments/assets/8b10eece-c955-4fd9-9aa1-30c45bf9956f" />

### 🔍 Rofi (custom theme)
<img width="1910" height="1078" alt="rofi screenshot" src="https://github.com/user-attachments/assets/e768718c-f2cd-4331-bfe9-40a6d00f61dc" />

### ⚡ Eww Powermenu
<img width="1919" height="1080" alt="eww powermenu screenshot" src="https://github.com/user-attachments/assets/3d5d1c2b-7178-4420-967e-9581a5b3dc57" />

---

## 📂 Repository Structure

| Component | Description |
|----------|-------------|
| **niri/** | Main WM configuration + scripts |
| **niri/scripts/wallpaper_carrousel** | Automatic wallpaper rotation script |
| **waybar/** | Custom Waybar configuration |
| **fastfetch/** | Fastfetch configuration |
| **eww/** | Widgets (powermenu, modules, etc.) |
| **alacritty/** *(coming soon)* | Theme + keybinds |
| **quickshell/** *(coming soon)* | Advanced widgets |

---

## ⚙️ Installation

Clone the repository:

```bash
git clone https://github.com/Kanjurito/dotfiles.git
cd ~/dotfiles
```
🎨 Important: Wallpaper Carousel Configuration

Inside:
Code

niri/scripts/wallpaper_carrousel

You must edit the following variable:
```bash

WALLPAPER_DIR="~/images/wallpaper"
```

➡️ Replace it with your own wallpaper directory, otherwise the script will not find any images.

Example:
``` bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
```
🧩 Recommended Dependencies

    Niri

    Waybar

    Eww

    Fastfetch

    Rofi

    Swww (for wallpapers)

    Nerd Fonts

    Alacritty (planned)
.
