#!/usr/bin/env bash
set -euo pipefail
source "$SETUP_DIR/scripts/distro.fn.sh"

if is_distro ubuntu; then
    
    sudo snap install spotify

fi

