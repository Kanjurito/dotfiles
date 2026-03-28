#!/bin/bash
WALLPAPER_DIR="~/Images/wallpaper"
THUMB_DIR="$HOME/.cache/wallpaper-thumbs"
INDEX_FILE="$THUMB_DIR/index.tsv"
THUMB_SIZE="800x450"

mkdir -p "$THUMB_DIR"

# ── Rebuild index only if wallpaper dir is newer than index ──
rebuild_index() {
    local tmp="$INDEX_FILE.tmp"
    : > "$tmp"
    while IFS= read -r -d '' FILE; do
        EXT="${FILE##*.}"
        EXT="${EXT,,}"
        HASH=$(printf '%s' "$FILE" | md5sum | cut -d' ' -f1)
        THUMB="$THUMB_DIR/${HASH}.png"
        printf '%s\t%s\t%s\n' "$FILE" "$THUMB" "$EXT" >> "$tmp"
    done < <(find "$WALLPAPER_DIR" -type f \
        \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \
           -o -iname "*.webp" -o -iname "*.gif" \
           -o -iname "*.mp4" -o -iname "*.mkv" \
           -o -iname "*.webm" -o -iname "*.mov" \
        \) -print0 | sort -z)
    mv "$tmp" "$INDEX_FILE"
}

# Rebuild if index missing or wallpaper dir modified more recently
if [[ ! -f "$INDEX_FILE" ]] || [[ "$WALLPAPER_DIR" -nt "$INDEX_FILE" ]]; then
    rebuild_index
fi

# ── Generate missing thumbs in background ────────────────────
generate_thumbs_bg() {
    while IFS=$'\t' read -r FILE THUMB EXT; do
        [[ -f "$THUMB" ]] && continue
        if [[ "$EXT" == "mp4" || "$EXT" == "mkv" || "$EXT" == "webm" || "$EXT" == "mov" ]]; then
            ffmpeg -ss 5 -i "$FILE" -vframes 1 \
                   -vf "scale=${THUMB_SIZE}:force_original_aspect_ratio=increase,crop=${THUMB_SIZE}" \
                   -y "$THUMB" &>/dev/null \
            || ffmpeg -i "$FILE" -vframes 1 -vf "scale=${THUMB_SIZE}" -y "$THUMB" &>/dev/null
        else
            convert "$FILE" -thumbnail "${THUMB_SIZE}^" \
                    -gravity center -extent "$THUMB_SIZE" \
                    "$THUMB" &>/dev/null
        fi
    done < "$INDEX_FILE"
}
generate_thumbs_bg &
BG_PID=$!

# ── Build rofi input instantly from index (no md5 recompute) ─
ROFI_INPUT=""
mapfile -t INDEXED < "$INDEX_FILE"

if [[ ${#INDEXED[@]} -eq 0 ]]; then
    notify-send "Wallpaper Picker" "No wallpapers found in $WALLPAPER_DIR"
    kill $BG_PID 2>/dev/null
    exit 1
fi

FILES=()
for LINE in "${INDEXED[@]}"; do
    IFS=$'\t' read -r FILE THUMB EXT <<< "$LINE"
    FILES+=("$FILE")
    ROFI_INPUT+=" \0icon\x1f${THUMB}\n"
done

# ── Launch rofi immediately ───────────────────────────────────
CHOSEN=$(printf "%b" "$ROFI_INPUT" | rofi \
    -dmenu \
    -p "" \
    -theme ~/.config/rofi/wallpaper-picker.rasi \
    -show-icons \
    -no-fixed-num-lines \
    -i \
    -format i \
    2>/dev/null)

kill $BG_PID 2>/dev/null
wait $BG_PID 2>/dev/null

[[ -z "$CHOSEN" ]] && exit 0
SELECTED_FILE="${FILES[$CHOSEN]}"
[[ -z "$SELECTED_FILE" ]] && exit 0

EXT="${SELECTED_FILE##*.}"
EXT="${EXT,,}"

wallust run "$SELECTED_FILE"

if [[ "$EXT" == "mp4" || "$EXT" == "mkv" || "$EXT" == "webm" || "$EXT" == "mov" ]]; then
    pkill mpvpaper 2>/dev/null
    mpvpaper -o "--loop-file=inf --no-audio --hwdec=auto --video-unscaled=no --panscan=1.0" "*" "$SELECTED_FILE" &
else
    pkill mpvpaper 2>/dev/null
    awww img "$SELECTED_FILE" --transition-type outer --transition-step 30
fi

HASH=$(printf '%s' "$SELECTED_FILE" | md5sum | cut -d' ' -f1)
notify-send "Wallpaper" "$(basename "$SELECTED_FILE")" --icon "$THUMB_DIR/${HASH}.png"
