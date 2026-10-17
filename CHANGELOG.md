# Changelog

All notable changes to `orvyn` are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.2.0] - 2026-10-17

### Changed
- **Project Renamed to ORVYN**: Officially rebranded project from CAVAC to **ORVYN**.
- **Executable & CLI**: Migrated main command and executable to `orvyn` (`~/.local/bin/orvyn`), featuring self-identification as ORVYN and `-v`/`--version` support.
- **Backward Compatibility**: Automated creation of `cavac` symlink pointing to `orvyn`, ensuring existing user scripts, aliases, and habits continue working seamlessly without duplicate or conflicting binaries.
- **Cache Migration**: Migrated runtime artwork and lyrics caches to `~/.cache/orvyn` with automatic backward-compatible migration preserving existing cached data from `~/.cache/cavac`.
- **Repository URLs**: Updated all repository links and documentation to `https://github.com/Kai-Kodes/orvyn`.

---

## [3.1.0] - 2026-10-17

### Added
- **True Line-Level Lyrics Synchronization**: Re-engineered lyrics engine to require genuine timestamped `.lrc` events.
- **Robust LRC Parser (`parse_lrc`)**:
  - Full support for standard `[mm:ss.xx]`, `[mm:ss.xxx]`, and `[hh:mm:ss.xx]` timestamps.
  - Support for multiple timestamps on single lines (e.g. repeated choruses `[00:15.50][00:25.50]Lyric`).
  - Offset tag parsing (`[offset:+/-ms]`) with millisecond timestamp adjustment.
  - Automatic filtering of ID3/LRC metadata tags (`[ti:]`, `[ar:]`, `[al:]`, `[by:]`, `[length:]`).
  - Chronological event sorting and duplicate timestamp deduplication.
- **Sub-Second MPRIS Playback Synchronization**:
  - High-precision monotonic clock extrapolation during active playback.
  - Instantaneous lyric freeze when playback pauses.
  - Rapid recovery and realignment upon forward or backward seeks.
  - 5 Hz (0.20s) MPRIS polling cycle recording hardware query timestamps.
- **Intro & Instrumental Break Handling**:
  - Pre-lyric song intros ($t < \text{first timestamp}$) display an ambient note indicator (`♪`) rather than advancing prematurely.
  - Instrumental breaks display `♪` until the next lyric sentence begins.
- **Stale Asynchronous Result Protection**: Discards background fetch results if the active track changed during network query execution.
- **Schema 3 Cache Isolation (`v3_{hash}.json`)**: Caches track fingerprint, matched candidate metadata, provider, and genuine timestamped events, preventing old plain-text cache entries from being misidentified as synchronized.

### Changed
- **Honest Sync Presentation**: If genuine line-level timestamps are unavailable, `orvyn` displays a tasteful, subdued `Synced lyrics unavailable` message. Eliminated approximate line distribution over track duration.
- **Provider Priority Pipeline**:
  1. YouTube Music InnerTube API (inspected for timestamps; plain text classified as `unsynced`).
  2. LRCLIB API (`/api/get` exact query followed by `/api/search` with candidate validation).

---

## [3.0.0] - 2026-10-17

### Added
- **Synchronized Lyrics Mode (`-lyrics`)**: Dedicated side panel displaying the active lyric sentence on the right side of the screen.
- **Strict Candidate Validation Engine (`validate_candidate`)**:
  - NFKD Unicode normalization, quote standardization, and punctuation stripping.
  - Primary artist token overlap verification.
  - Unrequested version penalty: rejects mismatched remixes, live performances, acoustic covers, slowed/reverb edits, karaoke, and sped-up tracks.
  - Duration tolerance verification ($\le 12\text{s}$ tolerance, $> 45\text{s}$ rejection).
- **Native Typography**: Single active lyric sentence rendered in native terminal font with ANSI bold and artwork-derived RGB accent coloring, replacing mathematical Unicode fonts.

---

## [2.5.0] - 2026-10-16

### Added
- **Rotating Vinyl Artwork Mode (`-rotate`)**: Renders high-resolution album covers as a circular vinyl record with realistic grooves, center spindle hole, and circular album label.
- **Smooth 25 FPS Animation**: Monotonic time-driven angular positioning maintaining a 10-second rotation cycle decoupled from audio visualizer ticks.
- **Mouse Cursor Auto-Hiding**: Integrated X11 ctypes binding that automatically hides the mouse cursor inside the WezTerm window after 3 seconds of inactivity and restores it on movement.

---

## [2.0.0] - 2026-10-16

### Added
- **Minimalist Music Dashboard (`-meta`, `--meta`)**:
  - High-resolution album artwork rendering via WezTerm/iTerm2 inline image escape sequences (`\033]1337;File=...`).
  - Dynamic color theme: dominant RGB color extraction from cover art with cyan fallback (`\033[38;2;r;g;bm`).
  - Live track metadata: title, artist, album, player status, and player identity detection.
  - Live progress bar with current position and total length indicators.
  - `--compact` flag for smaller terminal viewports.
  - `--no-cover` flag for lightweight metadata display without inline artwork.
  - Responsive header layout adapting to terminal resize events.

---

## [1.0.0] - 2026-10-03

### Initial Release
- Classic animated cyan spectrum audio visualizer powered by CAVA's raw ASCII output stream.
- Zero-latency terminal rendering with clean SIGINT/SIGTERM terminal restoration.
