#!/usr/bin/env bash

configure_x11() {
    log_info "Adding $RUNTIME_USER to necessary groups for headless X11..."
    usermod -a -G tty,video "$RUNTIME_USER" || true

    log_info "Configuring Xwrapper.config for rootless execution..."
    local xwrapper="/etc/X11/Xwrapper.config"
    backup_file "$xwrapper"

    mkdir -p /etc/X11

    if [[ -f "$xwrapper" ]]; then
        if grep -q "^allowed_users" "$xwrapper"; then
            sed -i 's/^allowed_users.*/allowed_users=anybody/' "$xwrapper"
        else
            echo "allowed_users=anybody" >> "$xwrapper"
        fi
    else
        echo "allowed_users=anybody" > "$xwrapper"
    fi
    log_info "Successfully configured $xwrapper."
}
