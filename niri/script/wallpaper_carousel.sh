#!/bin/bash

WALLPAPER_DIR="/home/alterra/Images/wallpaper"
INTERVAL=120

while true; do
    FILE=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)
    EXT="${FILE##*.}"
    EXT=$(echo "$EXT" | tr '[:upper:]' '[:lower:]')

    echo "Chargement de : $FILE"

    # --- ÉTAPE WALLUST ---
    # On lance wallust sur le fichier. 
    # Si c'est une vidéo, wallust prendra une frame pour générer les couleurs.
    wallust run -n "$FILE" 
    
    # (Optionnel) Recharger la config de Niri ou de tes terminaux ici si besoin
    # niri msg action reload-config-file 

    if [[ "$EXT" == "mp4" || "$EXT" == "mkv" || "$EXT" == "webm" || "$EXT" == "mov" ]]; then
        pkill mpvpaper
        # Note : Ajuste bien tes arguments mpvpaper ici (ils semblaient coupés dans ton prompt)
        mpvpaper -o "--loop-file=inf --no-audio --hwdec=auto" "*" "$FILE" &
    else
        pkill mpvpaper
        swww img "$FILE" --transition-type outer --transition-step 30
    fi

    sleep $INTERVAL
done
