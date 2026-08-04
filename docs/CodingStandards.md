# Coding Standards

To maintain consistency and production-quality code, the following standards apply to all ABDOS development.

## 1. Shell Scripts
*   **Shebang:** All scripts must start with `#!/usr/bin/env bash`.
*   **Safety:** Scripts must use `set -euo pipefail` (unless explicitly handling a pipeline failure).
*   **Validation:** All shell scripts must pass `shellcheck` with zero warnings.
*   **Indentation:** 2 or 4 spaces (be consistent per file). No tabs.
*   **Variables:** Use lowercase for internal script variables (e.g., `local target_dir`). Use uppercase for environment/configuration variables (e.g., `URL`). Always quote variables (`"$URL"`).
*   **Functions:** Group logic into functions. Use `local` for function variables.
*   **Logging:** Use `echo` for CLI output during installation. Use `logger` for runtime scripts writing to systemd journal.
*   **Exit Codes:** Ensure scripts return `0` on success and `>0` on failure. Provide meaningful error messages to `stderr`.

## 2. Configuration Files (abdos.conf)
*   **Format:** Strict `KEY=value`. No spaces around `=`.
*   **Comments:** Use `#` for comments.

## 3. Systemd Units
*   **Naming:** Prefix custom services with `abdos-` (e.g., `abdos-kiosk.service`).
*   **Structure:** Include `[Unit]`, `[Service]`, and `[Install]` sections. Provide clear `Description` fields.

## 4. Markdown Documentation
*   **Format:** Standard GitHub Flavored Markdown (GFM).
*   **Structure:** Use H1 (`#`) for the document title, H2 (`##`) for main sections.
*   **Diagrams:** Use Mermaid syntax for all architectural diagrams.
*   **Line Length:** No strict character limit, but break paragraphs logically.
