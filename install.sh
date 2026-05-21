#!/usr/bin/env bash
set -euo pipefail

REPO="https://raw.githubusercontent.com/koko84749/prayer-times/main"
CONFIG_DIR="$HOME/.config/prayer-times"
DATA_DIR="$HOME/.local/share/prayer-times"
ATHAN_DIR="$DATA_DIR/athans"

echo "📦 Installing Prayer Times Daemon..."
mkdir -p "$CONFIG_DIR" "$ATHAN_DIR"

# Download core files
for f in daemon.py config.json status.sh select-athan.sh prayer-times.sh dunstrc; do
    echo "  Downloading $f..."
    curl -sL "$REPO/$f" -o "$CONFIG_DIR/$f"
done

chmod +x "$CONFIG_DIR/daemon.py" "$CONFIG_DIR/status.sh" "$CONFIG_DIR/select-athan.sh" "$CONFIG_DIR/prayer-times.sh"

# Download athan files
echo "📥 Downloading Athan audio files..."
ATHANS=(
    "adhan-madani-1|Adhan_Al_Haram_Al_Madani_-_Al_Madinah_1_(أذان_الحرم_المدني_-_المدينة_المنورة).mp3"
    "adhan-madani-2|Adhan_Al_Haram_Al_Madani_-_Al_Madinah_2_(أذان_الحرم_المدني_-_المدينة_المنورة).mp3"
    "adhan-fajr-madani|Adhan_Fajr_Al_Haram_Al_Madani_(أذان_الفجر_الحرم_المدني).mp3"
    "adhan-makkah-ali-mala|Ali_Ibn_Ahmad_Mala_1_-_Al_Haram_Al_Maki_(علي_بن_أحمد_ملا_-_الحرم_المكي).mp3"
    "adhan-fajr-makkah|Adhan_Fajr_Al_Haram_Al_Maki_(أذان_الفجر_الحرم_المكي).mp3"
    "adhan-alafasy|Mishary_Rashid_Alafasy_1_-_Kuwait_(مشاري_راشد_العفاسي_-_الكويت).mp3"
)

for entry in "${ATHANS[@]}"; do
    local_name="${entry%%|*}"
    remote_name="${entry##*|}"
    echo "  Downloading $local_name..."
    curl -sL "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/$remote_name" \
        -o "$ATHAN_DIR/$local_name.mp3" &
done
wait

# Install dunst config
if [ -f "$HOME/.config/dunst/dunstrc" ] && [ ! -f "$HOME/.config/dunst/dunstrc.bak" ]; then
    cp "$HOME/.config/dunst/dunstrc" "$HOME/.config/dunst/dunstrc.bak"
fi
mkdir -p "$HOME/.config/dunst"
cp "$CONFIG_DIR/dunstrc" "$HOME/.config/dunst/dunstrc"

echo ""
echo "✅ Installation complete!"
echo ""
echo "🔧 To enable autostart, add to your Hyprland config:"
echo "    exec-once = dunst &"
echo "    exec-once = $HOME/.config/prayer-times/prayer-times.sh start"
echo ""
echo "📋 Commands:"
echo "    prayer-times.sh start    - Start the daemon"
echo "    prayer-times.sh stop     - Stop the daemon"
echo "    prayer-times.sh test     - Test API & show today's times"
echo "    prayer-times.sh select   - Choose athan via rofi"
echo "    prayer-times.sh status   - Show next prayer (JSON)"
echo ""
echo "🕌 May your prayers be accepted! 🤲"
