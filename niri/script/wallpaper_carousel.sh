#!/bin/bash

# Dossier des images (bien mis entre guillemets à cause des espaces)
WALLPAPER_DIR="/home/alterra/Images/wallpaper"

# Temps entre chaque image (en secondes) - ici 300s = 5 minutes
INTERVAL=300

while true; do
    # On choisit une image au hasard
    IMAGE=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)
    
    # On l'applique avec swww (avec un effet de transition sympa)
    swww img "$IMAGE" --transition-type outer --transition-step 30
    
    sleep $INTERVAL
done
