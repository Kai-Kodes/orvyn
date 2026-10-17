# Installation Guide for cavac

This guide details how to install, configure, and verify `cavac` on Debian, Ubuntu, and other Linux distributions.

---

## Prerequisites & Dependencies

`cavac` requires Python 3.10+, CAVA, and a few lightweight system utilities:

### 1. Debian / Ubuntu / Linux Mint
```bash
sudo apt update
sudo apt install -y cava playerctl python3 python3-pil libx11-6
```

### 2. Arch Linux / Manjaro
```bash
sudo pacman -S cava playerctl python python-pillow libx11
```

### 3. Fedora
```bash
sudo dnf install cava playerctl python3 python3-pillow libX11
```

### Dependency Breakdown
| Dependency | Type | Purpose |
| :--- | :--- | :--- |
| `cava` | Required | Audio spectrum visualizer engine |
| `python3` | Required | Runtime environment (3.10+ recommended) |
| `playerctl` | Required for `-meta` | MPRIS media player metadata and playback position |
| `python3-pil` (Pillow) | Optional / Recommended | Dynamic accent color extraction, cover processing, vinyl rotation |
| `libx11-6` | Optional | Mouse cursor auto-hiding after 3s of inactivity under X11 |

---

## Method 1: Automated Installation (Recommended)

Clone the repository and run the provided installation script:

```bash
git clone https://github.com/Kai-Kodes/cavac.git
cd cavac
./install.sh
```

The script will:
1. Back up any existing `~/.local/bin/cavac` with a timestamp before updating.
2. Install the `cavac` executable to `~/.local/bin/cavac`.
3. Check for `~/.config/cava/custom.conf`. If missing, installs the recommended `cava.conf`. Existing CAVA configurations are preserved untouched.
4. Verify all system dependencies and report any missing packages.

---

## Method 2: Manual Installation

If you prefer to configure everything manually:

1. **Install the executable**:
   ```bash
   mkdir -p ~/.local/bin
   cp cavac ~/.local/bin/cavac
   chmod +x ~/.local/bin/cavac
   ```

2. **Ensure `~/.local/bin` is in your `PATH`**:
   Add this line to your `~/.bashrc`, `~/.zshrc`, or shell profile:
   ```bash
   export PATH="${HOME}/.local/bin:${PATH}"
   ```
   Reload your shell:
   ```bash
   source ~/.bashrc
   ```

3. **Install the CAVA configuration**:
   ```bash
   mkdir -p ~/.config/cava
   cp cava.conf ~/.config/cava/custom.conf
   ```

---

## Terminal Compatibility

| Mode | Supported Terminals | Protocol |
| :--- | :--- | :--- |
| **Classic Visualizer (`cavac`)** | Any terminal emulator | ANSI 256-color / 24-bit RGB |
| **Dashboard (`--no-cover`)** | Any terminal emulator | ANSI 24-bit Truecolor |
| **Artwork & Rotating Vinyl** | WezTerm, iTerm2, Konsole, Ghostty | iTerm2 inline image escape protocol |

> [!TIP]
> If your terminal emulator does not support the iTerm2 inline image protocol, use `cavac -meta --no-cover` to enjoy full track metadata, progress indicators, synchronized lyrics, and audio visualizer spectrum without inline images.

---

## Audio Server Configuration (PipeWire / PulseAudio)

`cava` connects to your desktop audio server. The included `cava.conf` is configured for **PulseAudio / PipeWire**:

```ini
[input]
method = pulse
source = auto
```

If you are using pure ALSA or JACK, edit `~/.config/cava/custom.conf` and adjust the `method` under `[input]`:
- ALSA: `method = alsa`
- FIFO: `method = fifo`
- JACK: `method = jack`

---

## Uninstallation

To remove `cavac`:

```bash
rm -f ~/.local/bin/cavac
```

Optionally remove cached artwork and lyrics:
```bash
rm -rf ~/.cache/cavac
```

*(Your personal `~/.config/cava/custom.conf` is preserved unless manually deleted.)*
