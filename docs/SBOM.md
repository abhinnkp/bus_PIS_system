# Software Bill of Materials (SBOM)

This document lists the mandatory and optional software packages installed by the ABDOS installer on top of the base Raspberry Pi OS Lite image.

*Target Base: Raspberry Pi OS Lite (Bookworm, 32-bit)*

| Package Name | Purpose | Mandatory / Optional | Installation Source | Expected Version | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `chromium-browser`| Kiosk display engine | Mandatory | apt (Raspberry Pi Repo) | Latest Bookworm | Hardware accelerated version preferred. |
| `xserver-xorg` | Base graphical display | Mandatory | apt | Latest | Minimal X11 server. |
| `x11-xserver-utils`| Display control (`xset`) | Mandatory | apt | Latest | Used to disable DPMS and screen blanking. |
| `xinit` | X11 initialization | Mandatory | apt | Latest | Used to start the X session. |
| `openbox` | Minimal Window Manager | Mandatory | apt | Latest | Ensures Chromium stays fullscreen without borders. |
| `unclutter` | Cursor hiding | Mandatory | apt | Latest | Hides the mouse cursor after inactivity. |
| `plymouth` | Boot splash screen | Mandatory | apt | Latest | Replaces boot logs with a custom image. |
| `plymouth-themes` | Plymouth themes | Mandatory | apt | Latest | Provides the framework for custom images. |
| `network-manager`| Network management | Mandatory | pre-installed | Latest | Base OS default, but explicitly verified. |
| `watchdog` | Hardware watchdog daemon | Optional | apt | Latest | (V1 uses systemd's built-in watchdog capability instead of this package, but listed for reference). |

## Justification for Minimization
No desktop environment packages (e.g., `lxde`, `pi-greeter`, `lightdm`) are installed. This saves over 500MB of disk space and significantly reduces RAM usage, ensuring the appliance fits within the Pi Zero W budgets.
