#!/bin/bash

# Lines that modules used to append straight to ~/.bashrc before the
# ~/.bashrc.d convention. They are removed once; the equivalent lives in
# ~/.bashrc.d/*.sh now.
LEGACY_BASHRC_LINES=(
    'eval "$(oh-my-posh init bash --config ~/.config/ohmyposh/theme.omp.json)"'
    'export PATH="$HOME/bin:$PATH"'
    'export NVM_DIR="$HOME/.nvm"'
    '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm'
    '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion'
    'export PATH="$HOME/.cargo/bin:$PATH"'
    'export PYENV_ROOT="$HOME/.pyenv"'
    '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"'
    'eval "$(pyenv init -)"'
    'export PATH="$PATH:/usr/local/go/bin"'
    'export PATH="$PATH:${GOPATH:-$HOME/go}/bin"'
    'export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock'
)

install() {
    : # bash is always available
}

configure() {
    symlink_file "$DIR/config/bash/bash_aliases" "$HOME/.bash_aliases"
    remove_bashrc_lines "${LEGACY_BASHRC_LINES[@]}"
    ensure_bashrc_loader
}
