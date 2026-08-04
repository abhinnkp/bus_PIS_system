# Troubleshooting Guide

This guide helps diagnose common issues with the ABDOS appliance.

## 1. Accessing the System
Because the appliance has no terminal or desktop, you must access it via SSH over the network.
*   Find the Pi's IP address on your DHCP server/router.
*   `ssh pi@<ip-address>` (using the credentials set when flashing the OS).

## 2. Common Issues

### Issue: The screen stays black after the splash image.
*   **Cause:** Chromium failed to start or X11 failed.
*   **Diagnosis:**
    ```bash
    systemctl status abdos-kiosk.service
    journalctl -u abdos-kiosk.service -n 50
    ```
*   **Resolution:** Check for GPU memory limits, invalid Chromium flags, or ensure `network-online.target` was actually reached.

### Issue: Chromium shows a "No Internet" dinosaur page.
*   **Cause:** Network drop after the browser launched, or a DNS resolution failure.
*   **Diagnosis:** Check network status: `nmcli d`. Ping a known external IP (e.g., `8.8.8.8`). Ping a domain (e.g., `google.com`).
*   **Resolution:** Verify `WIFI_PASSWORD` in `/boot/firmware/abdos.conf`. Restart the kiosk service: `sudo systemctl restart abdos-kiosk.service`.

### Issue: The system reboots randomly.
*   **Cause:** Hardware watchdog timeout due to a system freeze, or power supply issues.
*   **Diagnosis:** Check for under-voltage warnings: `dmesg | grep -i voltage`. Check journal for kernel panics before previous boot.
*   **Resolution:** Use a higher quality power supply (5V 2.5A+ for Pi Zero/3). Reduce rendering load in the displayed webpage to prevent thermal throttling.

### Issue: Wi-Fi won't connect.
*   **Cause:** Incorrect SSID/Password, or hidden network.
*   **Diagnosis:** `journalctl -u NetworkManager`.
*   **Resolution:** Re-edit `/boot/firmware/abdos.conf` carefully. Note that V1 script logic may require manual NM profile deletion if changing SSIDs frequently, though the config script should ideally handle updates.
