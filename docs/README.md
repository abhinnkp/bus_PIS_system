# Amnex Bus Display OS (ABDOS)

**Version:** 1.0
**Target Hardware:** Raspberry Pi Zero W, 2 Model B, 3 Model B/B+
**Base OS:** Raspberry Pi OS Lite (Bookworm, 32-bit)

## 1. Project Overview
ABDOS is a production-ready embedded kiosk operating system. It converts a standard Raspberry Pi into a dedicated, single-purpose appliance that boots silently, manages network connectivity automatically, and displays a configurable web page in a locked-down Chromium browser. It is specifically designed for public transportation environments like bus stations and passenger information systems.

## 2. Features
*   **Silent Boot:** No kernel logs, no blinking cursors, custom splash screen.
*   **Appliance Mode:** No desktop environment, no login prompts, hidden cursor.
*   **Configuration Driven:** Completely managed by a single `/boot/firmware/abdos.conf` file editable from Windows/Mac.
*   **Smart Networking:** Automatic Ethernet preference with Wi-Fi failover via NetworkManager.
*   **Resilience:** Hardware watchdog integration and automatic service recovery.
*   **Resource Optimized:** Architected specifically to run within the 512MB RAM constraints of a Raspberry Pi Zero W.

## 3. Directory Structure

```text
abdos/
├── assets/        # Static files (splash image, default config)
├── config/        # Default configuration templates
├── docs/          # Comprehensive project documentation
│   └── ADR/       # Architecture Decision Records
├── installer/     # Installation scripts
├── scripts/       # Runtime shell scripts
├── systemd/       # Custom systemd unit files
└── tests/         # Automated validation scripts
```

## 4. Quick Start
*(Note: Implementation scripts are pending Phase 2).*
1. Flash Raspberry Pi OS Lite (32-bit, Bookworm) to an SD card.
2. Clone this repository to the Pi.
3. Run `sudo ./installer/install.sh`.
4. Edit `/boot/firmware/abdos.conf` to set your target `URL`.
5. Reboot.

## 5. Documentation Index
The architecture and design are comprehensively documented. Start here:
*   [Software Requirements Specification (SRS)](SRS.md)
*   [Software Design Specification (SDS)](SDS.md)
*   [System Architecture & Flow Diagrams](Architecture.md)
*   [Configuration Guide](Configuration.md)
*   [Installation Guide](Installation.md)
*   [Performance Targets](PerformanceTargets.md)
