# Service Audit & Minimization

To achieve the stringent performance targets for the Raspberry Pi Zero W, default Raspberry Pi OS Lite services must be aggressively audited and minimized.

## 1. Philosophy
*   **Opt-in, not Opt-out:** Only services explicitly required for kiosk operation are enabled.
*   **Save RAM:** Every unused daemon saves precious MBs.
*   **Save CPU at Boot:** Fewer services mean faster boot times to the splash screen and browser.

## 2. Service Classification

| Service Name | Purpose | Classification | Action | RAM Impact (Est) | Startup Impact | Justification |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `systemd-journald` | Core logging | Mandatory | Enable | ~5-15MB | Low | Essential for debugging; configure for RAM storage. |
| `NetworkManager` | Network connections | Mandatory | Enable | ~10-20MB | Medium | Required for Ethernet/Wi-Fi failover logic. |
| `ssh` | Remote access | Mandatory | Enable | ~2-5MB | Low | Required for remote management and updates. |
| `systemd-timesyncd` | NTP Time Sync | Mandatory | Enable | <2MB | Low | Certificates and schedules require accurate time. |
| `wpa_supplicant` | Wi-Fi backend | Mandatory | Enable | ~2-5MB | Low | Handled via NetworkManager. |
| `cron` | Scheduled tasks | Optional | Disable/Mask | ~2MB | Low | Replace with systemd timers if scheduling is needed. |
| `bluetooth` / `hciuart`| Bluetooth support | Disabled by Default| Disable/Mask | ~5-10MB | Medium | Not required for a display appliance. |
| `avahi-daemon` | mDNS discovery | Disabled by Default| Disable/Mask | ~3-5MB | Low | Not required for standard appliance operation. |
| `triggerhappy` | Hotkey daemon | Disabled by Default| Disable/Mask | ~2MB | Low | No keyboard/buttons on appliance. |
| `apt-daily.timer` | Auto-updates | Disabled by Default| Disable/Mask | Variable | High | Updates must be controlled and manual/scripted. |
| `alsa-state` / Audio | Sound state | Disabled by Default| Disable/Mask | ~2MB | Low | Assuming no audio required for this iteration. |

## 3. Implementation Note
The installer script must explicitly `systemctl disable` or `systemctl mask` the services classified as "Disabled by Default" to guarantee the required memory and CPU budget.
