#!/usr/bin/env bash
CONFIG="$HOME/.config/prayer-times/config.json"
ATHAN_DIR="$HOME/.local/share/prayer-times/athans"
CURRENT=$(jq -r '.selected_athan' "$CONFIG")

declare -A LABELS
LABELS["madani-1"]="🕋 Madani Athan 1 (Al-Masjid an-Nabawi)"
LABELS["madani-2"]="🕋 Madani Athan 2 (Al-Masjid an-Nabawi)"
LABELS["fajr-madani"]="🌅 Fajr Madani (Al-Masjid an-Nabawi)"
LABELS["makkah-ali-mala"]="🕋 Makkah - Ali Ibn Ahmad Mala"
LABELS["fajr-makkah"]="🌅 Fajr Makkah (Al-Haram Al-Maki)"
LABELS["alafasy"]="🎤 Mishary Alafasy"

for f in "$ATHAN_DIR"/*.mp3; do
    [ -f "$f" ] || continue
    BASE=$(basename "$f" .mp3)
    case "$BASE" in
        adhan-madani-1|adhan-madani-2|adhan-fajr-madani|adhan-makkah-ali-mala|adhan-fajr-makkah|adhan-alafasy) continue ;;
    esac
    LABELS["custom:$BASE"]="🎵 $BASE"
done

ADD_LABEL="➕ Add Custom Athan..."
MENU=$(printf "%s\n" "${LABELS[@]}" "$ADD_LABEL" | rofi -dmenu -p "🎵 Select Athan" 2>/dev/null)

[ -z "$MENU" ] && exit 0

if [ "$MENU" = "$ADD_LABEL" ]; then
    exec "$HOME/.config/prayer-times/add-athan.sh"
fi

for key in "${!LABELS[@]}"; do
    if [ "${LABELS[$key]}" = "$MENU" ]; then
        ATHAN_KEY="${key#custom:}"
        jq --arg k "$ATHAN_KEY" '.selected_athan = $k' "$CONFIG" > /tmp/prayer-config.json && mv /tmp/prayer-config.json "$CONFIG"
        notify-send -a prayer-times -u normal -t 3000 "Athan Changed" "Selected: ${MENU#* }"
        break
    fi
done
