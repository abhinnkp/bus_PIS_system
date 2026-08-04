#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="/boot/firmware/abdos.conf"

log() {
    logger -t abdos-config "$1"
    echo "abdos-config: $1"
}

# 1. Check if config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    log "ERROR: Configuration file not found at $CONFIG_FILE. Proceeding with defaults."
    exit 0
fi

log "Reading configuration from $CONFIG_FILE"

# Load variables safely (ignore comments and empty lines)
while IFS='=' read -r key value; do
    # Remove leading/trailing whitespace using pure bash (preserves exact spaces within string)
    # Strip leading whitespace
    key="${key#"${key%%[![:space:]]*}"}"
    value="${value#"${value%%[![:space:]]*}"}"
    # Strip trailing whitespace
    key="${key%"${key##*[![:space:]]}"}"
    value="${value%"${value##*[![:space:]]}"}"

    # Strip optional surrounding quotes if present
    value="${value#\"}"
    value="${value%\"}"
    value="${value#\'}"
    value="${value%\'}"

    # Skip comments and empty lines
    [[ "$key" =~ ^#.*$ ]] && continue
    [[ -z "$key" ]] && continue

    export "$key=$value"
done < "$CONFIG_FILE"

# 2. Hostname Configuration
if [[ -n "${HOSTNAME:-}" ]]; then
    if [[ "$HOSTNAME" =~ ^[a-zA-Z0-9-]+$ ]]; then
        if [[ $(hostname) != "$HOSTNAME" ]]; then
            log "Applying hostname: $HOSTNAME"
            hostnamectl set-hostname "$HOSTNAME"
        fi
    else
        log "WARNING: Invalid hostname format '$HOSTNAME'. Skipping."
    fi
fi

# 3. Timezone Configuration
if [[ -n "${TIMEZONE:-}" ]]; then
    if [[ -f "/usr/share/zoneinfo/$TIMEZONE" ]]; then
        current_tz=$(timedatectl show -p Timezone --value)
        if [[ "$current_tz" != "$TIMEZONE" ]]; then
            log "Applying timezone: $TIMEZONE"
            timedatectl set-timezone "$TIMEZONE"
        fi
    else
        log "WARNING: Invalid timezone '$TIMEZONE'. Skipping."
    fi
fi

# 4. SSH Configuration
SSH_STATUS=${SSH_ENABLED:-true}
if [[ "${SSH_STATUS,,}" == "true" ]]; then
    if ! systemctl is-enabled ssh >/dev/null 2>&1; then
        log "Enabling SSH daemon"
        systemctl enable ssh >/dev/null 2>&1 || true
        systemctl start ssh || true
    fi
else
    if systemctl is-enabled ssh >/dev/null 2>&1; then
        log "Disabling SSH daemon"
        systemctl stop ssh || true
        systemctl disable ssh >/dev/null 2>&1 || true
    fi
fi

# 5. Dynamic Splash Image Configuration
# Only attempt to update if the file exists and is different from the currently installed theme image.
PLYMOUTH_THEME_IMG="/usr/share/plymouth/themes/pix/splash.png"
SPLASH_IMG=${SPLASH_IMAGE:-/boot/firmware/splash.png}

if [[ -f "$SPLASH_IMG" ]]; then
    if [[ -f "$PLYMOUTH_THEME_IMG" ]]; then
        # Compare files to avoid unnecessary initramfs rebuilds (which are slow and write heavy)
        if ! cmp -s "$SPLASH_IMG" "$PLYMOUTH_THEME_IMG"; then
            log "Updating Plymouth splash image from $SPLASH_IMG"
            cp "$SPLASH_IMG" "$PLYMOUTH_THEME_IMG"
            # Rebuild initramfs in the background so it doesn't delay the current boot sequence
            log "Rebuilding initramfs in background..."
            update-initramfs -u >/dev/null 2>&1 &
        fi
    else
        log "Plymouth pix theme not found. Splash image update skipped."
    fi
fi

# 6. NetworkManager Configuration
# Ensure NM is running before attempting to use nmcli
if systemctl is-active --quiet NetworkManager; then

    # Configure Wi-Fi
    if [[ -n "${WIFI_SSID:-}" ]]; then
        # Check if connection already exists and if the SSID matches
        CURRENT_SSID=$(nmcli -t -f 802-11-wireless.ssid connection show "abdos-wifi" 2>/dev/null || true)

        if [[ "$CURRENT_SSID" != "$WIFI_SSID" ]]; then
            log "Configuring Wi-Fi network: $WIFI_SSID"
            if nmcli -t -f NAME connection show | grep -qx "abdos-wifi"; then
                nmcli connection delete "abdos-wifi" >/dev/null 2>&1 || true
            fi

            if [[ -n "${WIFI_PASSWORD:-}" ]]; then
                nmcli connection add type wifi ifname wlan0 con-name "abdos-wifi" ssid "$WIFI_SSID" \
                    wifi-sec.key-mgmt wpa-psk wifi-sec.psk "$WIFI_PASSWORD" \
                    connection.autoconnect yes >/dev/null 2>&1 || log "Failed to configure Wi-Fi"
            else
                nmcli connection add type wifi ifname wlan0 con-name "abdos-wifi" ssid "$WIFI_SSID" \
                    connection.autoconnect yes >/dev/null 2>&1 || log "Failed to configure open Wi-Fi"
            fi
        else
            log "Wi-Fi network $WIFI_SSID is already configured. Skipping."
        fi
    else
        # If WIFI_SSID is empty, remove the old profile if it exists
        if nmcli -t -f NAME connection show | grep -qx "abdos-wifi"; then
            log "Removing Wi-Fi configuration (WIFI_SSID is empty)"
            nmcli connection delete "abdos-wifi" >/dev/null 2>&1 || true
        fi
    fi

    # Configure Ethernet Priority
    ETH_PRIORITY=${ETHERNET_PRIORITY:-true}
    # Create or update default ethernet profile metric
    if nmcli -t -f NAME connection show | grep -qx "Wired connection 1"; then
        if [[ "${ETH_PRIORITY,,}" == "true" ]]; then
            # Set route metric lower (higher priority)
            nmcli connection modify "Wired connection 1" ipv4.route-metric 100 >/dev/null 2>&1 || true
            nmcli connection modify "abdos-wifi" ipv4.route-metric 200 >/dev/null 2>&1 || true
        else
            # Set route metric higher (lower priority)
            nmcli connection modify "Wired connection 1" ipv4.route-metric 200 >/dev/null 2>&1 || true
            nmcli connection modify "abdos-wifi" ipv4.route-metric 100 >/dev/null 2>&1 || true
        fi
    fi
else
    log "WARNING: NetworkManager is not active. Network configurations skipped."
fi

log "Configuration applied successfully."
exit 0
