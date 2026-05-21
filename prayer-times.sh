#!/usr/bin/env bash

case "${1:-}" in
status)
    exec "$HOME/.config/prayer-times/status.sh"
    ;;
select)
    exec "$HOME/.config/prayer-times/select-athan.sh"
    ;;
start)
    nohup python3 "$HOME/.config/prayer-times/daemon.py" >/dev/null 2>&1 &
    notify-send -a prayer-times -u normal -t 3000 "Prayer Times" "Daemon started"
    ;;
stop)
    pkill -f "python3.*prayer-times.*daemon" 2>/dev/null
    notify-send -a prayer-times -u normal -t 3000 "Prayer Times" "Daemon stopped"
    ;;
restart)
    pkill -f "python3.*prayer-times.*daemon" 2>/dev/null
    sleep 1
    nohup python3 "$HOME/.config/prayer-times/daemon.py" >/dev/null 2>&1 &
    notify-send -a prayer-times -u normal -t 3000 "Prayer Times" "Daemon restarted"
    ;;
times)
    CACHE="$HOME/.local/share/prayer-times/timings.json"
    if [ ! -f "$CACHE" ]; then
        notify-send -a prayer-times -u critical -t 5000 "Error" "No cached times"
        exit 1
    fi
    JQ_FILTER='if type=="object" and has("timings") then .timings else . end'
    FAJR=$(jq -r "$JQ_FILTER | .Fajr" "$CACHE")
    DHUHR=$(jq -r "$JQ_FILTER | .Dhuhr" "$CACHE")
    ASR=$(jq -r "$JQ_FILTER | .Asr" "$CACHE")
    MAGHRIB=$(jq -r "$JQ_FILTER | .Maghrib" "$CACHE")
    ISHA=$(jq -r "$JQ_FILTER | .Isha" "$CACHE")
    notify-send -a prayer-times -u normal -t 10000 "🕌 Today's Prayer Times" "Fajr: $FAJR\nDhuhr: $DHUHR\nAsr: $ASR\nMaghrib: $MAGHRIB\nIsha: $ISHA"
    ;;
test)
    python3 -c "
import json, sys
from pathlib import Path
sys.path.insert(0, str(Path.home() / '.config/prayer-times'))
from daemon import fetch_prayer_times, load_config
cfg = load_config()
try:
    t = fetch_prayer_times(cfg)
    for p in ['Fajr','Dhuhr','Asr','Maghrib','Isha']:
        print(f'{p}: {t[p]}')
except Exception as e:
    print(f'Error: {e}')
"
    ;;
location)
    exec "$HOME/.config/prayer-times/set-location.sh"
    ;;
add-athan)
    exec "$HOME/.config/prayer-times/add-athan.sh"
    ;;
*)
    echo "Usage: $0 {status|select|start|stop|restart|test|times|location|add-athan}"
    exit 1
    ;;
esac
