# Performance Targets & Budgets

Because the primary target is the Raspberry Pi Zero W (512MB RAM, single-core ARM11), strict performance targets and resource budgets are essential.

## 1. Memory Budget (Target: Pi Zero W, 512MB RAM)

| Component | Estimated RAM (MB) | Notes |
| :--- | :--- | :--- |
| **Linux Kernel & Base OS** | ~70 - 100 | Includes systemd, bash, ssh. |
| **NetworkManager** | ~10 - 20 | DHCP and interface management. |
| **X11 Server (Xorg)** | ~40 - 60 | Minimal graphics stack. |
| **Window Manager (Openbox)** | ~5 - 10 | Extremely lightweight. |
| **Plymouth (Boot only)** | ~20 | Frees memory after boot. |
| **Chromium (Base)** | ~100 - 150 | Heavily optimized via flags. |
| **Chromium (Render/GPU)** | ~50 - 100 | Depends on the configured URL complexity. |
| **RAM Cache / Logging** | ~20 | `/tmp` tmpfs limits. |
| **Remaining Free RAM** | **~50 - 100** | Critical safety margin to prevent OOM killer. |

*Note: GPU memory split (e.g., 64MB or 128MB to GPU) must be factored into total available RAM.*

## 2. CPU Budget (Target: Pi Zero W)
*   **Idle Operation (Static Webpage):** < 15% CPU.
*   **Idle Operation (Dynamic Webpage - CSS animations):** < 40% CPU.
*   **Video Playback:** **Not recommended** for Pi Zero W without hardware decoding optimization (out of scope for V1 base).
*   **Background Services:** < 2% CPU combined.

## 3. Measurable Performance Targets

### Raspberry Pi Zero W
*   **Boot Time (Power to Splash):** < 15s
*   **Splash to Browser:** < 75s
*   **Chromium Restart Time (Crash Recovery):** < 30s
*   **Free RAM (Idle):** > 50MB

### Raspberry Pi 2 / 3 B+
*   **Boot Time (Power to Splash):** < 10s
*   **Splash to Browser:** < 30s
*   **Chromium Restart Time (Crash Recovery):** < 10s
*   **Free RAM (Idle):** > 300MB (Pi 3)

## 4. Chromium Optimization Strategy
To fit within the memory budget, Chromium must be launched with flags that reduce footprint:
*   `--disable-dev-shm-usage`: Forces use of `/tmp` instead of `/dev/shm`.
*   `--disable-extensions`: Prevents memory overhead.
*   `--disable-gpu-shader-disk-cache`: Saves SD card writes.
*   `--disk-cache-dir=/tmp`: Moves cache to RAM.

## 5. SD Card Write Minimization
To extend the life of the SD card in 24/7 deployment:
*   Swap file must be disabled (`systemctl disable dphys-swapfile`). If RAM is exhausted, the system must crash and recover via watchdog rather than thrashing the SD card.
*   Log writes are minimized (see `LoggingStrategy.md`).
