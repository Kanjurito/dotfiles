#!/bin/bash

# --- CONFIGURATION ---
# IMPORTANT: Replace the path below with your own wallpaper folder!
WALLPAPER_DIR="/home/alterra/Images/wallpaper"
# Time between wallpaper changes (in seconds)
INTERVAL=120

while true; do
    # Pick a random file from the directory
    FILE=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

    # Extract extension and convert to lowercase for checking
    EXT="${FILE##*.}"
    EXT=$(echo "$EXT" | tr '[:upper:]' '[:lower:]')

    # Update system colors based on the new wallpaper using wallust
    wallust run "$FILE"

    # Check if the file is a video
    if [[ "$EXT" == "mp4" || "$EXT" == "mkv" || "$EXT" == "webm" || "$EXT" == "mov" ]]; then
        # Kill any existing video wallpaper process
        pkill mpvpaper

        # Start video wallpaper on all monitors (*) with optimized settings
        mpvpaper -o "--loop-file=inf --no-audio --hwdec=auto --video-unscaled=no --panscan=1.0" "*" "$FILE" &

    else
        # Kill video process if switching back to a static image
        pkill mpvpaper

        # Set static wallpaper with a smooth transition using swww
        swww img "$FILE" --transition-type outer --transition-step 30
    fi

    # Wait before the next rotation
    sleep $INTERVAL
done
