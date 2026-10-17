#!/usr/bin/env bash
# ==============================================================================
# ORVYN installer
# Installs orvyn to ~/.local/bin and sets up the recommended CAVA configuration.
# Provides backward-compatibility symlink for legacy 'cavac' commands.
# ==============================================================================

set -euo pipefail

BIN_DIR="${HOME}/.local/bin"
CONFIG_DIR="${HOME}/.config/cava"
CONFIG_FILE="${CONFIG_DIR}/custom.conf"
CACHE_DIR="${HOME}/.cache/orvyn"
LEGACY_CACHE_DIR="${HOME}/.cache/cavac"
SCRIPT_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Installing ORVYN ==="

# 1. Ensure target directories exist
mkdir -p "${BIN_DIR}"
mkdir -p "${CONFIG_DIR}"
mkdir -p "${CACHE_DIR}/covers"
mkdir -p "${CACHE_DIR}/lyrics"

# 2. Migrate legacy cache if present
if [ -d "${LEGACY_CACHE_DIR}" ]; then
    echo "Migrating legacy cache from ${LEGACY_CACHE_DIR} to ${CACHE_DIR}..."
    if [ -d "${LEGACY_CACHE_DIR}/covers" ]; then
        cp -rn "${LEGACY_CACHE_DIR}/covers/"* "${CACHE_DIR}/covers/" 2>/dev/null || true
    fi
    if [ -d "${LEGACY_CACHE_DIR}/lyrics" ]; then
        cp -rn "${LEGACY_CACHE_DIR}/lyrics/"* "${CACHE_DIR}/lyrics/" 2>/dev/null || true
    fi
fi

# 3. Install executable
if [ -f "${BIN_DIR}/orvyn" ] && [ ! -L "${BIN_DIR}/orvyn" ]; then
    BACKUP="${BIN_DIR}/orvyn.bak.$(date +%Y%m%d_%H%M%S)"
    echo "Backing up existing orvyn to ${BACKUP}..."
    cp -p "${BIN_DIR}/orvyn" "${BACKUP}"
fi

echo "Installing orvyn to ${BIN_DIR}/orvyn..."
cp -p "${SCRIPT_SRC}/orvyn" "${BIN_DIR}/orvyn"
chmod +x "${BIN_DIR}/orvyn"

# 4. Backward-compatibility symlink for cavac
if [ -e "${BIN_DIR}/cavac" ]; then
    if [ -L "${BIN_DIR}/cavac" ]; then
        rm -f "${BIN_DIR}/cavac"
    else
        BACKUP="${BIN_DIR}/cavac.bak.$(date +%Y%m%d_%H%M%S)"
        echo "Backing up existing cavac to ${BACKUP}..."
        cp -p "${BIN_DIR}/cavac" "${BACKUP}"
        rm -f "${BIN_DIR}/cavac"
    fi
fi
echo "Creating backward-compatibility symlink: ${BIN_DIR}/cavac -> ${BIN_DIR}/orvyn..."
ln -sf "${BIN_DIR}/orvyn" "${BIN_DIR}/cavac"

# 5. Configure CAVA
if [ -f "${CONFIG_FILE}" ]; then
    echo "Found existing CAVA configuration at ${CONFIG_FILE} (preserving untouched)."
else
    echo "Installing default CAVA configuration to ${CONFIG_FILE}..."
    cp -p "${SCRIPT_SRC}/cava.conf" "${CONFIG_FILE}"
fi

# 6. Dependency checks
echo ""
echo "=== Checking dependencies ==="

MISSING=0

check_cmd() {
    local cmd="$1"
    local pkg="$2"
    if command -v "${cmd}" >/dev/null 2>&1; then
        echo "  [✓] ${cmd}"
    else
        echo "  [✗] ${cmd} (install with: sudo apt install ${pkg})"
        MISSING=1
    fi
}

check_cmd "python3" "python3"
check_cmd "cava" "cava"
check_cmd "playerctl" "playerctl"

if python3 -c "from PIL import Image" >/dev/null 2>&1; then
    echo "  [✓] Pillow (PIL)"
else
    echo "  [✗] Pillow (install with: sudo apt install python3-pil)"
    MISSING=1
fi

echo ""
if [ "${MISSING}" -eq 0 ]; then
    echo "All dependencies are installed!"
else
    echo "Note: Install any missing packages listed above for full functionality."
fi

# 7. PATH check
if [[ ":$PATH:" != *":${BIN_DIR}:"* ]]; then
    echo ""
    echo "Notice: ${BIN_DIR} is not in your current PATH."
    echo "Add the following line to your ~/.bashrc or ~/.zshrc:"
    echo "    export PATH=\"\${HOME}/.local/bin:\${PATH}\""
fi

echo ""
echo "ORVYN installation complete! Run 'orvyn --help' to get started."
echo "(Legacy 'cavac' command is preserved as a backward-compatibility symlink)."
