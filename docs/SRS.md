# Software Requirements Specification (SRS)

## 1. Introduction

### 1.1 Purpose
This document specifies the software requirements for the Amnex Bus Display OS (ABDOS) v1.0. ABDOS is a production-ready embedded kiosk operating system designed for the Raspberry Pi.

### 1.2 Scope
ABDOS converts a standard Raspberry Pi OS Lite (Bookworm, 32-bit) installation into a dedicated kiosk appliance. It boots silently, automatically manages network connections (Ethernet priority with Wi-Fi fallback), and launches a Chromium browser in a restricted, fullscreen kiosk mode. The primary target hardware is the Raspberry Pi Zero W, emphasizing minimal resource consumption.

## 2. Overall Description

### 2.1 Product Perspective
ABDOS functions as a self-contained appliance. It is completely driven by a single configuration file located on the `/boot/firmware` partition, allowing configuration before the first boot.

### 2.2 Target Hardware
*   **Primary Target:** Raspberry Pi Zero W (512MB RAM, ARM11). Resource optimization is heavily focused on this platform.
*   **Secondary Targets:** Raspberry Pi 2 Model B, Raspberry Pi 3 Model B/B+. The same software image will support all these devices.

### 2.3 User Characteristics
*   **System Administrators:** Will flash the OS, edit the `abdos.conf` file, and deploy the devices.
*   **End Users:** Passengers or public viewers who will only ever see the displayed webpage. They have no interaction capabilities (no keyboard, no mouse).

## 3. Specific Requirements

### 3.1 Operating System Foundation
*   **Base OS:** Raspberry Pi OS Lite (Bookworm) 32-bit.
*   **Environment:** No desktop environment installed. Minimal package footprint.
*   **Core Services:** SSH enabled, Time synchronization enabled.

### 3.2 Silent Boot & Display
*   **Boot Experience:** Completely silent. No kernel messages, no systemd logs, no blinking cursors, no splash screen logos (Rainbow, Pi logo).
*   **Splash Screen:** A custom splash image displayed during boot via Plymouth, remaining visible until Chromium is fully rendered to avoid any black screens.

### 3.3 Networking
*   **Backend:** NetworkManager.
*   **Logic:** Automatic Ethernet preference. Fallback to Wi-Fi if Ethernet is disconnected. Automatic recovery to Ethernet if it returns.

### 3.4 Kiosk Mode (Chromium)
*   **State:** Fullscreen, no tabs, no address bar, no context menu, no error/update/restore dialogs.
*   **Cache:** RAM-backed cache or cleared on boot to ensure a fresh session every time.
*   **Interaction:** Hide mouse cursor, disable screen blanking/saver/DPMS.

### 3.5 System Recovery & Watchdog
*   **Hardware Watchdog:** Enable Pi hardware watchdog to recover from hard hangs.
*   **Software Recovery:** Automatically restart Chromium if it crashes. Restart the X11 session if it fails.

## 4. Future Enhancements
While not part of Version 1, the architecture must support adding:
*   Over-The-Air (OTA) updates.
*   Remote device management and fleet management.
*   Health monitoring and remote logging.
*   VPN support and device provisioning.
*   Local offline fallback webpage.
*   HTTPS client certificates.
*   Centralized configuration management.
