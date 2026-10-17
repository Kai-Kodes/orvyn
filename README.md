# ORVYN

> **CAVA-powered terminal audio visualizer & minimalist music dashboard**

`orvyn` transforms [CAVA](https://github.com/karlstav/cava)'s raw audio spectrum into an artwork-first terminal music dashboard. Designed natively for modern terminal emulators like **WezTerm**, `orvyn` combines real-time spectrum visualization with live MPRIS track metadata, high-resolution album artwork, dynamic color palettes, animated rotating vinyl records, and genuine line-level synchronized lyrics.

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                        │
│     ╭──────────╮     ▶ PLAYING  •  Spotify               I said, "Ooh, I'm blinded     │
│    │  ╭──────╮  │                                        by the lights"                │
│    │ │ ╭────╮ │ │    Blinding Lights                                                   │
│    │ ││  ♪ ││ │    The Weeknd                                                        │
│    │ │ ╰────╯ │ │    After Hours                                                       │
│    │  ╰──────╯  │                                                                      │
│     ╰──────────╯     01:05  ━━━━━━━━━━━━────  03:20                                    │
│                                                                                        │
│  ━ ━━ ━━━ ━━━━ ━━━━━ ━━━━ ━━━ ━━ ━   ━ ━━ ━━━ ━━━━ ━━━━━ ━━━━ ━━━ ━━ ━   ━ ━━ ━━━ ━━━━  │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   ━━━━━━━━━━━━  │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Features

- **Classic CAVA Audio Spectrum**: Run `orvyn` without arguments to get the original, ultra-responsive cyan audio spectrum visualizer powered directly by CAVA.
- **Minimalist Artwork & Metadata Dashboard (`-meta`)**: High-resolution album cover art rendered natively in your terminal via the iTerm2/WezTerm inline image protocol, paired with live track title, artist, album name, player identity, and progress bar.
- **Dynamic Artwork-Derived Accent Colors**: Automatically extracts the dominant vibrance from the album cover art and styles the spectrum bars, progress indicator, and active lyrics to match the album palette (with fallback to default cyan `#00d7ff`).
- **Smooth Rotating Vinyl Record (`-rotate`)**: Pre-computes smooth 25 FPS rotation frames of the album artwork mapped onto a vinyl disc with realistic vinyl grooves, center label, and spindle hole, advancing with sub-second monotonic timing.
- **True Line-Level Synchronized Lyrics (`-lyrics`)**: A dedicated side panel displaying the active lyric sentence at the exact millisecond it is sung.
  - **Honest Sync**: Genuinely timestamped `.lrc` lines track active playback with sub-second precision.
  - **Zero Fabrication**: If a track only provides plain unsynchronized lyrics, `orvyn` displays a subtle `Synced lyrics unavailable` message rather than inventing fake timestamps or linearly distributing lines across the song duration.
  - **Smart Intros & Breaks**: Displays an ambient note indicator (`♪`) during instrumental intros and breaks, never jumping to lyric lines early.
- **Strict Candidate Validation Engine**: Matches songs against primary artists and base titles while penalizing unrequested remixes, live recordings, acoustic versions, slowed/reverb edits, karaoke, and sped-up tracks.
- **Intelligent Sub-Second Timing**: Uses CPU monotonic-clock extrapolation between MPRIS polls, freezes lyric progression immediately when playback is paused, and realigns instantly on forward or backward seeks.
- **Automatic Mouse Cursor Hiding**: Hides the mouse pointer after 3 seconds of inactivity inside the window on X11 and immediately restores it upon pointer movement.
- **Responsive Layout & Clean Exit**: Gracefully adapts to terminal resize events and restores terminal state cleanly upon exit (`Ctrl+C` or `SIGTERM`).
- **Backward Compatibility**: Full backward compatibility shim provided for legacy `cavac` scripts and workflows.

---

## Quick Start (Debian / Ubuntu)

### 1. Install Dependencies
```bash
sudo apt update
sudo apt install -y cava playerctl python3 python3-pil libx11-6
```

### 2. Install ORVYN
Clone the repository and run the automated installer:
```bash
git clone https://github.com/Kai-Kodes/orvyn.git
cd orvyn
./install.sh
```

*(See [INSTALL.md](INSTALL.md) for Arch Linux, Fedora, manual installation steps, and audio server configuration.)*

---

## Usage

```text
usage: orvyn [-h] [-meta] [-rotate] [-lyrics] [--no-cover] [--compact] [-v]

ORVYN - Cyan CAVA terminal audio visualizer & minimalist music dashboard

options:
  -h, --help         Show this help message and exit
  -meta, --meta      Display minimalist music metadata & high-res artwork above spectrum visualizer
  -rotate, --rotate  Display album artwork as an animated rotating circular vinyl record
  -lyrics, --lyrics  Display synchronized lyrics panel on the right side of the screen
  --no-cover         Display metadata and progress without album artwork
  --compact          Compact metadata layout for smaller terminal windows
  -v, --version      Show program's version number and exit
```

### Examples

#### 1. Classic Visualizer
```bash
orvyn
```
Runs the classic full-screen animated cyan audio spectrum visualizer.

#### 2. Music Dashboard
```bash
orvyn -meta
```
Displays native high-resolution album cover, track metadata, live progress bar, and dynamic artwork-colored spectrum bars.

#### 3. Rotating Vinyl Record
```bash
orvyn -meta -rotate
```
Renders the album cover as an animated rotating vinyl disc spinning at 25 FPS.

#### 4. Synchronized Lyrics
```bash
orvyn -meta -lyrics
```
Displays the minimalist dashboard with a dedicated active lyric sentence panel on the right.

#### 5. Full Experience: Vinyl + Lyrics + Spectrum
```bash
orvyn -meta -rotate -lyrics
```
The complete terminal music station: rotating vinyl disc on the left, track metadata in the center, synchronized lyrics on the right, and dynamic spectrum bars below.

#### 6. Text-Only Dashboard (No Artwork)
```bash
orvyn -meta --no-cover -lyrics
```
Ideal for terminals without inline image support or minimal resource usage.

---

## Backward Compatibility

`orvyn` provides seamless backward compatibility with existing installations:
- The installer automatically creates a symlink at `~/.local/bin/cavac` pointing to `~/.local/bin/orvyn`.
- Existing cache files from `~/.cache/cavac` are migrated to `~/.cache/orvyn` automatically without re-downloading artwork or lyrics.
- Calling `cavac` in any existing script or terminal session executes `orvyn` with identical parameters.

---

## How Lyrics Synchronization Works

`orvyn` implements a strict line-level synchronization engine:

1. **Provider Priority**:
   - **YouTube Music InnerTube API**: Queried first with strict candidate verification. If the response contains real timestamps, it is accepted as synchronized. Plain text lyrics are retained as unsynchronized.
   - **LRCLIB API**: Queried via exact `/api/get` parameters (`track_name`, `artist_name`, `duration`) followed by `/api/search` with candidate verification.
2. **Parser Capabilities**:
   - Standard `[mm:ss.xx]`, `[mm:ss.xxx]`, and `[hh:mm:ss.xx]` timestamp formats.
   - Multiple timestamps per line (e.g. repeated choruses `[00:15.50][00:25.50]Chorus`).
   - Millisecond offset adjustments via `[offset:+/-ms]` tags.
3. **Playback Tracking**:
   - At position $t$, `orvyn` displays the lyric event where timestamp $\le t$.
   - Extrapolates position with monotonic microsecond timing between MPRIS polling cycles (5 Hz / 0.20s).
   - Pausing freezes time progression immediately.
   - Seeking forward or backward recalibrates the active line instantaneously.
4. **Honest Availability**:
   - If genuine timestamps are not available from any verified source, the panel displays `Synced lyrics unavailable`. It never fabricates timing.

---

## Terminal Support

| Terminal Emulator | Classic Mode | Metadata Mode | Artwork & Vinyl |
| :--- | :---: | :---: | :---: |
| **WezTerm** | ✓ | ✓ | ✓ (Native iTerm2 Image Protocol) |
| **iTerm2** (macOS) | ✓ | ✓ | ✓ (Native iTerm2 Image Protocol) |
| **Konsole** (Recent) | ✓ | ✓ | ✓ (Inline Image Support) |
| **Ghostty** | ✓ | ✓ | ✓ (Inline Image Support) |
| **Kitty** | ✓ | ✓ | Use `--no-cover` (or iTerm2 shim) |
| **Alacritty / GNOME Terminal** | ✓ | ✓ (`--no-cover`) | Not supported by terminal |

> [!NOTE]
> Terminals that do not support inline image escape sequences can run `orvyn -meta --no-cover` or `orvyn -meta --no-cover -lyrics` for a full text-based experience.

---

## Configuration

`orvyn` reads its CAVA settings from `~/.config/cava/custom.conf`. A recommended configuration file is provided in [`cava.conf`](cava.conf):

```ini
[general]
bars = 80
framerate = 60
autosens = 1
sensitivity = 100

[input]
method = pulse
source = auto

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 1000
bar_delimiter = 32
frame_delimiter = 10
channels = mono
mono_option = average

[smoothing]
noise_reduction = 50
monstercat = 0
waves = 0
```

---

## Troubleshooting

### Missing Track Metadata / "No Media Playing"
- Verify that your music player supports MPRIS. Common supported players include:
  - **Spotify Desktop**
  - **Vivaldi / Chrome / Firefox** (ensure media session / hardware media key flags are enabled)
  - **VLC / MPV / Rhythmbox**
- Test playerctl output manually:
  ```bash
  playerctl metadata
  ```

### Lyrics Unavailable
- Synchronized lyrics require verified, line-level timestamped `.lrc` data from LRCLIB or YouTube Music. Not all songs, remixes, or obscure tracks have community-submitted timestamped lyrics.
- When timestamped lyrics do not exist, `orvyn` honestly displays `Synced lyrics unavailable`.

### Audio Visualizer Bars Not Moving
- Check if CAVA is receiving audio from your server:
  ```bash
  cava -p ~/.config/cava/custom.conf
  ```
- If your system uses PipeWire or PulseAudio, verify that the active sink is selected under `pavucontrol` or `wpctl`.

---

## Known Limitations

- **Source Availability**: Synchronized lyrics depend entirely on external community databases (LRCLIB) and YouTube Music. If no valid timestamped LRC exists for a track, lyrics cannot be synchronized.
- **X11 Cursor Hiding**: The automatic mouse cursor timeout utilizes an X11 ctypes binding (`libX11.so.6`). Under pure Wayland compositors, cursor hiding falls back gracefully without affecting dashboard functionality.

---

## Uninstallation

To uninstall `orvyn` and remove the legacy symlink:
```bash
rm -f ~/.local/bin/orvyn ~/.local/bin/cavac
rm -rf ~/.cache/orvyn ~/.cache/cavac
```
*(Your custom CAVA configuration at `~/.config/cava/custom.conf` is preserved.)*

---

## Credits & Attribution

- **[CAVA](https://github.com/karlstav/cava)** by Karl Stavestrand: The core audio spectrum visualization backend.
- **[LRCLIB](https://lrclib.net/)**: Open, community-driven synchronized lyrics database and API.
- **[YouTube Music InnerTube API](https://music.youtube.com)**: Track discovery, metadata verification, and lyrics ingestion.
- **[playerctl](https://github.com/altdesktop/playerctl)**: MPRIS command-line controller and metadata extractor.
- **[Pillow (PIL)](https://python-pillow.org/)**: Python Imaging Library used for color palette extraction and rotating vinyl disc rendering.

---

## License

This project is licensed under the [MIT License](LICENSE).
