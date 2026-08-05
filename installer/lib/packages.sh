#!/usr/bin/env bash

detect_and_install_packages() {
    log_info "Detecting available Chromium package..."
    apt-get update -y >/dev/null

    if apt-cache show chromium >/dev/null 2>&1; then
        CHROMIUM_PKG="chromium"
    else
        CHROMIUM_PKG="chromium-browser"
    fi
    log_info "Selected browser package: $CHROMIUM_PKG"

    log_info "Installing mandatory packages..."
    local pkgs=(
        "$CHROMIUM_PKG"
        "xserver-xorg"
        "x11-xserver-utils"
        "xinit"
        "openbox"
        "unclutter"
        "plymouth"
        "plymouth-themes"
        "network-manager"
    )

    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${pkgs[@]}"
    log_info "Mandatory packages installed successfully."

    # Detect binary path post-installation
    if command -v chromium >/dev/null 2>&1; then
        CHROMIUM_BIN="$(command -v chromium)"
    elif command -v chromium-browser >/dev/null 2>&1; then
        CHROMIUM_BIN="$(command -v chromium-browser)"
    else
        log_err "Failed to locate Chromium binary after installation. Aborting."
        exit 1
    fi
    log_info "Detected browser binary at: $CHROMIUM_BIN"
}
