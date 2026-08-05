# Hardware Validation (Alpha-2)

This document tracks findings from physical hardware validations and defines the test checklist for release candidates.

## 1. Alpha-1 Findings & Corrective Actions
Validation was performed on a Raspberry Pi 3 running Raspberry Pi OS Lite Bookworm (32-bit).

| Finding | Root Cause Analysis | Corrective Action in Alpha-2 |
| :--- | :--- | :--- |
| **Xorg failed to start** (`Only console users are allowed...`) | Bookworm defaults Xorg to require an interactive physical TTY console session. Background systemd services run by `pi` fail this check. | Configured `/etc/X11/Xwrapper.config` with `allowed_users=anybody` during installation (See ADR-007). |
| **`sudo` host resolution warning** | Changing hostname without updating `/etc/hosts` caused local resolution to fail temporarily. | Updated `abdos-config.sh` to update both files atomically and rollback if resolution fails. |
| **Kiosk Service restart loops on failure** | The systemd unit did not distinguish between recoverable crashes (Xorg segfault) and fatal configuration errors (binary missing). | Added `RestartPreventExitStatus=2` and strict stage-by-stage validation logic in `abdos-kiosk.sh`. |

## 2. Alpha-2 Hardware Validation Checklist

### Boot & Environment
*   [ ] **Silent Boot:** No Linux console text or flashing cursor is visible during boot.
*   [ ] **Splash Screen:** Custom splash image appears and smoothly transitions directly into Chromium without a black screen delay.
*   [ ] **Boot Time:** System reaches fully rendered webpage in acceptable time based on hardware limits.

### Network Resiliency
*   [ ] **Ethernet Preference:** If Ethernet is connected, it is used.
*   [ ] **Wi-Fi Fallback:** If Ethernet is unplugged, system fails over to Wi-Fi seamlessly.
*   [ ] **DHCP Recovery:** Unplugging the router and plugging it back in allows the system to recover IP and load the page.

### Browser & Display
*   [ ] **Launch:** Chromium launches fullscreen to the configured URL.
*   [ ] **UI Lockdown:** No cursor, no tabs, no address bar, no right-click context menu, no error dialogs.
*   [ ] **Crash Recovery:** Running `killall chromium-browser` via SSH results in a rapid, automatic restart of the browser.

### Reliability (24x7 Operations)
*   [ ] **Power Loss:** Unplugging power randomly and reconnecting does not corrupt the SD card or result in unbootable states.
*   [ ] **Watchdog:** Forcing a kernel panic triggers a hardware reboot within 15 seconds.
*   [ ] **RAM Usage (Idle):** `htop` confirms stable memory usage matching `PerformanceTargets.md`.

### Hardware Targets to Test
*   [ ] Raspberry Pi Zero W (Validate ARMv6 rejection logic).
*   [ ] Raspberry Pi 2 Model B.
*   [ ] Raspberry Pi 3 Model B/B+.
