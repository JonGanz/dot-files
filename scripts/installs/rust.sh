#!/usr/bin/env bash
set -euo pipefail
source "$SETUP_DIR/scripts/distro.fn.sh"

if is_distro ubuntu; then

    sudo apt-get install -y rustup
    # TODO: Must I do something now to ensure I know about rustup?
    rustup default stable
    rustup update

fi

