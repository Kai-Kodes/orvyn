#!/usr/bin/env bash
# ==============================================================================
# cavac installer
# Installs cavac to ~/.local/bin and sets up the recommended CAVA configuration.
# ==============================================================================

set -euo pipefail

BIN_DIR="${HOME}/.local/bin"
CONFIG_DIR="${HOME}/.config/cava"
CONFIG_FILE="${CONFIG_DIR}/custom.conf"
SCRIPT_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Installing cavac ==="

# 1. Ensure target directories exist
mkdir -p "${BIN_DIR}"
mkdir -p "${CONFIG_DIR}"

# 2. Install executable
if [ -f "${BIN_DIR}/cavac" ]; then
    BACKUP="${BIN_DIR}/cavac.bak.$(date +%Y%m%d_%H%M%S)"
    echo "Backing up existing cavac to ${BACKUP}..."
    cp -p "${BIN_DIR}/cavac" "${BACKUP}"
fi

echo "Installing cavac to ${BIN_DIR}/cavac..."
cp -p "${SCRIPT_SRC}/cavac" "${BIN_DIR}/cavac"
chmod +x "${BIN_DIR}/cavac"

# 3. Configure CAVA
if [ -f "${CONFIG_FILE}" ]; then
    echo "Found existing CAVA configuration at ${CONFIG_FILE} (preserving untouched)."
else
    echo "Installing default CAVA configuration to ${CONFIG_FILE}..."
    cp -p "${SCRIPT_SRC}/cava.conf" "${CONFIG_FILE}"
fi

# 4. Dependency checks
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

# 5. PATH check
if [[ ":$PATH:" != *":${BIN_DIR}:"* ]]; then
    echo ""
    echo "Notice: ${BIN_DIR} is not in your current PATH."
    echo "Add the following line to your ~/.bashrc or ~/.zshrc:"
    echo "    export PATH=\"\${HOME}/.local/bin:\${PATH}\""
fi

echo ""
echo "cavac installation complete! Run 'cavac --help' to get started."
