#!/usr/bin/env bash
set -euo pipefail

# ABDOS Modular Uninstallation Script (Idempotent)

REPO_ROOT="$(dirname "$(readlink -f "$0")")/.."
LIB_DIR="${REPO_ROOT}/installer/lib"

# Source logging and rollback logic
# shellcheck source=/dev/null
source "${LIB_DIR}/logging.sh"

log_info "=================================================================="
log_info "Starting ABDOS Uninstallation..."
log_info "=================================================================="

if [[ $EUID -ne 0 ]]; then
    log_err "This script must be run as root. Try: sudo ./uninstall.sh"
    exit 1
fi

# 1. Stop and Disable Custom Services
log_info "Stopping and disabling ABDOS services..."
SERVICES=("abdos-kiosk.service" "abdos-config.service" "plymouth-quit-wait.service")
for svc in "${SERVICES[@]}"; do
    if systemctl list-unit-files | grep -q "^${svc}"; then
        systemctl stop "$svc" 2>/dev/null || true
        systemctl disable "$svc" 2>/dev/null || true
        rm -f "/etc/systemd/system/${svc}"
    fi
done

# 2. Unmask system services
log_info "Unmasking system services..."
systemctl unmask plymouth-quit.service 2>/dev/null || true
systemctl unmask plymouth-quit-wait.service 2>/dev/null || true

# 3. Restore Backups
log_info "Restoring system file backups..."
BACKUP_REGISTRY="/var/log/abdos_backups.log"
if [[ -f "$BACKUP_REGISTRY" ]]; then
    while read -r backup_file; do
        if [[ -f "$backup_file" ]]; then
            original_file="${backup_file%.abdos.bak}"
            log_info "Restoring $original_file"
            mv -f "$backup_file" "$original_file"
        fi
    done < "$BACKUP_REGISTRY"
    rm -f "$BACKUP_REGISTRY"
else
    log_warn "Backup registry not found. System files may need manual restoration."
fi

# 4. Remove Configuration and Scripts
log_info "Removing generated files and configurations..."
rm -f "/usr/local/bin/abdos-config.sh"
rm -f "/usr/local/bin/abdos-kiosk.sh"
rm -f "/etc/X11/Xwrapper.config"
rm -f "/boot/firmware/abdos.conf"
rm -f "/boot/firmware/splash.png"

# 5. Restore Plymouth
log_info "Rebuilding initramfs..."
update-initramfs -u >/dev/null 2>&1 || log_warn "Failed to rebuild initramfs."

systemctl daemon-reload

log_info "=================================================================="
log_info "ABDOS Uninstallation Complete."
log_info "The system has been restored. Please reboot."
log_info "=================================================================="
exit 0
