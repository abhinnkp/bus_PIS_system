# Installer Design

The ABDOS installer (`install.sh`) is the core mechanism that transforms a generic Raspberry Pi OS Lite image into the dedicated kiosk appliance.

## 1. Installation Flow
1.  **Pre-flight Checks:** Verify OS version (Bookworm 32-bit), check for root privileges, verify internet connectivity (for `apt`).
2.  **Package Management:** Run `apt update` and install mandatory packages defined in the SBOM (e.g., `chromium`, `plymouth`, `openbox`).
3.  **Service Disablement:** Mask or disable unnecessary services (e.g., `bluetooth`, `avahi-daemon`) to meet performance targets.
4.  **File Deployment:** Copy scripts to `/usr/local/bin/` and systemd units to `/etc/systemd/system/`.
5.  **Configuration Seeding:** Copy `config/abdos.conf.template` to `/boot/firmware/abdos.conf` if it doesn't already exist.
6.  **Boot Modification:** Append required flags for silent boot to `/boot/firmware/cmdline.txt` (ensuring no duplicates).
7.  **Service Enablement:** Enable custom ABDOS systemd services.
8.  **Cleanup:** Clear apt cache to save space. Prompt for reboot.

## 2. Idempotency
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
