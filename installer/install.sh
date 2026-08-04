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

log_info "Starting ABDOS installation..."

# 2. Package Management (based on SBOM)
log_info "Updating apt repositories..."
apt-get update -y

PACKAGES=(
    "chromium-browser"
    "xserver-xorg"
    "x11-xserver-utils"
    "xinit"
    "openbox"
    "unclutter"
    "plymouth"
    "plymouth-themes"
    "network-manager"
)

log_info "Installing mandatory packages..."
# Using DEBIAN_FRONTEND=noninteractive to prevent prompts during automated install
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${PACKAGES[@]}"

# 3. Service Disablement (Resource Optimization)
log_info "Disabling unnecessary services..."
SERVICES_TO_DISABLE=(
    "bluetooth"
    "hciuart"
    "avahi-daemon"
    "triggerhappy"
    "apt-daily.timer"
    "apt-daily-upgrade.timer"
    "dphys-swapfile" # Disable swap to save SD card wear
)

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

# Ensure pi user has correct groups for headless X11 startup
log_info "Adding pi user to necessary groups..."
usermod -a -G tty,video pi || true

# 4. File Deployment
log_info "Deploying ABDOS scripts and services..."

# Assume script is run from abdos/installer directory
REPO_ROOT="$(dirname "$(readlink -f "$0")")/.."

# Copy scripts
cp -f "${REPO_ROOT}/scripts/abdos-config.sh" /usr/local/bin/
cp -f "${REPO_ROOT}/scripts/abdos-kiosk.sh" /usr/local/bin/
chmod +x /usr/local/bin/abdos-*.sh

# Copy systemd units
cp -f "${REPO_ROOT}/systemd/abdos-config.service" /etc/systemd/system/
cp -f "${REPO_ROOT}/systemd/abdos-kiosk.service" /etc/systemd/system/

systemctl daemon-reload

# 5. Configuration Seeding
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

# 6. Boot Modification (Silent Boot & Plymouth)
CMDLINE_FILE="/boot/firmware/cmdline.txt"
if [[ -f "$CMDLINE_FILE" ]]; then
    log_info "Configuring silent boot parameters..."
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

    # Remove console=tty1 to stop text output on HDMI
    cmdline=$(echo "$cmdline" | sed 's/console=tty1//g' | xargs)

    # Write back
    echo "$cmdline" > "$CMDLINE_FILE"
else
    log_err "$CMDLINE_FILE not found! Are you on Raspberry Pi OS Bookworm?"
fi

# Setup Plymouth theme (using a basic theme that can display an image)
if plymouth-set-default-theme -l | grep -q "pix"; then
    log_info "Configuring custom Plymouth splash image..."
    # The 'pix' theme in Pi OS uses splash.png. We overwrite it with ours.
    cp "/boot/firmware/splash.png" "/usr/share/plymouth/themes/pix/splash.png" 2>/dev/null || true
    # Set the theme and rebuild initramfs so it's available in early boot
    plymouth-set-default-theme -R pix
else
    # Fallback to tribar if pix isn't available
    plymouth-set-default-theme -R tribar || true
fi

# 7. Hardware Watchdog Enablement
log_info "Configuring Hardware Watchdog via systemd..."
# Enable RuntimeWatchdog in systemd
sed -i 's/^#RuntimeWatchdogSec=.*/RuntimeWatchdogSec=15/' /etc/systemd/system.conf

# Enable RAM-backed /tmp
log_info "Enabling tmp.mount to ensure /tmp is tmpfs (RAM)..."
if ! systemctl enable tmp.mount 2>/dev/null; then
    cp /usr/share/systemd/tmp.mount /etc/systemd/system/tmp.mount || true
    systemctl enable tmp.mount || log_warn "Failed to enable tmp.mount"
fi

# Configure Volatile Logging (RAM-based systemd journal)
log_info "Configuring volatile journald logging..."
sed -i 's/^#Storage=.*/Storage=volatile/' /etc/systemd/journald.conf
systemctl restart systemd-journald || true

# 8. Service Enablement
log_info "Enabling ABDOS services..."
systemctl enable abdos-config.service
systemctl enable abdos-kiosk.service

# Prevent standard plymouth from dropping splash screen before kiosk is ready
log_info "Masking default plymouth-quit services..."
systemctl mask plymouth-quit.service
systemctl mask plymouth-quit-wait.service

# Setup sudoers for pi to drop splash (ExecStartPost in systemd unit requires root)
if ! grep -q "plymouth" /etc/sudoers.d/010_pi-nopasswd 2>/dev/null; then
    echo "pi ALL=(ALL) NOPASSWD: /bin/plymouth quit" > /etc/sudoers.d/abdos-plymouth
    chmod 0440 /etc/sudoers.d/abdos-plymouth
fi

# 9. Cleanup
log_info "Cleaning up apt cache..."
apt-get clean

log_info "=================================================================="
log_info "ABDOS Installation Complete."
log_info "Please review /boot/firmware/abdos.conf and reboot the system."
log_info "=================================================================="
exit 0
