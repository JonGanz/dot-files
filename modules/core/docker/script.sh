#!/bin/bash

# Docker installation and rootless configuration

install() {
    if is_arch; then
        log_info "Installing Docker via pacman..."
        pkg_install docker docker-buildx docker-compose docker-rootless-extras-bin
    elif is_ubuntu; then
        log_info "Installing Docker via official repository..."

        # Dependencies for Docker repo
        pkg_install ca-certificates curl gnupg

        # Add Docker's official GPG key if not present
        if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
            sudo mkdir -p /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        fi

        # Add the repository if not present
        if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
            log_info "Adding Docker repository..."
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
                sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

            pkg_repo_update
        fi

        pkg_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
    fi
}

configure() {
    log_info "Configuring Docker (Rootless)..."

    # Install rootless dependencies
    if is_arch; then
        pkg_install fuse-overlayfs slirp4netns
    elif is_ubuntu; then
        pkg_install dbus-user-session uidmap fuse-overlayfs slirp4netns
    fi

    # Check if rootless is already set up
    if systemctl --user is-active docker.service >/dev/null 2>&1; then
        log_success "Rootless Docker is already running."
    else
        log_info "Running rootless setup tool..."
        
        # Ensure the user docker service is not running via system-wide docker
        sudo systemctl disable --now docker.service docker.socket >/dev/null 2>&1 || true

        # Run the setup tool provided by docker
        if has_cmd dockerd-rootless-setuptool.sh; then
            dockerd-rootless-setuptool.sh install
            
            # Enable and start user service
            systemctl --user enable --now docker.service
            
            # Ensure environment variables are in .bashrc
            if ! grep -q "DOCKER_HOST" "$HOME/.bashrc"; then
                log_info "Adding Docker environment variables to .bashrc..."
                {
                    echo 'export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock'
                } >> "$HOME/.bashrc"
            fi
            
            # Export for current session
            export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock
            log_success "Rootless Docker configured."
        else
            log_error "dockerd-rootless-setuptool.sh not found."
        fi
    fi
}

update() {
    if is_arch; then
        pkg_update docker docker-buildx docker-compose
    elif is_ubuntu; then
        pkg_update docker-ce docker-ce-cli
    fi
}
