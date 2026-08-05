#!/usr/bin/env bash

# Keep track of backups
BACKUP_REGISTRY="/var/log/abdos_backups.log"
touch "$BACKUP_REGISTRY"

backup_file() {
    if [[ -f "$1" ]]; then
        local target="${1}.abdos.bak"
        cp -f "$1" "$target"
        # Only log it once
        if ! grep -q "^$target$" "$BACKUP_REGISTRY"; then
            echo "$target" >> "$BACKUP_REGISTRY"
        fi
    fi
}
