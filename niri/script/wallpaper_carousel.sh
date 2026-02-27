#!/bin/bash

# Dossier contenant tes images (jpg, png, gif) et vidéos (mp4, mkv, etc.)
WALLPAPER_DIR="/home/alterra/Images/wallpaper"

INTERVAL=120

while true; do
    FILE=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)
    
    EXT="${FILE##*.}"
    EXT=$(echo "$EXT" | tr '[:upper:]' '[:lower:]')

    echo "Chargement de : $FILE"

    if [[ "$EXT" == "mp4" || "$EXT" == "mkv" || "$EXT" == "webm" || "$EXT" == "mov" ]]; then
        pkill mpvpaper
        
        mpvpaper -o "--loop-file=inf --no-audio --hwdec=auto --video-unscaled=no --panscan=1.0" "*" "$FILE" &
        
    else
        pkill mpvpaper
        
        swww img "$FILE" --transition-type outer --transition-step 30
    fi

    sleep $INTERVAL
done
