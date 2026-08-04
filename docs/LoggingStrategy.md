# Logging Strategy

In an embedded appliance running 24/7, excessive logging degrades performance and severely limits the lifespan of the SD card due to constant write operations.

## 1. Production Logging Policy
*   **Minimal Writes:** Applications and scripts must only log errors or critical state changes. Debug or informational logging must be disabled by default.
*   **systemd Journal:** All logging is routed through `systemd-journald`. Custom scripts should use `logger` or output to stdout/stderr so systemd captures it.

## 2. RAM-Based Logging
To prevent SD card wear, the system journal is configured to store logs primarily in RAM (tmpfs).
*   **Configuration:** `/etc/systemd/journald.conf`
*   **Setting:** `Storage=volatile`
*   **Behavior:** Logs are stored in `/run/log/journal/`. They are fast to write, consume a small, capped amount of RAM, and are completely wiped upon reboot.

## 3. Persistent Logging (Optional)
For debugging specific deployment issues where crash logs need to survive a reboot (e.g., watchdog resets):
*   A configuration flag (e.g., `PERSISTENT_LOGS=true` - future enhancement) could change `Storage=persistent`.
*   Even if persistent, `SystemMaxUse=50M` and `MaxRetentionSec=1week` must be strictly enforced to prevent filesystem exhaustion.
*   **V1 Default:** `Storage=volatile`.

## 4. Log Rotation
If persistent logging is enabled, standard `logrotate` configurations must be applied to `/var/log/messages`, `/var/log/syslog`, etc. However, switching to purely `journald` with volatile storage largely mitigates this need.

## 5. Application Logging (Chromium)
Chromium generates significant log output by default.
*   Launch flags include: `--log-level=3` (Fatal errors only) and `--enable-logging=stderr`.
*   Output is captured by the systemd `abdos-kiosk.service` and kept in the volatile journal.
