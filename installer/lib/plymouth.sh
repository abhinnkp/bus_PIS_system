#!/usr/bin/env bash

configure_plymouth() {
    log_info "Configuring custom Plymouth splash image..."
    local available_themes
    available_themes=$(plymouth-set-default-theme -l 2>/dev/null || true)
    local selected_theme=""

    for t in pix spinner tribar; do
        if echo "$available_themes" | grep -q "^$t$"; then
            selected_theme="$t"
            break
        fi
    done

    if [[ -n "$selected_theme" ]]; then
        local theme_dir="/usr/share/plymouth/themes/$selected_theme"
        if [[ -d "$theme_dir" ]]; then
            for img in splash.png watermark.png box.png; do
                if [[ -f "$theme_dir/$img" ]]; then
                    backup_file "$theme_dir/$img"
                    cp "/boot/firmware/splash.png" "$theme_dir/$img" 2>/dev/null || true
                fi
            done
        fi
        log_info "Setting plymouth theme to $selected_theme and rebuilding initramfs..."
        plymouth-set-default-theme -R "$selected_theme" || true
        log_info "Successfully configured Plymouth."
    else
        log_warn "No suitable plymouth theme found. Splash screen may not display custom image."
    fi

    # Boot Modification (cmdline.txt)
    local cmdline_file="/boot/firmware/cmdline.txt"
    if [[ -f "$cmdline_file" ]]; then
        log_info "Configuring silent boot parameters in cmdline.txt..."
        backup_file "$cmdline_file"
        local cmdline
        cmdline=$(cat "$cmdline_file")

        local flags="quiet splash loglevel=0 vt.global_cursor_default=0 logo.nologo consoleblank=0"
        for flag in $flags; do
            if ! echo "$cmdline" | grep -q -w "$flag"; then
                cmdline="$cmdline $flag"
            fi
        done

        # Remove all console entries
        cmdline=$(echo "$cmdline" | sed -E 's/console=[a-zA-Z0-9,]+//g' | xargs)

        echo "$cmdline" > "$cmdline_file"
        log_info "Successfully updated $cmdline_file"
    else
        log_err "$cmdline_file not found! Are you on Raspberry Pi OS Bookworm?"
    fi
}
