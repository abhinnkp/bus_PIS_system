# Directory Structure

This document describes the structure of the ABDOS project repository and the purpose of each directory.

```text
abdos/
├── assets/        # Static files like the default splash screen image, icons, or fallback HTML pages.
├── config/        # Default configuration templates (e.g., abdos.conf.template).
├── docs/          # Comprehensive project documentation (Markdown).
│   └── ADR/       # Architecture Decision Records explaining major design choices.
├── installer/     # Scripts responsible for deploying ABDOS onto a fresh Raspberry Pi OS image.
├── scripts/       # Operational shell scripts used during boot or runtime (e.g., kiosk-start.sh).
├── systemd/       # Custom systemd unit files (.service, .target) for managing the appliance lifecycle.
└── tests/         # Automated tests, linter configurations, and validation scripts.
```

## Directory Details

### `assets/`
Contains non-code resources. The default Plymouth splash screen (`splash.png`) resides here before being copied to `/boot/firmware` by the installer.

### `config/`
Contains the reference template for `abdos.conf`. This is used by the installer to seed the `/boot/firmware` partition if a configuration file does not already exist.

### `docs/`
The single source of truth for all project planning, architecture, design, and operational manuals. Must be kept up to date with code changes.

### `installer/`
Contains `install.sh`. This directory is copied to the Pi. The installer script is idempotent, meaning it can be run multiple times without causing duplicate configurations or errors.

### `scripts/`
Contains the runtime logic. Scripts here are typically copied to `/usr/local/bin/` on the target system. Example: `abdos-kiosk.sh` (launches Chromium) and `abdos-config.sh` (parses the config file). All scripts must be ShellCheck compliant.

### `systemd/`
Contains the `.service` files that integrate the shell scripts into the OS boot process. These files define the strict startup order, dependencies, and restart policies necessary for appliance stability.

### `tests/`
Contains test scripts (e.g., bats tests for bash scripts, configuration validation tests) to ensure the system logic functions as expected before deployment.
