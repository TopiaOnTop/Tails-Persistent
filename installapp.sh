#!/usr/bin/env bash

# Dossiers de destination
APP_DIR="$HOME/Persistent/Apps"
DESKTOP_DIR="/live/persistence/TailsData_unlocked/dotfiles/.local/share/applications"

# Vérification du stockage persistant
if [ ! -d "$HOME/Persistent" ]; then
    echo "[!] Erreur : Le stockage persistant n'est pas activé ou déverrouillé."
    exit 1
fi

mkdir -p "$APP_DIR"
mkdir -p "$DESKTOP_DIR"

echo "=== Assistant d'installation d'AppImage pour Tails OS ==="
echo ""

# Ask for mode: Download or Local
echo "1) Télécharger une AppImage via une URL"
echo "2) Utiliser un fichier AppImage déjà présent"
read -rp "Choix [1/2] : " CHOICE

if [ "$CHOICE" -eq 1 ]; then
    read -rp "Entrez l'URL de l'AppImage : " APP_URL
    read -rp "Nom du fichier final (ex: MonApp.AppImage) : " APP_FILENAME
    
    # Correction de l'extension si oubliée
    [[ "$APP_FILENAME" != *.AppImage ]] && APP_FILENAME="${APP_FILENAME}.AppImage"
    
    DEST_PATH="$APP_DIR/$APP_FILENAME"
    echo "[*] Téléchargement en cours..."
    curl -L "$APP_URL" -o "$DEST_PATH"
    
elif [ "$CHOICE" -eq 2 ]; then
    read -rp "Chemin vers votre fichier .AppImage (ex: /home/amnesia/Tor Browser/monapp.AppImage) : " LOCAL_PATH
    
    # Nettoyage des guillemets éventuels
    LOCAL_PATH="${LOCAL_PATH//\'/}"
    LOCAL_PATH="${LOCAL_PATH//\"/}"

    if [ ! -f "$LOCAL_PATH" ]; then
        echo "[!] Fichier introuvable : $LOCAL_PATH"
        exit 1
    fi
    
    APP_FILENAME=$(basename "$LOCAL_PATH")
    DEST_PATH="$APP_DIR/$APP_FILENAME"
    
    if [ "$LOCAL_PATH" != "$DEST_PATH" ]; then
        cp "$LOCAL_PATH" "$DEST_PATH"
        echo "[*] Fichier copié dans $APP_DIR"
    fi
else
    echo "[!] Choix invalide."
    exit 1
fi

# Rendre exécutable
chmod +x "$DEST_PATH"
echo "[+] Fichier rendu exécutable."

# Informations pour le raccourci .desktop
echo ""
echo "=== Configuration du raccourci dans le menu ==="
read -rp "Nom affiché dans le menu (ex: Mon Application) : " APP_NAME
read -rp "Nom du fichier .desktop (ex: monapp.desktop) : " DESKTOP_FILENAME
read -rp "Catégorie (ex: Utility, Network, Development, System) [Utility] : " APP_CAT
APP_CAT=${APP_CAT:-Utility}

[[ "$DESKTOP_FILENAME" != *.desktop ]] && DESKTOP_FILENAME="${DESKTOP_FILENAME}.desktop"
DESKTOP_FILE_PATH="$DESKTOP_DIR/$DESKTOP_FILENAME"

# Création du fichier .desktop
cat <<EOF > "$DESKTOP_FILE_PATH"
[Desktop Entry]
Version=1.0
Type=Application
Name=$APP_NAME
Exec=$DEST_PATH
Icon=exec
Terminal=false
Categories=$APP_CAT;
EOF

chmod +x "$DESKTOP_FILE_PATH"

echo ""
echo "=========================================="
echo "[✔] Installation terminée avec succès !"
echo "• AppImage stockée dans : $DEST_PATH"
echo "• Raccourci créé dans  : $DESKTOP_FILE_PATH"
echo ""
echo "Le raccourci apparaîtra dans le menu des applications au démarrage."