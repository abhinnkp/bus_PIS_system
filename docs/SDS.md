# Software Design Specification (SDS)

## 1. Introduction
This document outlines the software design and architecture of the Amnex Bus Display OS (ABDOS) v1.0. The design strictly adheres to an embedded appliance philosophy, prioritizing extreme resource efficiency for the Raspberry Pi Zero W, 24x7 stability, and configuration-driven modularity.

## 2. Core Architecture

### 2.1 Configuration-Driven Architecture
All behavior is controlled by `/boot/firmware/abdos.conf`. No hardcoded values exist in the shell scripts or systemd services. The configuration file acts as the single source of truth and the primary interface for system administrators.

### 2.2 Boot and Initialization Sequence
1.  **Bootloader/Kernel:** Silent boot via `cmdline.txt` adjustments (`quiet splash loglevel=0 vt.global_cursor_default=0`).
2.  **Plymouth:** Displays the custom splash image.
3.  **NetworkManager:** Initializes network interfaces, prioritizing Ethernet and handling DHCP/Wi-Fi.
4.  **systemd Services (Delayed Start):** The kiosk services wait for the network to be online before launching the display stack.
5.  **Display Stack:** Minimal X11 server starts with Openbox (Window Manager).
6.  **Browser:** Chromium launches in kiosk mode.
7.  **Splash Removal:** Plymouth is terminated seamlessly once Chromium is up.

## 3. Service Startup Strategy
To minimize peak memory usage and CPU contention during boot on the Pi Zero W:
*   **Dependency Chains:** Services strictly depend on prerequisites. The Kiosk service requires `network-online.target`.
*   **Disabled Services:** Unnecessary default daemons (e.g., Bluetooth, Avahi if not needed) are disabled to free RAM and speed up boot.
*   **Delayed Non-Critical Services:** Background tasks (like log rotation or watchdog pings, if script-based) start only after the browser is running.

## 4. Subsystem Design

### 4.1 Networking
Managed entirely by `NetworkManager`. Connection profiles are generated or updated based on `abdos.conf` during the startup phase or via a dedicated configuration application service.

### 4.2 Display and Kiosk
*   **X11 Server:** Started without a login manager (no LightDM/GDM). `xinit` or a systemd service directly invokes the X server.
*   **Window Manager:** `openbox` provides a minimal environment to handle window placement (fullscreen).
*   **Cursor Management:** `unclutter` hides the mouse cursor.
*   **Power Management:** `xset` disables DPMS, screen blanking, and screensavers.

### 4.3 Long-Term Stability & Watchdog
*   **Hardware Watchdog:** `/dev/watchdog` enabled via `systemd` to catch kernel panics or severe system hangs.
*   **Service Restarts:** systemd manages the `kiosk.service` with `Restart=always` to handle browser or X11 crashes.
*   **Memory Management:** RAM-backed `/tmp` and browser cache (`--disk-cache-dir=/tmp/chromium`) prevent SD card wear and ensure a clean state on reboot.

## 5. Future Architecture: Kiosk Manager
While V1 uses simple bash scripts and systemd to launch Chromium directly, the architecture anticipates a lightweight, compiled (or efficient scripting language) "Kiosk Manager" daemon in the future.
*   **Role:** Replace complex shell scripts to handle configuration validation, network readiness checks, browser process monitoring, and health reporting.
*   **Benefits:** Better error handling, remote management API endpoints, and tighter control over the browser lifecycle.
