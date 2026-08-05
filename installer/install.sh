#!/usr/bin/env bash
set -euo pipefail

# ABDOS Modular Installation Script (Idempotent)

REPO_ROOT="$(dirname "$(readlink -f "$0")")/.."
LIB_DIR="${REPO_ROOT}/installer/lib"

# Source modules
# shellcheck source=/dev/null
source "${LIB_DIR}/logging.sh"
# shellcheck source=/dev/null
source "${LIB_DIR}/validation.sh"
# shellcheck source=/dev/null
source "${LIB_DIR}/rollback.sh"
# shellcheck source=/dev/null
source "${LIB_DIR}/packages.sh"
# shellcheck source=/dev/null
source "${LIB_DIR}/services.sh"
# shellcheck source=/dev/null
source "${LIB_DIR}/configuration.sh"
# shellcheck source=/dev/null
source "${LIB_DIR}/network.sh"
# shellcheck source=/dev/null
source "${LIB_DIR}/x11.sh"
# shellcheck source=/dev/null
source "${LIB_DIR}/browser.sh"
# shellcheck source=/dev/null
source "${LIB_DIR}/plymouth.sh"
# shellcheck source=/dev/null
source "${LIB_DIR}/watchdog.sh"

log_info "=================================================================="
log_info "Starting ABDOS Installation (Alpha-2)..."
log_info "=================================================================="

validate_environment
detect_runtime_user

detect_and_install_packages
disable_unnecessary_services
configure_network_manager
configure_x11

# Deploy and render templates
render_template "${REPO_ROOT}/scripts/abdos-config.sh.in" "/usr/local/bin/abdos-config.sh"
render_template "${REPO_ROOT}/scripts/abdos-kiosk.sh.in" "/usr/local/bin/abdos-kiosk.sh"
chmod +x /usr/local/bin/abdos-*.sh

render_template "${REPO_ROOT}/systemd/abdos-config.service.in" "/etc/systemd/system/abdos-config.service"
render_template "${REPO_ROOT}/systemd/abdos-kiosk.service.in" "/etc/systemd/system/abdos-kiosk.service"

systemctl daemon-reload

seed_configuration
configure_plymouth
configure_watchdog
configure_logging

enable_abdos_services
verify_installation

log_info "Cleaning up apt cache..."
apt-get clean >/dev/null 2>&1

log_info "=================================================================="
log_info "ABDOS Installation Complete."
log_info "Please review /boot/firmware/abdos.conf and reboot the system."
log_info "=================================================================="
exit 0
