#!/usr/bin/env bash
CONFIG="$HOME/.config/prayer-times/config.json"
CURRENT_CITY=$(jq -r '.city' "$CONFIG")
CURRENT_COUNTRY=$(jq -r '.country' "$CONFIG")

CHOICE=$(printf "Auto-detect (IP)\nManual: %s, %s\nCairo, Egypt\nMecca, Saudi Arabia\nMedina, Saudi Arabia\nIstanbul, Turkey\nKuala Lumpur, Malaysia\nJakarta, Indonesia\nLondon, United Kingdom\nNew York, United States\nDubai, United Arab Emirates\nRiyadh, Saudi Arabia\nAmman, Jordan\nKuwait City, Kuwait\nDoha, Qatar\nManama, Bahrain\nMuscat, Oman\nAlgiers, Algeria\nRabat, Morocco\nTunis, Tunisia\nKhartoum, Sudan\nBaghdad, Iraq\nTehran, Iran\nIslamabad, Pakistan\nDhaka, Bangladesh\nKabul, Afghanistan\nOther..." | rofi -dmenu -p "📍 Location" 2>/dev/null)

[ -z "$CHOICE" ] && exit 0

if [ "$CHOICE" = "Auto-detect (IP)" ]; then
    jq '.auto_detect = true' "$CONFIG" > /tmp/prayer-config.json && mv /tmp/prayer-config.json "$CONFIG"
    notify-send -a prayer-times -u normal -t 3000 "Location" "Auto-detect enabled"
    $HOME/.config/hypr/Scripts/prayer-times.sh restart
    exit 0
fi

if [ "$CHOICE" = "Other..." ]; then
    CITY=$(rofi -dmenu -p "City" 2>/dev/null)
    [ -z "$CITY" ] && exit 0
    COUNTRY=$(rofi -dmenu -p "Country" 2>/dev/null)
    [ -z "$COUNTRY" ] && exit 0
    jq --arg c "$CITY" --arg co "$COUNTRY" '.auto_detect = false | .city = $c | .country = $co' "$CONFIG" > /tmp/prayer-config.json && mv /tmp/prayer-config.json "$CONFIG"
    notify-send -a prayer-times -u normal -t 3000 "Location" "$CITY, $COUNTRY"
    $HOME/.config/hypr/Scripts/prayer-times.sh restart
    exit 0
fi

if [ "$CHOICE" != "$CURRENT_CITY, $CURRENT_COUNTRY" ]; then
    CITY="${CHOICE%%, *}"
    COUNTRY="${CHOICE#*, }"
    jq --arg c "$CITY" --arg co "$COUNTRY" '.auto_detect = false | .city = $c | .country = $co' "$CONFIG" > /tmp/prayer-config.json && mv /tmp/prayer-config.json "$CONFIG"
    notify-send -a prayer-times -u normal -t 3000 "Location" "$CITY, $COUNTRY"
    $HOME/.config/hypr/Scripts/prayer-times.sh restart
fi
