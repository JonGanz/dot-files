#!/bin/bash

# Node Version Manager (nvm) and Node.js LTS installation

install() {
    if is_arch; then
        log_info "Installing nvm via pacman..."
        pkg_install nvm
    elif is_ubuntu; then
        if [ ! -d "$HOME/.nvm" ]; then
            log_info "Installing nvm via shell script..."
            # PROFILE=/dev/null stops the installer appending to ~/.bashrc; ~/.bashrc.d/node.sh handles that
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | PROFILE=/dev/null bash
        else
            log_success "nvm is already installed at $HOME/.nvm"
        fi
    fi
}

configure() {
    log_info "Configuring nvm and installing Node.js LTS..."

    # Source nvm from our SDK environment
    if [ -f "$DIR/modules/sdks/node/env.sh" ]; then
        source "$DIR/modules/sdks/node/env.sh"
    fi

    if has_cmd nvm; then
        log_info "Installing latest Node.js LTS..."
        nvm install --lts
        nvm use --lts
        nvm alias default 'lts/*'
        log_success "Node.js $(node --version) is now active and set as default."

        bashrc_d_link "$DIR/modules/sdks/node/env.sh" node
    else
        log_error "nvm command not found after installation. You may need to restart your shell."
    fi
}

update() {
    # nvm itself doesn't have a simple 'update' command; configure() (which
    # installs the current LTS) runs automatically after update.
    :
}
