# Test Strategy

This document outlines the testing approach for ABDOS to ensure production-level reliability.

## 1. Development Roadmap & Phasing
*   **Phase 1:** Architecture & Documentation (Current).
*   **Phase 2:** Installer & Configuration Scripts Implementation. (Testing: Unit, Linter).
*   **Phase 3:** systemd & Kiosk Integration. (Testing: VM/Integration).
*   **Phase 4:** Boot Optimization & Splash Screen. (Testing: Hardware).
*   **Phase 5:** Hardware Validation & Release.

## 2. Risk Analysis (Real Deployment Scenarios)
See `FMEA.md` for a comprehensive Failure Mode and Effects Analysis. Key deployment risks include SD card corruption due to unexpected power loss (mitigated by RAM caching) and network unreliability (mitigated by NM failover).

## 3. Unit Testing
*   **Scripts:** All shell scripts (e.g., config parser) must be tested using `bats` (Bash Automated Testing System) to ensure correct parsing of `abdos.conf`, especially handling of missing or invalid variables according to the `ConfigurationSchema.md`.

## 4. Integration Testing
*   **Process:** After running the installer on a clean Pi OS Lite environment, automated scripts will check system state.
*   **Checks:** `systemctl is-active abdos-kiosk.service`, `grep -q "quiet" /boot/cmdline.txt`, verifying NetworkManager profiles are generated correctly from a test `abdos.conf`.

## 5. Hardware Validation
Because ABDOS is heavily dependent on the Raspberry Pi's specific hardware (GPU, Watchdog, Bootloader), physical validation is mandatory.
*   Test on Pi Zero W, Pi 2, and Pi 3.
*   Verify HDMI output, Plymouth splash transition, and Wi-Fi stability.

## 6. Performance Testing
*   Measure boot time using `systemd-analyze`.
*   Monitor RAM usage using `free -m` and `htop` while Chromium renders a complex webpage, ensuring it stays within the budgets defined in `PerformanceTargets.md`.

## 7. Recovery & Regression Testing
*   Simulate Chromium crashes (`killall chromium-browser`) and measure recovery time.
*   Simulate X11 crashes (`killall Xorg`).
*   Simulate network drops (unplug Ethernet) and time the failover to Wi-Fi.
