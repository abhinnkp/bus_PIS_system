#!/usr/bin/env bash
set -euo pipefail

# ABDOS Installation Script (Idempotent)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_err() { echo -e "${RED}[ERROR]${NC} $1"; }

# 1. Pre-flight Checks
if [[ $EUID -ne 0 ]]; then
    log_err "This script must be run as root. Try: sudo ./install.sh"
    exit 1
fi

REPO_ROOT="$(dirname "$(readlink -f "$0")")/.."

# Verify required files and directories exist before proceeding
log_info "Verifying installer assets and templates..."
REQUIRED_FILES=(
    "${REPO_ROOT}/config/abdos.conf.template"
    "${REPO_ROOT}/assets/splash.png"
    "${REPO_ROOT}/scripts/abdos-config.sh.in"
    "${REPO_ROOT}/scripts/abdos-kiosk.sh.in"
    "${REPO_ROOT}/systemd/abdos-config.service.in"
    "${REPO_ROOT}/systemd/abdos-kiosk.service.in"
)
for req in "${REQUIRED_FILES[@]}"; do
    if [[ ! -f "$req" ]]; then
        log_err "Required template or asset missing: $req"
        log_err "Installation aborted. System has not been modified."
        exit 1
    fi
done

log_info "Starting ABDOS installation..."

# 2. Dynamic Runtime User Detection
log_info "Detecting primary runtime user..."
# Attempt to detect the user invoking sudo, fallback to ID 1000 (standard first user), or fail.
if [[ -n "${SUDO_USER:-}" && "$SUDO_USER" != "root" ]]; then
    RUNTIME_USER="$SUDO_USER"
elif id -nu 1000 >/dev/null 2>&1; then
    RUNTIME_USER=$(id -nu 1000)
else
    log_err "Could not detect a standard primary interactive user (UID 1000 or SUDO_USER). Aborting."
    exit 1
fi

RUNTIME_UID=$(id -u "$RUNTIME_USER")
RUNTIME_GID=$(id -g "$RUNTIME_USER")
RUNTIME_GROUP=$(id -ng "$RUNTIME_USER")
RUNTIME_HOME=$(getent passwd "$RUNTIME_USER" | cut -d: -f6)

# Runtime Validation
if [[ ! -d "$RUNTIME_HOME" ]]; then
    log_err "Detected home directory $RUNTIME_HOME for user $RUNTIME_USER does not exist. Aborting."
    exit 1
fi

log_info "Detected User: $RUNTIME_USER (UID: $RUNTIME_UID, GID: $RUNTIME_GID)"
log_info "Detected Home: $RUNTIME_HOME"

# 3. Dynamic Chromium Package Detection
log_info "Detecting available Chromium package..."
apt-get update -y >/dev/null
# Prefer the native 'chromium' package on Bookworm
if apt-cache show chromium >/dev/null 2>&1; then
    CHROMIUM_PKG="chromium"
else
    # Fallback for older/alternate repo structures
    CHROMIUM_PKG="chromium-browser"
fi
log_info "Selected browser package: $CHROMIUM_PKG"

# 4. Package Management (based on SBOM)
log_info "Installing mandatory packages..."

PACKAGES=(
    "$CHROMIUM_PKG"
    "xserver-xorg"
    "x11-xserver-utils"
    "xinit"
    "openbox"
    "unclutter"
    "plymouth"
    "plymouth-themes"
    "network-manager"
)

# Using DEBIAN_FRONTEND=noninteractive to prevent prompts during automated install
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${PACKAGES[@]}"

# Detect binary path post-installation
if command -v chromium >/dev/null 2>&1; then
    CHROMIUM_BIN="$(command -v chromium)"
elif command -v chromium-browser >/dev/null 2>&1; then
    CHROMIUM_BIN="$(command -v chromium-browser)"
else
    log_err "Failed to locate Chromium binary after installation. Aborting."
    exit 1
fi
log_info "Detected browser binary at: $CHROMIUM_BIN"

# 5. Service Disablement (Resource Optimization)
log_info "Disabling unnecessary services..."
SERVICES_TO_DISABLE=(
    "bluetooth"
    "hciuart"
    "avahi-daemon"
    "triggerhappy"
    "apt-daily.timer"
    "apt-daily-upgrade.timer"
)
# Note: dphys-swapfile is retained during initial validation phases to ensure Chromium does not OOM.
# SD card wear optimizations will be measured and adjusted in Phase 3.

for svc in "${SERVICES_TO_DISABLE[@]}"; do
    if systemctl list-unit-files | grep -q "^${svc}"; then
        systemctl stop "$svc" 2>/dev/null || true
        systemctl disable "$svc" 2>/dev/null || true
        systemctl mask "$svc" 2>/dev/null || true
        log_info "Masked $svc"
    fi
done

# Ensure NetworkManager takes over
if systemctl list-unit-files | grep -q "^dhcpcd.service"; then
    systemctl stop dhcpcd 2>/dev/null || true
    systemctl disable dhcpcd 2>/dev/null || true
fi
systemctl enable NetworkManager

# Ensure user has correct groups for headless X11 startup
log_info "Adding $RUNTIME_USER to necessary groups..."
usermod -a -G tty,video "$RUNTIME_USER" || true

# 6. File Deployment & Template Rendering
log_info "Rendering templates and deploying scripts/services..."


backup_file() {
    if [[ -f "$1" ]]; then
        cp -f "$1" "$1.abdos.bak"
    fi
}

render_template() {
    local src="$1"
    local dest="$2"
    log_info "Rendering $src -> $dest"
    backup_file "$dest"
    sed -e "s|@USER@|${RUNTIME_USER}|g" \
        -e "s|@GROUP@|${RUNTIME_GROUP}|g" \
        -e "s|@HOME@|${RUNTIME_HOME}|g" \
        -e "s|@CHROMIUM_BIN@|${CHROMIUM_BIN}|g" \
        "$src" > "$dest"
}

# Deploy Scripts
render_template "${REPO_ROOT}/scripts/abdos-config.sh.in" "/usr/local/bin/abdos-config.sh"
render_template "${REPO_ROOT}/scripts/abdos-kiosk.sh.in" "/usr/local/bin/abdos-kiosk.sh"
chmod +x /usr/local/bin/abdos-*.sh

# Deploy Systemd Units
render_template "${REPO_ROOT}/systemd/abdos-config.service.in" "/etc/systemd/system/abdos-config.service"
render_template "${REPO_ROOT}/systemd/abdos-kiosk.service.in" "/etc/systemd/system/abdos-kiosk.service"

systemctl daemon-reload

# 7. Configuration Seeding
if [[ ! -f "/boot/firmware/abdos.conf" ]]; then
    log_info "Seeding default configuration to /boot/firmware/abdos.conf"
    cp "${REPO_ROOT}/config/abdos.conf.template" "/boot/firmware/abdos.conf"
else
    log_warn "/boot/firmware/abdos.conf already exists. Keeping existing configuration."
fi

if [[ ! -f "/boot/firmware/splash.png" ]]; then
    log_info "Copying default splash screen..."
    cp "${REPO_ROOT}/assets/splash.png" "/boot/firmware/splash.png"
fi

# 8. Boot Modification (Silent Boot & Plymouth)
CMDLINE_FILE="/boot/firmware/cmdline.txt"
if [[ -f "$CMDLINE_FILE" ]]; then
    log_info "Configuring silent boot parameters..."
    backup_file "$CMDLINE_FILE"
    # Read current cmdline
    cmdline=$(cat "$CMDLINE_FILE")

    # Flags required for silent boot and plymouth
    FLAGS="quiet splash loglevel=0 vt.global_cursor_default=0 logo.nologo consoleblank=0"

    # Idempotent append
    for flag in $FLAGS; do
        if ! echo "$cmdline" | grep -q -w "$flag"; then
            cmdline="$cmdline $flag"
        fi
    done

    # Remove all console entries to stop text output on HDMI and Serial
    # e.g., console=tty1, console=serial0,115200, console=ttyAMA0,115200
    cmdline=$(echo "$cmdline" | sed -E 's/console=[a-zA-Z0-9,]+//g' | xargs)

    # Write back
    echo "$cmdline" > "$CMDLINE_FILE"
    log_info "Successfully updated $CMDLINE_FILE"
else
    log_err "$CMDLINE_FILE not found! Are you on Raspberry Pi OS Bookworm?"
fi

# 9. Dynamic Plymouth Theme Configuration
log_info "Configuring custom Plymouth splash image..."
# Detect available themes, prefer 'pix', fallback to 'spinner' or 'tribar'
AVAILABLE_THEMES=$(plymouth-set-default-theme -l)
SELECTED_THEME=""
for t in pix spinner tribar; do
    if echo "$AVAILABLE_THEMES" | grep -q "^$t$"; then
        SELECTED_THEME="$t"
        break
    fi
done

if [[ -n "$SELECTED_THEME" ]]; then
    THEME_IMG_DIR="/usr/share/plymouth/themes/$SELECTED_THEME"
    # Overwrite the default splash asset for the detected theme if it exists
    if [[ -d "$THEME_IMG_DIR" ]]; then
        for img in splash.png watermark.png box.png; do
            if [[ -f "$THEME_IMG_DIR/$img" ]]; then
                backup_file "$THEME_IMG_DIR/$img"
                cp "/boot/firmware/splash.png" "$THEME_IMG_DIR/$img" 2>/dev/null || true
            fi
        done
    fi
    log_info "Setting plymouth theme to $SELECTED_THEME and rebuilding initramfs..."
    plymouth-set-default-theme -R "$SELECTED_THEME" || true
else
    log_warn "No suitable plymouth theme found. Splash screen may not display custom image."
fi

# INI updater function
update_ini() {
    local file="$1"
    local key="$2"
    local value="$3"

    if grep -q "^[#]*[[:space:]]*${key}=" "$file"; then
        # Replace existing (commented or not)
        sed -i "s/^[#]*[[:space:]]*${key}=.*/${key}=${value}/" "$file"
    else
        # Append if not found
        echo "${key}=${value}" >> "$file"
    fi
}

# 10. Hardware Watchdog Enablement
log_info "Configuring Hardware Watchdog via systemd..."
backup_file "/etc/systemd/system.conf"
update_ini "/etc/systemd/system.conf" "RuntimeWatchdogSec" "15"
log_info "Successfully configured Hardware Watchdog."

# 11. RAM-Backed File Systems
log_info "Enabling tmp.mount to ensure /tmp is tmpfs (RAM)..."
if ! systemctl enable tmp.mount 2>/dev/null; then
    cp /usr/share/systemd/tmp.mount /etc/systemd/system/tmp.mount || true
    systemctl enable tmp.mount || log_warn "Failed to enable tmp.mount"
fi

# Configure Volatile Logging (RAM-based systemd journal)
log_info "Configuring volatile journald logging..."
backup_file "/etc/systemd/journald.conf"
update_ini "/etc/systemd/journald.conf" "Storage" "volatile"
systemctl restart systemd-journald || true
log_info "Successfully configured volatile logging."

# 12. Service Enablement
log_info "Enabling ABDOS services..."
systemctl enable abdos-config.service
systemctl enable abdos-kiosk.service
log_info "Successfully enabled ABDOS services."

# Prevent standard plymouth from dropping splash screen before kiosk is ready
log_info "Masking default plymouth-quit services..."
systemctl mask plymouth-quit.service
systemctl mask plymouth-quit-wait.service

# 13. Cleanup
log_info "Cleaning up apt cache..."
apt-get clean

log_info "=================================================================="
log_info "ABDOS Installation Complete."
log_info "Please review /boot/firmware/abdos.conf and reboot the system."
log_info "=================================================================="
exit 0
