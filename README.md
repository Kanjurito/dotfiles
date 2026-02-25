# 🜸 Niri Dotfiles — Complete Wayland Setup

Personal configuration for **Niri**, **Waybar**, **Fastfetch**, **Eww**, and soon **Alacritty** + **Quickshell**.  
This repository contains everything needed to reproduce my lightweight, fast, and cohesive Wayland environment.

---

## 📸 Screenshots

### 🧊 Fastfetch
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/948a8864-06e0-4a74-be1f-0ef302e54758" />

### 🔍 Rofi (custom theme)
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/c70b4ec0-b94f-454d-a7ab-176733e89556" />


### ⚡ Eww Powermenu
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/794fcbf0-b4a8-4a68-bda0-41637c73e83c" />


### 🎵 Music, Home Menu & Waifu Widget
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/2d9b571d-0af0-436f-aa1f-351111fab006" />


---

## 📂 Repository Structure

| Component | Description |
|----------|-------------|
| **niri/** | Main WM configuration + scripts |
| **niri/scripts/wallpaper_carrousel** | Automatic wallpaper rotation script |
| **waybar/** | Custom Waybar configuration |
| **fastfetch/** | Fastfetch configuration |
| **eww/** | Widgets (powermenu, modules, etc.) |
| **alacritty/** | Theme + keybinds |
| **quickshell/**  | media player,user menu and waifu widgets |

---

## ⚙️ Installation

Clone the repository:

```bash
git clone https://github.com/Kanjurito/dotfiles.git
cd ~/dotfiles
```
copy to your .config folder
```bash
ln -sf ~/dotfiles-niri/niri ~/.config/niri
ln -sf ~/dotfiles-niri/waybar ~/.config/waybar
ln -sf ~/dotfiles-niri/fastfetch ~/.config/fastfetch
ln -sf ~/dotfiles-niri/eww ~/.config/eww
```

🎨 Important: Wallpaper Carousel Configuration

Inside:
```bash

niri/scripts/wallpaper_carrousel
```

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
