#!/usr/bin/env bash
CACHE="$HOME/.local/share/prayer-times/timings.json"
CONFIG="$HOME/.config/prayer-times/config.json"

if [ ! -f "$CACHE" ]; then
    echo '{"text":"🌙 ?", "class":"error"}'
    exit 0
fi

CITY=$(jq -r '.city // "auto"' "$CONFIG")
SEL=$(jq -r '.selected_athan // "madani-1"' "$CONFIG")
LOCATION=$(jq -r '.city // ""' "$CACHE")

NOW_EPOCH=$(date +%s)
PRAYERS=("Fajr" "Dhuhr" "Asr" "Maghrib" "Isha")

GET_TIMING='if type=="object" and has("timings") then .timings[$p] else .[$p] end // empty'

NEXT_PRAYER=""
NEXT_TIME=""

for p in "${PRAYERS[@]}"; do
    t=$(jq -r --arg p "$p" "$GET_TIMING" "$CACHE")
    [ -z "$t" ] || [ "$t" = "null" ] && continue
    PRAYER_EPOCH=$(date -d "$t" +%s 2>/dev/null)
    [ -z "$PRAYER_EPOCH" ] && continue
    if [ "$PRAYER_EPOCH" -gt "$NOW_EPOCH" ]; then
        NEXT_PRAYER="$p"
        NEXT_TIME="$t"
        break
    fi
done

if [ -z "$NEXT_PRAYER" ]; then
    t=$(jq -r 'if type=="object" and has("timings") then .timings.Fajr else .Fajr end // empty' "$CACHE")
    if [ -n "$t" ]; then
        TOMORROW=$(date -d "tomorrow $t" +%s 2>/dev/null)
        DIFF=$((TOMORROW - NOW_EPOCH))
        H=$((DIFF / 3600))
        M=$(( (DIFF % 3600) / 60 ))
        echo "{\"text\":\"🌙 Fajr ${H}h${M}m\", \"tooltip\":\"Fajr tomorrow at $t\", \"class\":\"next-prayer\"}"
        exit 0
    fi
    echo '{"text":"🌙 ?", "class":"error"}'
    exit 0
fi

DIFF=$((PRAYER_EPOCH - NOW_EPOCH))
H=$((DIFF / 3600))
M=$(( (DIFF % 3600) / 60 ))

echo "{\"text\":\"🕌 ${NEXT_PRAYER} ${H}h${M}m\", \"tooltip\":\"${NEXT_PRAYER} at ${NEXT_TIME}\\nAthan: ${SEL}\", \"class\":\"next-prayer\"}"
