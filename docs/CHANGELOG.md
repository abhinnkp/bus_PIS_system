# Changelog

All notable changes to the ABDOS project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - Phase 2 (Current)

### Added
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
