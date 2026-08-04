# ADR-003: Configuration File Location and Format

## Context
Deploying hundreds of displays requires an easy way to provision devices offline before they are booted for the first time.

## Problem Statement
Where should the configuration file live, and what format should it use to balance ease of use for humans and ease of parsing for the OS?

## Decision
Use a simple `KEY=value` text file named `abdos.conf` located on the `/boot/firmware` partition.

## Alternatives Considered
*   **JSON/YAML in `/etc/abdos/`:**
    *   *Disadvantage:* Requires booting the Pi or using a Linux machine to mount the ext4 partition. Requires external parsers (`jq`, `yq`) which add overhead.
*   **Database (SQLite):**
    *   *Disadvantage:* Overkill for V1. Hard to edit manually.

## Advantages
*   `/boot/firmware` is a FAT32 partition. It automatically mounts on Windows, macOS, and Linux when the SD card is plugged in via USB.
*   The `KEY=value` format can be natively sourced in bash scripts (`source /boot/firmware/abdos.conf`), requiring zero external dependencies.

## Disadvantages
*   Security: FAT32 does not support Linux file permissions. Anyone with physical access to the SD card can read Wi-Fi passwords. (Accepted risk for physical appliances).
*   Bash sourcing is dangerous if the file contains malicious commands. The parsing script must validate the file rather than directly executing it if untrusted input is expected.

## Future Considerations
If complex nested configurations (e.g., multiple Wi-Fi networks with priority) are needed in V2, we may migrate to JSON and use a compiled Kiosk Manager to parse it, but the file will remain on the `/boot/firmware` partition.
