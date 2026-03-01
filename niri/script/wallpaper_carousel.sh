#!/bin/bash

# Dossier contenant tes images (jpg, png, gif) et vidéos (mp4, mkv, etc.)
WALLPAPER_DIR="/home/alterra/Images/wallpaper"

# Intervalle de changement (120s = 2 minutes)
INTERVAL=120

while true; do
    # On choisit un fichier au hasard (tous types confondus)
    FILE=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)
    
    # On récupère l'extension en minuscule pour le test
    EXT="${FILE##*.}"
    EXT=$(echo "$EXT" | tr '[:upper:]' '[:lower:]')

    echo "Chargement de : $FILE"
    wallust run -n "$FILE"

    if [[ "$EXT" == "mp4" || "$EXT" == "mkv" || "$EXT" == "webm" || "$EXT" == "mov" ]]; then
        # --- CAS VIDÉO ---
        # On prépare le terrain : on arrête les autres processus de fond d'écran
        pkill mpvpaper
        # swww n'a pas besoin d'être tué, il sera simplement recouvert par mpvpaper
        
        # On lance la vidéo avec l'option panscan pour éviter les bandes noires
        mpvpaper -o "--loop-file=inf --no-audio --hwdec=auto --video-unscaled=no --panscan=1.0" "*" "$FILE" &
        
    else
        # --- CAS IMAGE (ou GIF via swww) ---
        # Si une vidéo tournait, on l'arrête pour voir l'image
        pkill mpvpaper
        
        # On applique l'image avec swww et tes transitions préférées
        swww img "$FILE" --transition-type outer --transition-step 30
    fi

    sleep $INTERVAL
done
