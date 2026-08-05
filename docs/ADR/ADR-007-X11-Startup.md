# ADR-007: X11 Startup Architecture

## Context
During Alpha-1 hardware validation on a Raspberry Pi 3, the `abdos-kiosk.service` failed to launch Xorg. The journal logged:
`/usr/lib/xorg/Xorg.wrap: Only console users are allowed to run the X server`
This caused `xinit` to hang and Chromium never launched.

## Problem Statement
How do we reliably start a rootless X11 server from a systemd background service (without an interactive TTY console user) without installing a heavy Display Manager (like LightDM) that would compromise our RAM and CPU budgets on the Pi Zero W?

## Decision
Modify `/etc/X11/Xwrapper.config` during installation to set `allowed_users=anybody`.

## Alternatives Considered
*   **Install a Display Manager (LightDM / nodm):**
    *   *Disadvantage:* Display managers consume significant RAM (20MB+), increase boot time, and often pull in unnecessary desktop dependencies. `nodm` is deprecated.
*   **Run Xorg as Root:**
    *   *Disadvantage:* Massive security violation. The web browser and X server should run as an unprivileged user (`pi` or equivalent).
*   **Logind `PAMName=login` Hack:**
    *   *Context:* We attempted to spoof a console session in Alpha-1 using systemd `TTYPath=/dev/tty1` and `PAMName=login`.
    *   *Disadvantage:* Modern systemd/logind combinations are increasingly strict about what constitutes an active session seat. Background services often fail to acquire DRM/KMS master rights even with PAM overrides.

## Advantages
*   **Reliability:** Explicitly telling the X wrapper to allow any user (including our background systemd user) is the officially supported Xorg method for headless/kiosk environments.
*   **Performance:** Zero additional runtime dependencies. No RAM overhead.
*   **Compatibility:** Works across all Raspberry Pi hardware (Zero W through 5) running Bookworm.

## Disadvantages
*   **Security:** Technically allows any SSH user to attempt to start an X server. However, in our appliance context where SSH is disabled by default and the device is locked down, this is an acceptable and necessary trade-off for appliance operation.

## Implementation
The installer (`installer/lib/x11.sh`) will idempotently generate or append to `/etc/X11/Xwrapper.config` and the uninstaller will restore it.
