# Network Behavior

ABDOS networking is entirely managed by `NetworkManager`. The primary goal is reliable, automatic connectivity with zero user interaction after the initial configuration.

## 1. NetworkManager Backend
Raspberry Pi OS Lite (Bookworm) uses NetworkManager by default. ABDOS leverages this by mapping configurations from `/boot/firmware/abdos.conf` to NetworkManager profiles using `nmcli`.

## 2. Priority and Fallback Logic

### Scenario A: Ethernet Only
If an Ethernet cable is connected and provides DHCP, NetworkManager automatically prioritizes it over Wi-Fi due to default metric routing.

### Scenario B: Wi-Fi Only
If `WIFI_SSID` and `WIFI_PASSWORD` are defined in the config, the `abdos-config.service` generates a NetworkManager connection profile. If Ethernet is unplugged, NetworkManager connects to the configured Wi-Fi.

### Scenario C: Ethernet and Wi-Fi Available
If `ETHERNET_PRIORITY=true` (default), NetworkManager routes traffic through the Ethernet interface (eth0). If the Ethernet link goes down (cable unplugged), NetworkManager seamlessly fails over to the configured Wi-Fi (wlan0). If Ethernet is plugged back in, routing shifts back to Ethernet.

## 3. Network Dependency
The display stack (`abdos-kiosk.service`) is configured in systemd to require `network-online.target`. Chromium will not attempt to load the configured `URL` until NetworkManager signals that an active connection exists.

## 4. Future Static IP Support
While Version 1 relies on DHCP, the architecture abstracts network profile creation via `abdos-config.sh`. In future versions, adding `STATIC_IP`, `GATEWAY`, and `DNS` to the config file will simply require an update to the script to pass those parameters to `nmcli`.
