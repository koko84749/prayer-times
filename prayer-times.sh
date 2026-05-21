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
*)
    echo "Usage: $0 {status|select|start|stop|restart|test}"
    exit 1
    ;;
esac
