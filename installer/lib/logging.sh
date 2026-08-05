#!/usr/bin/env bash

configure_logging() {
    log_info "Enabling tmp.mount to ensure /tmp is tmpfs (RAM)..."
    if ! systemctl enable tmp.mount 2>/dev/null; then
        cp /usr/share/systemd/tmp.mount /etc/systemd/system/tmp.mount || true
        systemctl enable tmp.mount || log_warn "Failed to enable tmp.mount"
    fi

    log_info "Configuring volatile journald logging..."
    local journal_conf="/etc/systemd/journald.conf"
    backup_file "$journal_conf"
    update_ini "$journal_conf" "Storage" "volatile"
    systemctl restart systemd-journald || true
    log_info "Successfully configured volatile logging."
}
