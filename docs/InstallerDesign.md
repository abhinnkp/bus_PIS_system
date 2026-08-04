# Installer Design

The ABDOS installer (`install.sh`) is the core mechanism that transforms a generic Raspberry Pi OS Lite image into the dedicated kiosk appliance.

## 1. Installation Flow
1.  **Pre-flight Checks:** Verify root privileges.
2.  **Dynamic Runtime Detection:** Detect the primary interactive user (via `SUDO_USER` or UID 1000) and Chromium package type. Validate the user and home directory.
3.  **Package Management:** Install packages defined in the SBOM dynamically based on availability.
4.  **Service Disablement:** Mask unnecessary services (e.g., `bluetooth`, swap) to meet Pi Zero W performance constraints.
5.  **Template Rendering:** Render systemd unit files and shell script templates (`.in`), injecting the detected `@USER@`, `@HOME@`, and `@CHROMIUM_BIN@` to keep source files deployment-agnostic. Deploy to `/usr/local/bin/` and `/etc/systemd/system/`.
6.  **Configuration Seeding:** Seed `/boot/firmware/abdos.conf` if missing.
7.  **Boot & Plymouth Modification:** Safely modify `cmdline.txt` (after backing it up). Detect the active Plymouth theme and inject the custom splash image.
8.  **Service Enablement:** Enable tmpfs (`tmp.mount`), volatile logging, and kiosk services.
9.  **Cleanup:** Clear apt cache to save space.

## 2. Idempotency and Rollback
The installer creates `.abdos.bak` backups of all modified system files (e.g., `cmdline.txt`, `system.conf`, `journald.conf`) prior to editing. The script uses robust text processing (`sed`, `grep`) to ensure it can be re-run safely multiple times.
The installer must be idempotent. Running it multiple times on the same system must not cause failures, duplicate configurations in `cmdline.txt`, or broken states.
*   Use `grep` before appending to files.
*   Use `cp -f` to overwrite older scripts.
*   Use `systemctl enable --now` safely.

## 3. Validation
At the end of the installation, a brief validation routine should check:
*   Are required files in `/usr/local/bin`?
*   Are systemd services enabled?
*   Is `/boot/firmware/abdos.conf` present?

## 4. Failure Handling
*   If `apt install` fails (e.g., repository down), the script must exit immediately with a non-zero code (`set -e`) and explain the failure.
*   No partial installations. While true transactionality is hard in bash, the script should fail fast.

## 5. Rollback Strategy
V1 does not include an automated rollback script. Since the base is an SD card image, the rollback strategy is to flash a fresh Pi OS Lite image and run the installer again.
