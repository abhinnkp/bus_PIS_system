# Versioning Strategy

ABDOS follows standard Semantic Versioning and branching practices to ensure stable releases.

## 1. Semantic Versioning (SemVer)
Releases are versioned as `MAJOR.MINOR.PATCH` (e.g., `1.0.0`).
*   **MAJOR:** Incompatible changes (e.g., shifting from bash scripts to a compiled Kiosk Manager, changing the base OS requirement from Bookworm to a newer Debian release).
*   **MINOR:** Backwards-compatible new features (e.g., adding `STATIC_IP` support to `abdos.conf`).
*   **PATCH:** Backwards-compatible bug fixes (e.g., fixing a race condition in the boot script).

## 2. Release Numbering
The configuration file format and expected behavior are tied to the version number.
*   Version 1.x.x guarantees compatibility with the V1 `abdos.conf` schema.

## 3. Branching Strategy
*   `main`: The stable branch. Contains production-ready code.
*   `develop`: The integration branch for new features.
*   `feature/*`: Branches for specific tasks (e.g., `feature/ota-updates`).
*   `release/*`: Branches used to stabilize a version before merging to `main`.

## 4. Changelog Process
All notable changes to the project must be documented in `docs/CHANGELOG.md` following the "Keep a Changelog" format.
Categories: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`.

## 5. Compatibility Expectations
*   The installer must always be able to run on the explicitly supported base OS (currently Raspberry Pi OS Lite Bookworm 32-bit).
*   Changes to `abdos.conf` parameters must provide a sensible default if an older config file is parsed by a newer system script to ensure smooth manual upgrades.
