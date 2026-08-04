# Security and Hardening

ABDOS is an appliance OS. Security is centered around preventing physical tampering and minimizing attack surfaces on the network.

## 1. Attack Surface Reduction
*   **Minimal Packages:** Only absolute necessities are installed (no desktop environment, no unnecessary utilities).
*   **Disabled Services:** Bluetooth, mDNS (Avahi), and unneeded daemons are disabled.
*   **Appliance Behavior:** The system boot directly to a fullscreen browser. There is no Window Manager interface (menus, taskbars) accessible to the user.

## 2. Access Control
*   **SSH Access:** Disabled by default unless `SSH_ENABLED=true` in `abdos.conf`. If enabled, standard Pi OS credentials/keys apply. It is strongly recommended to change default passwords or use SSH keys.
*   **No Local Console:** Boot parameters disable local TTY switching (e.g., Ctrl+Alt+F1). No login prompts are displayed on the HDMI output.
*   **No Screen Locking:** As a kiosk, the display must remain on 24/7. Screen lockers and power management (DPMS) are explicitly disabled.

## 3. Peripheral Restrictions
*   **Keyboard/Mouse:** While `unclutter` hides the mouse cursor (`CURSOR=false`), the system does not explicitly disable USB input devices at the kernel level in V1 to allow emergency debugging. However, the UI (Chromium) is locked down to prevent navigation.
*   **USB Automount:** Desktop file managers are not installed, so USB drives inserted into the Pi will not automount or display popups on the screen.

## 4. Browser Hardening
Chromium is launched with flags to disable:
*   Translation infobars.
*   "Restore Session" dialogs after a crash.
*   Developer tools (F12).
*   Context menus (right-click).

## 5. File Permissions
*   `/boot/firmware/abdos.conf` contains sensitive information (Wi-Fi passwords). While it is on a FAT32 partition, physical access to the SD card compromises this data. This is an accepted risk for offline provisioning.

## 6. Future Considerations
*   Read-only root filesystem (OverlayFS) to prevent any persistent tampering.
*   Disabling USB ports entirely via `udev` rules.
*   Enforcing HTTPS-only URLs in configuration.
