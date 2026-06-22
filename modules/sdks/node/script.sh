#!/bin/bash

# Node Version Manager (nvm) and Node.js LTS installation

install() {
    if is_arch; then
        log_info "Installing nvm via pacman..."
        pkg_install nvm
    elif is_ubuntu; then
        if [ ! -d "$HOME/.nvm" ]; then
            log_info "Installing nvm via shell script..."
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
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

        # Ensure nvm is initialized in .bashrc for future sessions
        if ! grep -q "NVM_DIR" "$HOME/.bashrc"; then
            log_info "Adding nvm initialization to .bashrc..."
            {
                echo 'export NVM_DIR="$HOME/.nvm"'
                echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm'
                echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion'
            } >> "$HOME/.bashrc"
        fi
    else
        log_error "nvm command not found after installation. You may need to restart your shell."
    fi
}

update() {
    # nvm itself doesn't have a simple 'update' command, but we can update Node
    configure
}
