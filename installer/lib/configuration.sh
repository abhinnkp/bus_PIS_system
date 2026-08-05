#!/usr/bin/env bash

render_template() {
    local src="$1"
    local dest="$2"
    log_info "Rendering template $src -> $dest"
    backup_file "$dest"
    sed -e "s|@USER@|${RUNTIME_USER}|g" \
        -e "s|@GROUP@|${RUNTIME_GROUP}|g" \
        -e "s|@HOME@|${RUNTIME_HOME}|g" \
        -e "s|@CHROMIUM_BIN@|${CHROMIUM_BIN}|g" \
        "$src" > "$dest"
}

seed_configuration() {
    if [[ ! -f "/boot/firmware/abdos.conf" ]]; then
        log_info "Seeding default configuration to /boot/firmware/abdos.conf"
        cp "${REPO_ROOT}/config/abdos.conf.template" "/boot/firmware/abdos.conf"
    else
        log_warn "/boot/firmware/abdos.conf already exists. Keeping existing configuration."
    fi

    if [[ ! -f "/boot/firmware/splash.png" ]]; then
        log_info "Copying default splash screen asset..."
        cp "${REPO_ROOT}/assets/splash.png" "/boot/firmware/splash.png"
    fi
}
