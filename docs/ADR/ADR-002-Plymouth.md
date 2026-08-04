# ADR-002: Boot Splash Screen implementation

## Context
ABDOS must boot completely silently, hiding all kernel text and logos, and displaying a custom image until the browser is ready.

## Problem Statement
How do we display an image early in the boot process and keep it on screen until X11 and Chromium have finished rendering, avoiding the "black screen" flash?

## Decision
Use **Plymouth** with a custom override to delay the `plymouth-quit` signal.

## Alternatives Considered
*   **fbi (Linux Framebuffer Imageviewer):**
    *   *Advantage:* Extremely lightweight.
    *   *Disadvantage:* Does not integrate well with the transition to X11. It often flashes the console text before X11 takes over the framebuffer.
*   **Custom Framebuffer write (C program):**
    *   *Disadvantage:* Unnecessary complexity when Plymouth is a standard, maintained package.

## Advantages
*   Standard tool for Linux boot splashes.
*   Integrates perfectly with early KMS (Kernel Mode Setting) for fast display.
*   Can be controlled via `plymouth` CLI commands from our custom systemd services.

## Disadvantages
*   Plymouth can consume ~20MB of RAM during boot.

## Future Considerations
The Plymouth daemon must be strictly instructed to terminate immediately after Chromium launches to reclaim that 20MB of RAM for the browser.
