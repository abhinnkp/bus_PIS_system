# ADR-006: Hardware Watchdog Integration

## Context
ABDOS devices will be deployed in hard-to-reach locations (e.g., mounted high on a bus stop). Physical power cycling is expensive and slow.

## Problem Statement
How do we ensure the device recovers automatically if the Linux kernel panics or the system completely locks up?

## Decision
Utilize the Raspberry Pi's internal **BCM2835 hardware watchdog timer**, managed by `systemd`.

## Alternatives Considered
*   **External Watchdog Timer (Hardware module):**
    *   *Disadvantage:* Increases BOM (Bill of Materials) cost and requires custom wiring.
*   **Software-only daemon (`watchdog` package):**
    *   *Disadvantage:* Unnecessary package if systemd can ping the hardware device natively.

## Advantages
*   Zero cost (built into the Pi SoC).
*   Native systemd integration (`RuntimeWatchdogSec=15` in `/etc/systemd/system.conf`).
*   Guarantees a hard reset if the OS hangs and stops pinging the watchdog.

## Disadvantages
*   Requires editing systemd core configuration.
*   If systemd gets stuck but the kernel is fine, it will still reboot the system (which is actually desired behavior for a kiosk).

## Future Considerations
The watchdog simply resets the hardware. The root cause of the freeze (e.g., thermal throttling, bad power supply) must be diagnosed via persistent logs if freezes become frequent.
