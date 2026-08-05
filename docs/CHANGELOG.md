# Changelog

All notable changes to the ABDOS project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - Alpha-2 Release

### Added
*   Modularized installer architecture (`installer/lib/`) for better maintainability.
*   Complete, idempotent uninstaller (`installer/uninstall.sh`).
*   Automated `/etc/X11/Xwrapper.config` configuration for reliable rootless Xorg execution.
*   Atomic Hostname configuration logic (updates both `/etc/hostname` and `/etc/hosts`).
*   Hardware Validation documentation and Alpha-1 root cause analysis.

### Changed
*   Moved `StartLimitIntervalSec` to the correct `[Unit]` section in systemd services.

## [Unreleased] - Phase 2

### Added
*   Hardware detection rejecting Chromium launch on ARMv6 (Pi Zero W / 1) due to Bookworm NEON requirement.
*   Browser binary validation in the `abdos-kiosk.sh` script, exiting gracefully if missing.
*   Openbox synchronization delay (`sleep 1`) on slower hardware.
*   Strict allowlist API enforced in all configuration parsers.
*   Robust INI parser in installer to safely update systemd configurations (Watchdog, Journald).
*   Console parameter stripping (`console=tty1`, `console=serial0`) for silent boot.
*   Core installer script (`install.sh`) with idempotent execution and backup functionality.
*   Dynamic runtime user detection (`@USER@`, `@HOME@`) replacing hard-coded accounts.
*   Dynamic Chromium package and Plymouth theme detection.
*   Template rendering system (`.in` files) for scripts and systemd units.
*   Systemd configurations for volatile logging (`journald`) and RAM-backed `/tmp`.
*   Strict bash API parser for `abdos.conf` enforcing an allowlist of keys.
*   Systemd rootless X11 integration (`PAMName=login`, `vt1`).
*   Chromium clean session enforcement via RAM-backed user profiles.

## [Unreleased] - Phase 1

### Added
*   Initial repository structure initialization.
*   Software Requirements Specification (`SRS.md`).
*   Software Design Specification (`SDS.md`).
*   System Architecture Diagrams (`Architecture.md`).
*   Configuration Guide and Schema (`Configuration.md`, `ConfigurationSchema.md`).
*   Performance Targets for Pi Zero W (`PerformanceTargets.md`).
*   Service Architecture and Minimization Audit (`ServiceArchitecture.md`, `ServiceAudit.md`).
*   Deployment, Installation, Troubleshooting, and Maintenance Guides.
*   Test Strategy, Acceptance Tests, and FMEA (`TestStrategy.md`, `AcceptanceTest.md`, `FMEA.md`).
*   Coding Standards, SBOM, and Versioning Strategy.
*   Architecture Decision Records (ADRs 001 through 006).
