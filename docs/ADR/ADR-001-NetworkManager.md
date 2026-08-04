# ADR-001: Networking Backend Selection

## Context
ABDOS requires a reliable networking backend that handles automatic Ethernet preference, Wi-Fi failover, and headless configuration via a single text file.

## Problem Statement
We need to select a networking manager for Raspberry Pi OS Lite (Bookworm) that is stable, supports our failover logic automatically, and can be easily manipulated via shell scripts.

## Decision
Use **NetworkManager** (`nmcli`) as the sole networking backend.

## Alternatives Considered
*   **systemd-networkd & wpa_supplicant:** The traditional headless Pi approach.
    *   *Disadvantage:* Implementing reliable, automatic Ethernet-to-Wi-Fi fallback requires complex custom shell scripting or bonding configurations which are prone to edge-case failures.
*   **dhcpcd:** The old Pi OS default.
    *   *Disadvantage:* Deprecated in Bookworm in favor of NetworkManager.

## Advantages
*   It is the official default in Raspberry Pi OS Bookworm.
*   Automatic, out-of-the-box routing metrics prioritize Ethernet over Wi-Fi.
*   Handles link state changes (plugging/unplugging) instantly without custom polling scripts.
*   Provides a powerful CLI (`nmcli`) for easy profile generation from `abdos.conf`.
*   Future-proof for adding VPNs or static IPs.

## Disadvantages
*   Slightly higher memory footprint than `systemd-networkd` (~15MB vs ~5MB).

## Future Considerations
If memory becomes critically constrained on the Pi Zero W (below the 50MB free threshold), we may need to investigate downgrading to `systemd-networkd`, but the current budget allows for NetworkManager's stability benefits.
