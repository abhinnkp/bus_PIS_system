#!/usr/bin/env bash

disable_unnecessary_services() {
    log_info "Disabling unnecessary services..."
    local services=(
        "bluetooth"
        "hciuart"
        "avahi-daemon"
        "triggerhappy"
        "apt-daily.timer"
        "apt-daily-upgrade.timer"
    )
    # dphys-swapfile is explicitly NOT disabled during Alpha phases to prevent OOM

    for svc in "${services[@]}"; do
        if systemctl list-unit-files | grep -q "^${svc}"; then
            systemctl stop "$svc" 2>/dev/null || true
            systemctl disable "$svc" 2>/dev/null || true
            systemctl mask "$svc" 2>/dev/null || true
            log_info "Masked $svc"
        fi
    done
}

enable_abdos_services() {
    log_info "Enabling ABDOS core services..."
    systemctl enable abdos-config.service
    systemctl enable abdos-kiosk.service
    log_info "Successfully enabled ABDOS services."

    log_info "Masking default plymouth-quit services to hold splash..."
    systemctl mask plymouth-quit.service
    systemctl mask plymouth-quit-wait.service
}
