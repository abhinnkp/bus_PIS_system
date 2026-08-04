# Failure Mode and Effects Analysis (FMEA)

This document outlines potential failure scenarios for the ABDOS appliance and their mitigation strategies.

| Scenario | Cause | Effect | Detection | Recovery Strategy | Severity | Probability | Mitigation |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Unexpected Power Loss** | Unplugged cable | Potential SD card corruption. | Next boot fails. | Re-flash SD card. | High | Medium | RAM-backed `/tmp`, volatile logging, and Chromium RAM cache drastically reduce SD card write operations, lowering corruption probability. |
| **Browser Crash** | OOM, Render bug | Screen disappears/freezes. | systemd service exits. | `abdos-kiosk.service` restarts automatically. | High | Low | systemd `Restart=always`. |
| **X11 Crash** | Driver issue | Screen goes black. | systemd detects Xorg exit. | `abdos-kiosk.service` restarts automatically. | High | Low | systemd `Restart=always`. |
| **Ethernet Failure** | Cable unplugged | Loss of connection. | NetworkManager link down. | Auto-switch to Wi-Fi. | Medium | Medium | Configure `WIFI_SSID` as fallback. |
| **Network Unavailable** | Router down | Browser shows "No Internet" | Ping fails. | Wait. Browser auto-reloads or relies on Kiosk Manager to monitor. | High | Medium | Kiosk service delays start until `network-online.target`. |
| **Invalid Config** | Typo in `abdos.conf` | Boot loop or incorrect behavior. | Config script validates. | Apply defaults, log warning. | Medium | Low | Strict parsing via `ConfigurationSchema.md`. |
| **System Hang** | Kernel panic | Unresponsive device. | Watchdog ping fails. | Hardware reset. | High | Low | Enable `/dev/watchdog` via systemd. |
| **Memory Exhaustion** | Webpage memory leak | System freeze, OOM killer triggers. | Syslog OOM entry. | Watchdog reboot or Kiosk restart. | High | Medium | Optimized Chromium flags; Pi Zero W RAM budget. |
| **Display Disconnected** | HDMI unplugged | No visual output. | Cannot be detected by Pi OS purely. | Operator notices. | High | Low | Physical cable management. |
