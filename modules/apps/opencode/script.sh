#!/bin/bash

install() {
    if ! has_cmd npm; then
        log_error "npm is required to install opencode (sdks/node should run before this module)."
        return 1
    fi

    npm install -g @opencode/cli
}

# tmux status integration is wired up by apps/agent-status-collector, which
# installs the agent-status plugin into ~/.config/opencode/plugins/.
configure() {
    :
}

update() {
    npm install -g @opencode/cli
}
