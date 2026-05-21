#!/usr/bin/env bash
ATHAN_DIR="$HOME/.local/share/prayer-times/athans"
CONFIG="$HOME/.config/prayer-times/config.json"

FILE=$(rofi -dmenu -p "📁 Path to MP3 file (or drag & drop)" 2>/dev/null)
[ -z "$FILE" ] && exit 0

FILE="${FILE#file://}"
FILE="${FILE#\'}"
FILE="${FILE%\'}"

if [ ! -f "$FILE" ]; then
    notify-send -a prayer-times -u critical -t 5000 "Error" "File not found: $FILE"
    exit 1
fi

case "$FILE" in
    *.mp3|*.MP3|*.wav|*.WAV|*.ogg|*.OGG) ;;
    *)
        notify-send -a prayer-times -u critical -t 5000 "Error" "Not an audio file (.mp3, .wav, .ogg)"
        exit 1
        ;;
esac

NAME=$(basename "$FILE" | sed 's/\.[^.]*$//')
LABEL=$(rofi -dmenu -p "🎵 Name this Athan" -filter "$NAME" 2>/dev/null)
[ -z "$LABEL" ] && LABEL="$NAME"

cp "$FILE" "$ATHAN_DIR/$LABEL.mp3"
KEY=$(echo "$LABEL" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9-]//g')

jq --arg k "$KEY" --arg f "$LABEL.mp3" '.athan_files[$k] = $f' "$CONFIG" > /tmp/pc.json && mv /tmp/pc.json "$CONFIG"

notify-send -a prayer-times -u normal -t 5000 "✅ Athan Added" "Custom athan '$LABEL' added\nRestart daemon to use it"
