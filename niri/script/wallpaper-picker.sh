#!/bin/bash
# ============================================================
#  wallpaper-picker.sh
#  Rofi-based wallpaper picker with thumbnail previews.
#  Works alongside your auto-rotation script — just call this
#  whenever you want to pick manually; rotation continues after.
# ============================================================

# --- CONFIGURATION ---
WALLPAPER_DIR="/home/alterra/Images/wallpaper"
THUMB_DIR="$HOME/.cache/wallpaper-thumbs"
THUMB_SIZE="400x225"   # 16:9 thumbnails
ROFI_COLS=4            # columns in the grid

mkdir -p "$THUMB_DIR"

# ── 1. Collect wallpaper files ────────────────────────────────
mapfile -t FILES < <(find "$WALLPAPER_DIR" -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png"  \
       -o -iname "*.webp" -o -iname "*.gif"                 \
       -o -iname "*.mp4"  -o -iname "*.mkv" -o -iname "*.webm" -o -iname "*.mov" \
    \) | sort)

if [[ ${#FILES[@]} -eq 0 ]]; then
    notify-send "Wallpaper Picker" "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

# ── 2. Generate thumbnails (skip if already cached) ──────────
for FILE in "${FILES[@]}"; do
    HASH=$(echo "$FILE" | md5sum | cut -d' ' -f1)
    THUMB="$THUMB_DIR/${HASH}.png"

    if [[ ! -f "$THUMB" ]]; then
        EXT="${FILE##*.}"
        EXT=$(echo "$EXT" | tr '[:upper:]' '[:lower:]')

        if [[ "$EXT" == "mp4" || "$EXT" == "mkv" || "$EXT" == "webm" || "$EXT" == "mov" ]]; then
            # Extract frame at 5s for video files
            ffmpeg -ss 5 -i "$FILE" -vframes 1 -vf "scale=${THUMB_SIZE}:force_original_aspect_ratio=increase,crop=${THUMB_SIZE}" \
                   -y "$THUMB" &>/dev/null \
            || ffmpeg -i "$FILE" -vframes 1 -vf "scale=${THUMB_SIZE}" -y "$THUMB" &>/dev/null
            # Overlay a small ▶ play badge on video thumbs
            if [[ -f "$THUMB" ]]; then
                convert "$THUMB" \
                    -fill 'rgba(0,0,0,0.55)' -draw 'circle 32,32 32,16' \
                    -fill white -font DejaVu-Sans -pointsize 22 \
                    -gravity NorthWest -annotate +20+18 '▶' \
                    "$THUMB" 2>/dev/null || true
            fi
        else
            convert "$FILE" -thumbnail "${THUMB_SIZE}^" \
                    -gravity center -extent "$THUMB_SIZE" \
                    "$THUMB" &>/dev/null
        fi
    fi
done

# ── 3. Build rofi input list  (label\0icon\x1fPATH) ──────────
ROFI_INPUT=""
for FILE in "${FILES[@]}"; do
    HASH=$(echo "$FILE" | md5sum | cut -d' ' -f1)
    THUMB="$THUMB_DIR/${HASH}.png"
    LABEL=$(basename "$FILE")
    ROFI_INPUT+="${LABEL}\0icon\x1f${THUMB}\n"
done

# ── 4. Launch rofi ───────────────────────────────────────────
CHOSEN=$(printf "%b" "$ROFI_INPUT" | rofi \
    -dmenu \
    -p "  Wallpaper" \
    -theme-str "$(cat "$HOME/.config/rofi/wallpaper-picker.rasi" 2>/dev/null || echo '')" \
    -theme ~/.config/rofi/wallpaper-picker.rasi \
    -show-icons \
    -no-fixed-num-lines \
    -i \
    -format i \
    2>/dev/null)

# rofi returns the 0-based index with -format i
[[ -z "$CHOSEN" ]] && exit 0

SELECTED_FILE="${FILES[$CHOSEN]}"
[[ -z "$SELECTED_FILE" ]] && exit 0

# ── 5. Apply the chosen wallpaper (same logic as your script) ─
EXT="${SELECTED_FILE##*.}"
EXT=$(echo "$EXT" | tr '[:upper:]' '[:lower:]')

wallust run "$SELECTED_FILE"

if [[ "$EXT" == "mp4" || "$EXT" == "mkv" || "$EXT" == "webm" || "$EXT" == "mov" ]]; then
    pkill mpvpaper 2>/dev/null
    mpvpaper -o "--loop-file=inf --no-audio --hwdec=auto --video-unscaled=no --panscan=1.0" "*" "$SELECTED_FILE" &
else
    pkill mpvpaper 2>/dev/null
    swww img "$SELECTED_FILE" --transition-type outer --transition-step 30
fi

notify-send "Wallpaper set" "$(basename "$SELECTED_FILE")" --icon "$HOME/.cache/wallpaper-thumbs/$(echo "$SELECTED_FILE" | md5sum | cut -d' ' -f1).png"
