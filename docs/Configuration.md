# Configuration Guide

All configuration for the ABDOS appliance is managed through a single file located on the boot partition:
`/boot/firmware/abdos.conf`

This file uses a standard bash-sourceable key-value format. No spaces are allowed around the `=` sign.

## Configuration Parameters

| Parameter | Type | Default | Required | Validation Rules | Description | Example |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `URL` | String | `http://localhost` | Yes | Must be a valid HTTP/HTTPS URL | The webpage the kiosk will display. | `URL=https://example.com` |
| `HOSTNAME` | String | `abdos-display` | No | Valid hostname characters (a-z, 0-9, -) | The network hostname of the device. | `HOSTNAME=BUS-DISPLAY-001` |
| `ETHERNET_PRIORITY`| Boolean| `true` | No | `true` or `false` | Prefer Ethernet over Wi-Fi when both are available. | `ETHERNET_PRIORITY=true` |
| `WIFI_SSID` | String | (empty) | No | Any string | Wi-Fi network name. | `WIFI_SSID=DepotWiFi` |
| `WIFI_PASSWORD` | String | (empty) | No | String | Wi-Fi network password. | `WIFI_PASSWORD=secret123` |
| `TIMEZONE` | String | `Etc/UTC` | No | Valid tz database name | System timezone. | `TIMEZONE=Asia/Kolkata` |
| `SPLASH_IMAGE` | String | `/boot/firmware/splash.png`| No | Valid absolute path | Path to the boot splash image. | `SPLASH_IMAGE=/boot/firmware/splash.png` |
| `SSH_ENABLED` | Boolean| `true` | No | `true` or `false` | Enable or disable the SSH daemon. | `SSH_ENABLED=true` |
| `WATCHDOG` | Boolean| `true` | No | `true` or `false` | Enable the hardware watchdog. | `WATCHDOG=true` |
| `CURSOR` | Boolean| `false` | No | `true` or `false` | Show or hide the mouse cursor. | `CURSOR=false` |
| `CACHE_MODE` | String | `ram` | No | `ram` or `clear` | How browser cache is handled across boots. | `CACHE_MODE=ram` |

## Modifying Configuration
1. Power off the Raspberry Pi and remove the SD card.
2. Insert the SD card into a PC/Mac.
3. Open the `boot` (or `bootfs`) partition.
4. Edit `abdos.conf` with a text editor.
5. Save, eject, and boot the Pi. Configurations are applied automatically during startup.
