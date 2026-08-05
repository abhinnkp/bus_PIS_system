#!/usr/bin/env bash

# Validation constraints
validate_environment() {
    if [[ $EUID -ne 0 ]]; then
        log_err "This script must be run as root. Try: sudo ./install.sh"
        exit 1
    fi

    log_info "Verifying installer assets and templates..."
    local required_files=(
        "${REPO_ROOT}/config/abdos.conf.template"
        "${REPO_ROOT}/assets/splash.png"
        "${REPO_ROOT}/scripts/abdos-config.sh.in"
        "${REPO_ROOT}/scripts/abdos-kiosk.sh.in"
        "${REPO_ROOT}/systemd/abdos-config.service.in"
        "${REPO_ROOT}/systemd/abdos-kiosk.service.in"
    )
    for req in "${required_files[@]}"; do
        if [[ ! -f "$req" ]]; then
            log_err "Required template or asset missing: $req"
            log_err "Installation aborted. System has not been modified."
            exit 1
        fi
    done
    log_info "All installer assets present."
}

detect_runtime_user() {
    log_info "Detecting primary runtime user..."
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
    # shellcheck disable=SC2034
    RUNTIME_GROUP=$(id -ng "$RUNTIME_USER")
    RUNTIME_HOME=$(getent passwd "$RUNTIME_USER" | cut -d: -f6)

    if [[ ! -d "$RUNTIME_HOME" ]]; then
        log_err "Detected home directory $RUNTIME_HOME for user $RUNTIME_USER does not exist. Aborting."
        exit 1
    fi

    log_info "Detected User: $RUNTIME_USER (UID: $RUNTIME_UID, GID: $RUNTIME_GID)"
    log_info "Detected Home: $RUNTIME_HOME"
}

verify_installation() {
    log_info "Running post-installation verification..."
    local errors=0

    # 1. Configuration & Templates
    if [[ ! -f "/boot/firmware/abdos.conf" ]]; then log_err "/boot/firmware/abdos.conf missing."; errors=$((errors+1)); fi
    if [[ ! -f "/usr/local/bin/abdos-kiosk.sh" ]]; then log_err "abdos-kiosk.sh template missing."; errors=$((errors+1)); fi

    # 2. X11 & Binaries
    if ! grep -q "allowed_users=anybody" /etc/X11/Xwrapper.config 2>/dev/null; then log_err "Xwrapper.config invalid."; errors=$((errors+1)); fi
    if [[ ! -x "$CHROMIUM_BIN" ]]; then log_err "Chromium executable not found at $CHROMIUM_BIN."; errors=$((errors+1)); fi

    # 3. Services (Installed & Enabled)
    for svc in abdos-config.service abdos-kiosk.service; do
        if ! systemctl is-enabled "$svc" >/dev/null 2>&1; then log_err "$svc is not enabled."; errors=$((errors+1)); fi
    done
    if ! systemctl is-active NetworkManager >/dev/null 2>&1; then log_err "NetworkManager is not active."; errors=$((errors+1)); fi

    # 4. OS Configurations
    if ! grep -q "Storage=volatile" /etc/systemd/journald.conf 2>/dev/null; then log_err "Journald volatile storage missing."; errors=$((errors+1)); fi
    if ! grep -q "RuntimeWatchdogSec=15" /etc/systemd/system.conf 2>/dev/null; then log_err "Watchdog config missing."; errors=$((errors+1)); fi

    # 5. Hostname
    local current_host
    current_host=$(hostname)
    if ! grep -q -w "$current_host" /etc/hosts; then log_err "Hostname $current_host missing from /etc/hosts."; errors=$((errors+1)); fi

    if [[ $errors -eq 0 ]]; then
        log_info "Post-installation verification PASSED."
    else
        log_warn "Post-installation verification FAILED with $errors errors."
    fi
}
