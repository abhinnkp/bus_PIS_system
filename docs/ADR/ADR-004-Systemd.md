# ADR-004: Service Management

## Context
The appliance requires strict ordering of events (Config -> Network -> Display) and automatic recovery if components crash.

## Problem Statement
How do we orchestrate the startup sequence and monitor the health of the kiosk application?

## Decision
Leverage the native **systemd** init system with custom unit files (`abdos-config.service`, `abdos-kiosk.service`).

## Alternatives Considered
*   **Custom Python/Bash daemon (rc.local or cron @reboot):**
    *   *Disadvantage:* `rc.local` is deprecated. Custom daemons require reinventing process supervision, dependency management, and logging.
*   **Supervisord / PM2:**
    *   *Disadvantage:* Adds unnecessary package weight and memory overhead when systemd is already running as PID 1.

## Advantages
*   Zero additional memory overhead (systemd is already running).
*   Built-in process restart capabilities (`Restart=always`).
*   Robust dependency definitions (`After=network-online.target`).
*   Standardized logging via `journalctl`.

## Disadvantages
*   systemd unit files can be complex to debug if dependency cycles occur.

## Future Considerations
While V1 uses shell scripts wrapped in systemd, V2 might replace the shell scripts with a single Go/Rust binary (Kiosk Manager) managed by a single systemd unit.
