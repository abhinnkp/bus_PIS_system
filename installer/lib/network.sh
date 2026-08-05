#!/usr/bin/env bash

configure_network_manager() {
    # Ensure NetworkManager takes over from dhcpcd if present
    if systemctl list-unit-files | grep -q "^dhcpcd.service"; then
        systemctl stop dhcpcd 2>/dev/null || true
        systemctl disable dhcpcd 2>/dev/null || true
        log_info "Disabled legacy dhcpcd service."
    fi
    systemctl enable NetworkManager
    log_info "NetworkManager enabled."
}
