# Configuration Schema

This document defines the formal schema and behavior for `/boot/firmware/abdos.conf`. The config script must validate inputs based on these rules.

## 1. Schema Definitions

### URL
*   **Type:** String
*   **Default:** `http://localhost`
*   **Validation:** Regex check for `^https?://`.
*   **Required:** Yes.
*   **Error Handling:** If missing or invalid format, log error and fallback to default.

### HOSTNAME
*   **Type:** String
*   **Default:** `abdos-display`
*   **Validation:** Regex `^[a-zA-Z0-9-]+$`. Maximum 63 characters. Cannot start or end with a hyphen.
*   **Required:** No.
*   **Error Handling:** If invalid, skip hostname update and log warning.

### ETHERNET_PRIORITY
*   **Type:** Boolean
*   **Default:** `true`
*   **Validation:** Must strictly equal `true` or `false` (case-insensitive).
*   **Required:** No.
*   **Error Handling:** If invalid, assume `true`.

### WIFI_SSID / WIFI_PASSWORD
*   **Type:** String
*   **Default:** Empty
*   **Validation:** If SSID is provided, attempt to configure NetworkManager.
*   **Required:** No.
*   **Error Handling:** If SSID is empty, skip Wi-Fi configuration.

### TIMEZONE
*   **Type:** String
*   **Default:** `Etc/UTC`
*   **Validation:** File must exist in `/usr/share/zoneinfo/`.
*   **Required:** No.
*   **Error Handling:** If invalid/not found, skip timezone update and log warning.

### SPLASH_IMAGE
*   **Type:** String (File Path)
*   **Default:** `/boot/firmware/splash.png`
*   **Validation:** File must exist at path and be a valid `.png` format.
*   **Required:** No.
*   **Error Handling:** If file missing, Plymouth falls back to text mode or default theme.

### SSH_ENABLED
*   **Type:** Boolean
*   **Default:** `true`
*   **Validation:** Must strictly equal `true` or `false`.
*   **Required:** No.
*   **Error Handling:** If invalid, assume `true` to prevent lockout.

### WATCHDOG
*   **Type:** Boolean
*   **Default:** `true`
*   **Validation:** Must strictly equal `true` or `false`.
*   **Required:** No.
*   **Error Handling:** If invalid, assume `true`.

### CURSOR
*   **Type:** Boolean
*   **Default:** `false`
*   **Validation:** Must strictly equal `true` or `false`.
*   **Required:** No.
*   **Error Handling:** If invalid, assume `false`.

### CACHE_MODE
*   **Type:** String
*   **Default:** `ram`
*   **Validation:** Must be `ram` or `clear`.
*   **Required:** No.
*   **Error Handling:** If invalid, assume `ram`.

## 2. Global Error Handling Strategy
*   Invalid configuration parameters must *never* cause a boot failure or kernel panic.
*   The `abdos-config.service` will parse the file, apply validation rules, log any deviations to the journal, and apply safe defaults where necessary.
