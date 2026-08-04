# Acceptance Test Checklist

The following tests must be successfully executed on physical hardware (Pi Zero W, Pi 2, Pi 3) before a release candidate is approved.

## 1. Boot Experience
*   [ ] **Silent Boot:** Power on the device. No kernel text, raspberry logos, or blinking cursors appear.
*   [ ] **Splash Screen:** Custom splash image appears within 15 seconds.
*   [ ] **Boot Timing:** Splash screen remains visible until Chromium is fully displayed (no black screen transitions).

## 2. Networking
*   [ ] **Ethernet Priority:** Plug in Ethernet and configure Wi-Fi. Device connects via Ethernet.
*   [ ] **Wi-Fi Fallback:** Unplug Ethernet. Device automatically switches to Wi-Fi.
*   [ ] **Ethernet Recovery:** Plug Ethernet back in. Device routes traffic through Ethernet again.

## 3. Browser & Display
*   [ ] **URL Launch:** Browser loads the exact `URL` specified in `/boot/firmware/abdos.conf`.
*   [ ] **Fullscreen Kiosk:** Browser occupies the entire screen. No tabs, address bars, or window borders.
*   [ ] **Hidden Cursor:** Move the mouse (if attached); cursor does not appear.
*   [ ] **Power Management:** Leave device idle for 60 minutes. Screen does not blank or sleep.
*   [ ] **Cache Behavior:** Modify a webpage, verify change. Reboot Pi. Verify browser loads fresh page without relying on old disk cache.

## 4. Recovery
*   [ ] **Chromium Restart:** SSH in and run `killall chromium-browser`. Browser re-opens automatically within 30 seconds.
*   [ ] **X11 Restart:** SSH in and run `killall Xorg`. Display stack restarts and browser loads.
*   [ ] **Watchdog Reboot:** Trigger a kernel panic (e.g., `echo c > /proc/sysrq-trigger`). Pi hardware resets automatically.

## 5. Security & Appliance Mode
*   [ ] **No Desktop:** Attach keyboard; `Ctrl+Alt+F1`, `Alt+Tab`, `Super` keys do nothing or do not expose a desktop/terminal.
*   [ ] **No Login Prompt:** The screen never displays a `login:` prompt.
*   [ ] **Unwanted Interaction:** Right-clicking the mouse does not bring up a context menu.

## 6. Performance (Pi Zero W Specific)
*   [ ] **RAM Budget:** Verify `free -m` shows > 50MB free RAM while displaying a standard webpage.
*   [ ] **CPU Check:** Verify `htop` shows the system is not consistently pegged at 100% CPU when idle on a static page.
