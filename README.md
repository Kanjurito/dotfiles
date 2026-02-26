# 🜸 Niri Dotfiles — Complete Wayland Setup

Personal configuration for **Niri**, **Waybar**, **Fastfetch**, **Eww**, **Alacritty** and **Quickshell**.  
This repository contains everything needed to reproduce my lightweight, fast, and cohesive Wayland environment.

---

## 📸 Screenshots

### 🧊 Fastfetch
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/948a8864-06e0-4a74-be1f-0ef302e54758" />

### 🔍 Rofi (custom theme)
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/c70b4ec0-b94f-454d-a7ab-176733e89556" />


### ⚡ Eww Powermenu
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/794fcbf0-b4a8-4a68-bda0-41637c73e83c" />


### 🎵 Music, Home Menu, Clock & Waifu Widget
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/1c12d35c-c95f-43f8-b5b4-6b46e28cb202" />
---

## 📂 Repository Structure

| Component | Description |
|----------|-------------|
| **niri/** | Main WM configuration + scripts |
| **niri/scripts/wallpaper_carrousel** | Automatic wallpaper rotation script |
| **waybar/** | Custom Waybar configuration |
| **fastfetch/** | Fastfetch configuration |
| **eww/** | Powermenu Widgets |
| **alacritty/** | Theme + keybinds |
| **quickshell/**  | Media player,user menu and waifu widgets |

---

## ⚙️ Installation

Clone the repository:

```bash
git clone https://github.com/Kanjurito/dotfiles.git
cd ~/dotfiles
```
copy to your .config folder
```bash
ln -sf ~/dotfiles/niri ~/.config/niri
ln -sf ~/dotfiles/waybar ~/.config/waybar
ln -sf ~/dotfiles/fastfetch ~/.config/fastfetch
ln -sf ~/dotfiles/eww ~/.config/eww
ln -sf ~/dotfiles/alacritty ~/.config/alacritty
ln -sf ~/dotfiles/quickshell ~/.config/quickshell
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
---

## ⌨️ Keybindings

A complete overview of all custom keybindings used in this Niri setup.

### 🖥️ Session & System
| Keybind | Action |
|--------|--------|
| **MOD + Shift + E** | Quit session |
| **MOD + Shift + Y** | Toggle Eww powermenu |
| **MOD + Shift + Escape** | Show hotkey overlay |
| **CTRL + ALT + Delete** | Shutdown immediately |

---

### 🚀 Applications & Scripts
| Keybind | Action |
|--------|--------|
| **MOD + A** | Launch Rofi (drun) |
| **MOD + B** | Launch Firefox |
| **MOD + E** | Launch Nautilus |
| **MOD + Shift + D** | Launch Discord (XWayland) |
| **MOD + W** | Run wallpaper carousel script |
| **MOD + Shift + W** | Launch Quickshell waifu widget |
| **MOD + Shift + R** | Restart Quickshell widgets |
| **MOD + Shift + M** | Toggle media-player widget |
| **MOD + Shift + U** | Toggle user-menu widget |
| **MOD + P** | Launch Hyprpicker |

---

### 🔊 Media & Brightness
| Keybind | Action |
|--------|--------|
| **XF86AudioRaiseVolume** | Volume up |
| **XF86AudioLowerVolume** | Volume down |
| **XF86AudioMute** | Mute audio |
| **XF86AudioMicMute** | Mute microphone |
| **XF86AudioNext** | Next track |
| **XF86AudioPrev** | Previous track |
| **XF86AudioPause / Play** | Play / Pause |
| **XF86MonBrightnessUp** | Increase brightness |
| **XF86MonBrightnessDown** | Decrease brightness |

---

### 🪟 Window Management
| Keybind | Action |
|--------|--------|
| **MOD + Q** | Close window |
| **MOD + H / L** | Focus column left / right |
| **MOD + J / K** | Focus workspace down / up |
| **MOD + CTRL + Arrows** | Focus windows/columns |
| **MOD + Arrows** | Move windows/columns |
| **MOD + Shift + H/J/K/L** | Move columns or send to workspace |
| **MOD + Shift + Home/End** | Move column to first/last |
| **MOD + Home/End** | Focus first/last column |

---

### 🖥️ Multi‑Monitor Controls
| Keybind | Action |
|--------|--------|
| **MOD + CTRL + H/J/K/L** | Focus monitor |
| **MOD + Shift + CTRL + H/J/K/L** | Move window to monitor |
| **MOD + Shift + Arrows** | Move column to monitor |

---

### 🗂️ Workspace Navigation
| Keybind | Action |
|--------|--------|
| **MOD + 1–9** | Switch workspace |
| **MOD + Shift + 1–9** | Move window to workspace |
| **MOD + Tab** | Previous workspace |
| **MOD + Escape** | Toggle overview |
| **MOD + Wheel Up/Down** | Switch workspace |
| **MOD + Shift + Wheel Up/Down** | Move window to workspace |

---

### 🧱 Layout & Resizing
| Keybind | Action |
|--------|--------|
| **MOD + C** | Center column |
| **MOD + CTRL + C** | Center visible columns |
| **MOD + [ / ]** | Resize column width |
| **MOD + ALT + Wheel Up/Down** | Resize window width |
| **MOD + CTRL + Wheel Up/Down** | Resize window height |
| **MOD + Minus / Equal** | Resize column width |
| **MOD + Shift + Minus / Equal** | Resize window height |

---

### 🪟 Window Modes
| Keybind | Action |
|--------|--------|
| **MOD + T** | Toggle floating |
| **MOD + F** | Fullscreen window |
| **MOD + Shift + F** | Fullscreen window (alt bind) |
| **MOD + M** | Maximize column |

---

### 📸 Screenshots
| Keybind | Action |
|--------|--------|
| **MOD + S** | Screenshot |
| **MOD + Shift + S** | Screenshot screen → save to disk |
| **MOD + CTRL + S** | Screenshot window → save to disk |

---

🧩 Recommended Dependencies

    Niri

    Waybar

    Eww

    Fastfetch

    Cava

    Rofi

    Swww (for wallpapers)

    Nerd Fonts

    Alacritty

    Quickshell
.
