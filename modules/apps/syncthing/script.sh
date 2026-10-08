#!/bin/bash

install() {
    if is_ubuntu; then
        install_ubuntu
    fi
}

install_ubuntu() {
    log_info "Installing Syncthing via APT..."

    # Add official GPG key if not present
    if [ ! -f /usr/share/keyrings/syncthing-archive-keyring.gpg ]; then
        curl -fsSL https://syncthing.net/release-key.gpg | sudo gpg --yes --dearmor -o /usr/share/keyrings/syncthing-archive-keyring.gpg
        sudo chmod 644 /usr/share/keyrings/syncthing-archive-keyring.gpg
    fi

    # Add the repository if not present
    if [ ! -f /etc/apt/sources.list.d/syncthing.list ]; then
        log_info "Adding Syncthing repository..."

        echo 'deb [signed-by=/usr/share/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net syncthing stable-v2' | \
            sudo tee /etc/apt/sources.list.d/syncthing.list

        pkg_repo_update syncthing
    fi

    # Make sure this takes priority over Ubuntu's syncthing
    if [ ! -f /etc/apt/preferences.d/syncthing.pref ]; then
        printf "Package: *\nPin: origin apt.syncthing.net\nPin-Priority: 990\n" | \
            sudo tee /etc/apt/preferences.d/syncthing.pref > /dev/null
    fi

    pkg_install syncthing
}

configure() {
    # The GUI listens on 127.0.0.1:8384
    if ! has_cmd systemctl || ! systemctl --user show-environment &>/dev/null; then
        log_warn "systemd user session unavailable; start Syncthing manually with 'syncthing serve --no-browser'"
        return 0
    fi

    log_info "Enabling Syncthing user service..."
    systemctl --user enable --now syncthing
}

update() {
    if is_ubuntu; then
        pkg_update syncthing
    fi
}
