#!/bin/bash

# Python via pyenv

install() {
    if is_arch; then
        pkg_install python python-pip
    elif is_ubuntu; then
        if [ ! -d "$HOME/.pyenv" ]; then
            log_info "Installing pyenv build dependencies..."
            pkg_install make build-essential libssl-dev zlib1g-dev \
                libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
                libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
            log_info "Installing pyenv..."
            curl https://pyenv.run | bash
        else
            log_success "pyenv is already installed."
        fi
    fi
}

configure() {
    if [ -f "$DIR/modules/sdks/python/env.sh" ]; then
        source "$DIR/modules/sdks/python/env.sh"
    fi

    if is_ubuntu && has_cmd pyenv; then
        log_info "Installing latest stable Python 3..."
        local latest
        latest=$(pyenv install --list | grep -E '^\s+3\.[0-9]+\.[0-9]+$' | tail -1 | tr -d ' ')
        pyenv install -s "$latest"
        pyenv global "$latest"
        log_success "Python $(python --version) is ready."
    fi

    if ! grep -q "PYENV_ROOT" "$HOME/.bashrc"; then
        log_info "Adding pyenv to .bashrc..."
        {
            echo 'export PYENV_ROOT="$HOME/.pyenv"'
            echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"'
            echo 'eval "$(pyenv init -)"'
        } >> "$HOME/.bashrc"
    fi
}

update() {
    if is_arch; then
        pkg_update python python-pip
    elif is_ubuntu; then
        if [ -f "$DIR/modules/sdks/python/env.sh" ]; then
            source "$DIR/modules/sdks/python/env.sh"
        fi
        if has_cmd pyenv; then
            pyenv update
        else
            install
            configure
        fi
    fi
}
