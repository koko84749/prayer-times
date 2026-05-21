#!/usr/bin/env bash
# Rofi-based athan selector
CONFIG="$HOME/.config/prayer-times/config.json"
ATHAN_FILES=$(jq -r '.athan_files | to_entries[] | "\(.key)"' "$CONFIG")
CURRENT=$(jq -r '.selected_athan' "$CONFIG")

declare -A LABELS
LABELS["madani-1"]="🕋 Madani Athan 1 (Al-Masjid an-Nabawi)"
LABELS["madani-2"]="🕋 Madani Athan 2 (Al-Masjid an-Nabawi)"
LABELS["fajr-madani"]="🌅 Fajr Madani (Al-Masjid an-Nabawi)"
LABELS["makkah-ali-mala"]="🕋 Makkah - Ali Ibn Ahmad Mala"
LABELS["fajr-makkah"]="🌅 Fajr Makkah (Al-Haram Al-Maki)"
LABELS["alafasy"]="🎤 Mishary Alafasy"

Fajr_LABELS["madani-1"]="🕋 Madani Athan 1 (Al-Masjid an-Nabawi)"
Fajr_LABELS["madani-2"]="🕋 Madani Athan 2 (Al-Masjid an-Nabawi)"
Fajr_LABELS["fajr-madani"]="🌅 Fajr Madani (Al-Masjid an-Nabawi)"
Fajr_LABELS["makkah-ali-mala"]="🕋 Makkah - Ali Ibn Ahmad Mala"
Fajr_LABELS["fajr-makkah"]="🌅 Fajr Makkah (Al-Haram Al-Maki)"
Fajr_LABELS["alafasy"]="🎤 Mishary Alafasy"

CHOICE=$(printf "%s\n" "${LABELS[@]}" | rofi -dmenu -p "Select Athan" -theme "$HOME/.config/rofi/config.rasi" 2>/dev/null)

[ -z "$CHOICE" ] && exit 0

for key in "${!LABELS[@]}"; do
    if [ "${LABELS[$key]}" = "$CHOICE" ]; then
        jq --arg k "$key" '.selected_athan = $k' "$CONFIG" > /tmp/prayer-config.json && mv /tmp/prayer-config.json "$CONFIG"
        notify-send -a prayer-times -u normal -t 3000 "Athan Changed" "Selected: ${CHOICE#* }"
        break
    fi
done
