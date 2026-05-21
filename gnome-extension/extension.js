const GLib = imports.gi.GLib;
const Gio = imports.gi.Gio;
const St = imports.gi.St;
const Main = imports.ui.main;
const PanelMenu = imports.ui.panelMenu;
const PopupMenu = imports.ui.popupMenu;
const Clutter = imports.gi.Clutter;

const CACHE_PATH = GLib.get_home_dir() + '/.local/share/prayer-times/timings.json';
const PRAYER_NAMES = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
const ARABIC_NAMES = {
    'Fajr': 'الفجر',
    'Dhuhr': 'الظهر',
    'Asr': 'العصر',
    'Maghrib': 'المغرب',
    'Isha': 'العشاء'
};

let indicator = null;

function readTimings() {
    try {
        let file = Gio.File.new_for_path(CACHE_PATH);
        if (!file.query_exists(null)) return null;
        let contents = file.load_contents(null);
        let data = JSON.parse(contents[0]);
        return data.timings || data;
    } catch (e) {
        return null;
    }
}

function parseTime(str) {
    let parts = str.trim().split(':');
    let now = new Date();
    return new Date(now.getFullYear(), now.getMonth(), now.getDate(),
        parseInt(parts[0]), parseInt(parts[1]), 0);
}

function getNextPrayer(timings) {
    let now = new Date();
    for (let name of PRAYER_NAMES) {
        if (!timings[name]) continue;
        let t = parseTime(timings[name]);
        if (t > now) return { name, time: t };
    }
    let fajr = parseTime(timings['Fajr']);
    fajr.setDate(fajr.getDate() + 1);
    return { name: 'Fajr', time: fajr };
}

function formatCountdown(ms) {
    let total = Math.floor(ms / 1000);
    let h = Math.floor(total / 3600);
    let m = Math.floor((total % 3600) / 60);
    if (h > 0) return `${h}h ${m}m`;
    return `${m}m`;
}

function getCurrentDateStr() {
    let d = new Date();
    let dd = String(d.getDate()).padStart(2, '0');
    let mm = String(d.getMonth() + 1).padStart(2, '0');
    let yyyy = d.getFullYear();
    return `${dd}-${mm}-${yyyy}`;
}

const PrayerTimesIndicator = class extends PanelMenu.Button {
    constructor() {
        super(0.0, 'Prayer Times', false);

        this._label = new St.Label({
            text: '🕌 --:--',
            y_align: Clutter.ActorAlign.CENTER,
            style_class: 'prayer-times-label'
        });
        this.add_child(this._label);

        this._buildMenu();

        this._timeout = GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 30, () => {
            this._update();
            return true;
        });

        this._update();
    }

    _buildMenu() {
        this._items = {};
        for (let name of PRAYER_NAMES) {
            let item = new PopupMenu.PopupMenuItem('', { reactive: false });
            this.menu.addMenuItem(item);
            this._items[name] = item;
        }
        this.menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());
        this._dateItem = new PopupMenu.PopupMenuItem('', { reactive: false });
        this.menu.addMenuItem(this._dateItem);
    }

    _update() {
        let timings = readTimings();
        if (!timings) {
            this._label.set_text('🕌 N/A');
            this._dateItem.label.set_text('Daemon not running');
            return;
        }

        let next = getNextPrayer(timings);
        let diff = next.time - new Date();
        let countdown = formatCountdown(diff);
        let arabic = ARABIC_NAMES[next.name] || next.name;
        this._label.set_text(`🕌 ${next.name} ${countdown}`);

        for (let name of PRAYER_NAMES) {
            if (this._items[name]) {
                let t = timings[name] || '--:--';
                let arabicName = ARABIC_NAMES[name] || name;
                let isNext = name === next.name;
                let marker = isNext ? '◄ ' : '';
                this._items[name].label.set_text(
                    `${marker}${arabicName}  ${t}`
                );
            }
        }

        this._dateItem.label.set_text(
            `${timings['Date'] || getCurrentDateStr()}  |  ${timings['City'] || timings['city'] || ''} ${timings['Country'] || timings['country'] || ''}`
        );
    }

    destroy() {
        if (this._timeout) {
            GLib.source_remove(this._timeout);
            this._timeout = null;
        }
        super.destroy();
    }
};

function init() {
}

function enable() {
    indicator = new PrayerTimesIndicator();
    Main.panel.addToStatusArea('prayer-times', indicator);
}

function disable() {
    if (indicator) {
        indicator.destroy();
        indicator = null;
    }
}
