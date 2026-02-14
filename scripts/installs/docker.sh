#!/usr/bin/env bash
set -euo pipefail
source "$SETUP_DIR/scripts/distro.fn.sh"

if [[ "${HAS_DE:-0}" == "0" ]]; then
    echo "Skipping Docker install for environment without Desktop Environment"
    echo "This is likely a WSL2 setup; use the Windows integration instead."
    exit 2;
fi

if is_distro ubuntu; then

    if command -v docker >/dev/null 2>&1; then
        exit 0
    fi

    sudo apt-get -y install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
 
    sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

    sudo apt-get update

    sudo apt-get install -y \
        containerd.io \
        docker-buildx-plugin \
        docker-ce \
        docker-ce-cli \
        docker-compose-plugin \
        uidmap

    # Turn off system wide docker daemon running as root
    sudo systemctl disable --now docker.service docker.socket
    sudo rm -f /var/run/docker.sock

    dockerd-rootless-setuptool.sh install

fi

