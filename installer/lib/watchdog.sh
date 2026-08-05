#!/usr/bin/env bash

update_ini() {
    local file="$1"
    local key="$2"
    local value="$3"

    if grep -q "^[#]*[[:space:]]*${key}=" "$file"; then
        sed -i "s/^[#]*[[:space:]]*${key}=.*/${key}=${value}/" "$file"
    else
        echo "${key}=${value}" >> "$file"
    fi
}

configure_watchdog() {
    log_info "Configuring Hardware Watchdog via systemd..."
    local sys_conf="/etc/systemd/system.conf"
    backup_file "$sys_conf"
    update_ini "$sys_conf" "RuntimeWatchdogSec" "15"
    log_info "Successfully configured Hardware Watchdog."
}
