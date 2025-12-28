#!/usr/bin/env bash
set -euo pipefail
. /etc/os-release

if [[ "$ID_LIKE" == *"ubuntu"* ]]; then
    
    sudo snap install spotify

fi

