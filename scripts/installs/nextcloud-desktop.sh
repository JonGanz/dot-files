#!/usr/bin/env bash
set -euo pipefail
source "$SETUP_DIR/scripts/distro.fn.sh"

if [[ "${HAS_DE:-0}" == "0" ]]; then
    echo "Skipping Nextcloud Desktop install for environment without Desktop Environment"
    exit 2;
fi

if is_distro ubuntu; then

    # TODO: Only do the add/update if the repository isn't already there.
    sudo add-apt-repository ppa:nextcloud-devs/client -y
    sudo apt update

    sudo apt install -y nextcloud-desktop

fi

