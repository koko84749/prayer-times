# 🕌 Prayer Times Daemon

Islamic prayer times daemon for **Linux (Hyprland/Wayland)** with Athan notifications. Auto-detects your location, fetches accurate times from [Aladhan API](https://aladhan.com), and plays beautiful Athan (Adhan) audio at prayer time.

## ✨ Features

- 🔍 **Auto-detect location** via IP (or set manually)
- 🕋 **6 Athan choices** — Madani (Al-Masjid an-Nabawi), Makkah (Al-Haram Al-Maki), Mishary Alafasy
- 🌅 **Separate Fajr Athan** option
- 🔔 **Desktop notifications** via Dunst with prayer info
- 🔊 **Athan playback** via mpv at each prayer time
- 📊 **Status output** (JSON) for waybar/polybar/eww widgets
- 🎵 **Rofi selector** to change athan on the fly
- 📡 **Offline cache** — works without internet after first fetch
- ⚡ **Lightweight** — Python daemon using 30s poll interval

## 📥 Quick Install

```bash
curl -sL https://raw.githubusercontent.com/koko84749/prayer-times/main/install.sh | bash
```

### Dependencies

```bash
# Arch Linux
sudo pacman -S python python-requests mpv dunst jq rofi

# Debian/Ubuntu
sudo apt install python3 python3-requests mpv dunst jq rofi
```

## 🔧 Usage

```
prayer-times.sh start    # Start the daemon
prayer-times.sh stop     # Stop the daemon
prayer-times.sh restart  # Restart the daemon
prayer-times.sh test     # Test API & show today's times
prayer-times.sh select   # Choose athan via rofi menu
prayer-times.sh status   # Show next prayer (JSON output)
```

### Hyprland Autostart

Add to your `hyprland.conf` or `startup.conf`:

```conf
exec-once = dunst &
exec-once = $HOME/.config/prayer-times/prayer-times.sh start
```

### Keyboard Shortcuts

Add to `keybinds.conf`:

```conf
bind = $mainMod CTRL, P, exec, $HOME/.config/prayer-times/prayer-times.sh status
bind = $mainMod CTRL, A, exec, $HOME/.config/prayer-times/prayer-times.sh select
```

## ⚙️ Configuration

Edit `~/.config/prayer-times/config.json`:

| Key | Default | Description |
|-----|---------|-------------|
| `auto_detect` | `true` | Auto-detect city/country via IP |
| `city` | `Cairo` | Fallback city |
| `country` | `Egypt` | Fallback country |
| `method` | `5` | Calculation method (5=Egyptian, 3=MWL, 4=Umm Al-Qura) |
| `selected_athan` | `madani-1` | Default Athan choice |
| `selected_fajr_athan` | `fajr-madani` | Separate Athan for Fajr |
| `use_different_fajr` | `true` | Enable separate Fajr Athan |
| `volume` | `80` | mpv volume (0-100) |

### Calculation Methods

| ID | Method |
|----|--------|
| 1 | University of Islamic Sciences, Karachi |
| 2 | Islamic Society of North America (ISNA) |
| 3 | Muslim World League |
| 4 | Umm Al-Qura, Makkah |
| 5 | **Egyptian General Authority of Survey** (default) |
| 7 | Institute of Geophysics, Tehran |
| 8 | Gulf Region |
| 9 | Kuwait |
| 10 | Qatar |

## 🎵 Available Athans

| Key | Description | Source |
|-----|-------------|--------|
| `madani-1` | Madani Athan 1 — Al-Masjid an-Nabawi | [Kiwifu/adhan-mp3](https://github.com/Kiwifu/adhan-mp3) |
| `madani-2` | Madani Athan 2 — Al-Masjid an-Nabawi | [Kiwifu/adhan-mp3](https://github.com/Kiwifu/adhan-mp3) |
| `fajr-madani` | Fajr Athan — Al-Masjid an-Nabawi | [Kiwifu/adhan-mp3](https://github.com/Kiwifu/adhan-mp3) |
| `makkah-ali-mala` | Makkah — Ali Ibn Ahmad Mala | [Kiwifu/adhan-mp3](https://github.com/Kiwifu/adhan-mp3) |
| `fajr-makkah` | Fajr Athan — Al-Haram Al-Maki | [Kiwifu/adhan-mp3](https://github.com/Kiwifu/adhan-mp3) |
| `alafasy` | Mishary Rashid Alafasy | [Kiwifu/adhan-mp3](https://github.com/Kiwifu/adhan-mp3) |

## 🗺️ Language Breakdown

- **Python** — 90% — Core daemon, API fetching, time logic, notifications
- **Bash** — 8% — Installer, status script, athan selector, launcher
- **JSON** — 1% — Configuration
- **Config (dunst)** — 1% — Notification theme

## 📚 Sources & Credits

| Resource | Usage |
|----------|-------|
| [Aladhan API](https://aladhan.com) | Prayer times data (free, no API key needed) |
| [ipinfo.io](https://ipinfo.io) | IP-based location auto-detection |
| [Kiwifu/adhan-mp3](https://github.com/Kiwifu/adhan-mp3) | 200+ Adhan MP3 recordings (CC-friendly) |
| [Dunst](https://dunst-project.org) | Notification daemon |
| [mpv](https://mpv.io) | Audio playback |
| [Rofi](https://github.com/davatorium/rofi) | Athan selection menu |
| [jq](https://jqlang.github.io/jq/) | JSON parsing in shell |

## 📜 License

MIT
