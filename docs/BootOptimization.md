# Boot Optimization

Optimizing the boot process is critical for achieving a seamless appliance experience, particularly on the resource-constrained Raspberry Pi Zero W.

## 1. Silent Boot Implementation
To hide standard Linux boot output:
*   `/boot/firmware/cmdline.txt` is modified to include:
    `quiet splash loglevel=0 vt.global_cursor_default=0 logo.nologo consoleblank=0`
*   `console=tty1` is removed or redirected to `/dev/null` if necessary, to prevent text output on the primary display.

## 2. Splash Screen Timing (Plymouth)
*   **Tool:** `plymouth` with the `script` plugin or a basic image viewer plugin.
*   **Goal:** Display the image as early as possible in the boot process.
*   **Transition:** The standard `plymouth-quit.service` drops the splash screen before the X server starts, resulting in a black screen. ABDOS overrides this behavior. The splash screen remains active until the `abdos-kiosk.service` successfully starts Chromium and explicitly calls `plymouth quit`.

## 3. Service Startup Order
*   Avoid starting non-essential services.
*   Delay network-dependent services until `network-online.target` is reached.
*   Ensure `abdos-config.service` (which parses configurations) runs *before* NetworkManager reads its profiles.

## 4. Boot Timing Goals (Target: Pi Zero W)
*   **Power On to Splash Screen:** < 15 seconds.
*   **Splash Screen to Network Ready:** < 45 seconds.
*   **Network Ready to Browser Fully Rendered:** < 90 seconds.
*(Note: These are initial targets and will be refined during physical hardware validation).*
