#!/usr/bin/env python3
"""
Prayer Times Daemon - Islamic prayer times with Athan notifications.
Auto-detects location via IP, falls back to config.
Plays Madani/Makkah/etc athan at prayer times via dunst + mpv.
"""
import json
import os
import subprocess
import time
from datetime import datetime, timedelta
from pathlib import Path

import requests

CONFIG_PATH = Path.home() / ".config/prayer-times/config.json"
CACHE_PATH = Path.home() / ".local/share/prayer-times/timings.json"
LOCATION_CACHE = Path.home() / ".local/share/prayer-times/location.json"
ATHAN_DIR = Path.home() / ".local/share/prayer-times/athans"
CACHE_PATH.parent.mkdir(parents=True, exist_ok=True)

PRAYER_ORDER = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"]


def load_config():
    with open(CONFIG_PATH) as f:
        return json.load(f)


def get_today_date():
    return datetime.now().strftime("%d-%m-%Y")


def detect_location():
    try:
        resp = requests.get("https://ipinfo.io/json", timeout=10)
        resp.raise_for_status()
        data = resp.json()
        loc = {
            "city": data.get("city", "Cairo"),
            "country": data.get("country", "Egypt"),
        }
        LOCATION_CACHE.write_text(json.dumps(loc))
        return loc
    except Exception:
        if LOCATION_CACHE.exists():
            return json.loads(LOCATION_CACHE.read_text())
        return None


def fetch_prayer_times(config):
    date = get_today_date()
    loc = None
    if config.get("auto_detect", True):
        loc = detect_location()
    city = loc["city"] if loc else config["city"]
    country = loc["country"] if loc else config["country"]

    url = (
        f"https://api.aladhan.com/v1/timingsByCity"
        f"?city={city}&country={country}"
        f"&method={config['method']}&date={date}"
    )
    resp = requests.get(url, timeout=15)
    resp.raise_for_status()
    data = resp.json()["data"]["timings"]
    out = {"timings": data, "city": city, "country": country}
    CACHE_PATH.write_text(json.dumps(out, indent=2))
    return data


def load_cached_times():
    if CACHE_PATH.exists():
        data = json.loads(CACHE_PATH.read_text())
        if isinstance(data, dict) and "timings" in data:
            return data["timings"]
        return data
    return None


def get_times(config):
    try:
        return fetch_prayer_times(config)
    except Exception:
        cached = load_cached_times()
        if cached:
            return cached
        raise


def parse_time(t_str):
    now = datetime.now()
    t = datetime.strptime(t_str.strip(), "%H:%M")
    return now.replace(hour=t.hour, minute=t.minute, second=0)


def find_next_prayer(timings):
    now = datetime.now()
    next_name = None
    next_time = None

    for name in PRAYER_ORDER:
        t = parse_time(timings[name])
        if t > now:
            next_name = name
            next_time = t
            break

    if not next_name:
        t = parse_time(timings["Fajr"]) + timedelta(days=1)
        next_name = "Fajr"
        next_time = t

    return next_name, next_time


def get_athan_path(config, prayer_name):
    selected = config.get("selected_athan", "madani-1")
    is_fajr = prayer_name == "Fajr"
    use_diff = config.get("use_different_fajr", True)

    if is_fajr and use_diff:
        key = config.get("selected_fajr_athan", "fajr-madani")
    else:
        key = selected

    filename = config["athan_files"].get(key)
    if not filename:
        filename = list(config["athan_files"].values())[0]
    return ATHAN_DIR / filename


def play_athan(config, prayer_name):
    path = get_athan_path(config, prayer_name)
    vol = config.get("volume", 80)

    if path.exists():
        subprocess.Popen(
            ["mpv", f"--volume={vol}", "--no-video", "--loop=2", "--really-quiet", str(path)],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    else:
        subprocess.Popen(
            ["mpv", f"--volume={vol}", "--no-video", "--loop=2", "--really-quiet", str(path)],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )


def send_notification(prayer_name, timings):
    arabic_names = {"Fajr": "الفجر", "Dhuhr": "الظهر", "Asr": "العصر", "Maghrib": "المغرب", "Isha": "العشاء"}
    ar = arabic_names.get(prayer_name, prayer_name)
    t = timings[prayer_name]

    subprocess.run(
        [
            "notify-send",
            "-a", "prayer-times",
            "-u", "critical",
            "-t", "0",
            "-h", f"string:x-dunst-stack-tag:prayer-{prayer_name}",
            f"🕌 {prayer_name} ({ar})",
            f"Time: {t}\nالصلاة خير من النوم" if prayer_name == "Fajr" else f"حان وقت صلاة {ar}",
        ]
    )


def send_next_prayer_notif(next_name, next_time, timings):
    delta = next_time - datetime.now()
    mins = int(delta.total_seconds() // 60)
    t_str = timings[next_name]
    subprocess.run(
        [
            "notify-send",
            "-a", "prayer-times",
            "-u", "normal",
            "-t", "5000",
            "⏳ Next Prayer",
            f"{next_name} at {t_str} (in {mins} min)",
        ]
    )


def main():
    config = load_config()

    timings = get_times(config)
    last_date = get_today_date()

    last_triggered = {p: None for p in PRAYER_ORDER}

    is_first_run = True

    while True:
        now = datetime.now()
        today = get_today_date()

        if today != last_date:
            try:
                timings = fetch_prayer_times(config)
                last_date = today
            except Exception:
                timings = load_cached_times()
                if not timings:
                    time.sleep(60)
                    continue

        next_name, next_time = find_next_prayer(timings)

        for prayer in PRAYER_ORDER:
            t = parse_time(timings[prayer])
            day_key = today + "-" + prayer

            diff_sec = abs((now - t).total_seconds())
            if diff_sec < 90 and last_triggered.get(prayer) != day_key:
                play_athan(config, prayer)
                send_notification(prayer, timings)
                last_triggered[prayer] = day_key

        if is_first_run:
            send_next_prayer_notif(next_name, next_time, timings)
            is_first_run = False

        time.sleep(30)


if __name__ == "__main__":
    main()
