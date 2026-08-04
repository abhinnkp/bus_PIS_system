# ADR-005: Browser Selection and Optimization

## Context
ABDOS needs to render modern web pages reliably. The primary target, Pi Zero W, has only 512MB of RAM and a weak GPU.

## Problem Statement
Which browser engine should we use, and how do we prevent it from crashing the low-memory system?

## Decision
Use **Chromium** (the Pi OS optimized build) launched with aggressive low-memory and low-GPU flags.

## Alternatives Considered
*   **Firefox (Iceweasel):**
    *   *Disadvantage:* Historically heavier and less optimized for Raspberry Pi hardware acceleration compared to the official Chromium build provided by the Raspberry Pi Foundation.
*   **Midori / Surf (WebkitGTK):**
    *   *Advantage:* Extremely lightweight.
    *   *Disadvantage:* Poor compatibility with modern JavaScript frameworks (React, Angular) commonly used for dashboards.

## Advantages
*   Excellent modern web compatibility.
*   Raspberry Pi Foundation maintains hardware-accelerated builds.
*   Extensive CLI flags for kiosk mode and optimization.

## Disadvantages
*   Inherently a memory hog. If the displayed URL is bloated, it will crash the Pi Zero W.

## Optimization Strategy (Flags)
To mitigate the memory issue, Chromium will be launched with:
*   `--kiosk` (Fullscreen, locked down).
*   `--disable-dev-shm-usage` (Prevents crashes related to small `/dev/shm`).
*   `--disable-gpu-shader-disk-cache` (Reduces SD writes).
*   `--disk-cache-dir=/tmp/chromium` (RAM cache, cleared on boot).
*   `--disable-extensions`, `--disable-sync`, `--no-first-run` (Removes background bloat).

## Future Considerations
The content developers building the dashboard URLs *must* be instructed to optimize their web apps for low memory (avoiding large memory leaks in JS) as ABDOS cannot fix poorly written web applications.
