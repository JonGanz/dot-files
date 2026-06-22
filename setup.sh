#!/bin/bash

# Main entry point for the computer setup system

# Get the script directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Source libraries
source "$DIR/lib/log.sh"
source "$DIR/lib/env.sh"
source "$DIR/lib/pkg.sh"
source "$DIR/lib/util.sh"
source "$DIR/lib/config.sh"

# Default values
INTENT="common"
UPDATE=false
ONLY_MODULE=""
DRY_RUN=false
FORCE_RECONFIGURE=false

# Usage information
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --intent <name>    Set the intent (e.g., personal, work). Default: common"
    echo "  --update           Run update routines for existing modules"
    echo "  --only <module>    Run only a specific module"
    echo "  --reconfigure      Force a prompt for all configuration values"
    echo "  --dry-run          Show what would happen without executing"
    echo "  --help             Show this help message"
    exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --intent)
            INTENT="$2"
            shift 2
            ;;
        --update)
            UPDATE=true
            shift
            ;;
        --only)
            ONLY_MODULE="$2"
            shift 2
            ;;
        --reconfigure)
            FORCE_RECONFIGURE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help)
            usage
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            ;;
    esac
done

# Run the setup
main() {
    detect_env

    # Initial configuration setup
    if [ "$FORCE_RECONFIGURE" = true ]; then
        reconfigure
    else
        ensure_config
    fi

    log_step "Starting setup with intent: $INTENT"
    if [ "$UPDATE" = true ]; then
        log_info "Mode: Update"
        pkg_repo_update
    fi

    # Determine which modules to run
    modules=()
    if [ -n "$ONLY_MODULE" ]; then
        modules=("$ONLY_MODULE")
    else
        # Always include common modules
        if [ -f "$DIR/intents/common.txt" ]; then
            while IFS= read -r line; do
                [[ -n "$line" && ! "$line" =~ ^# ]] && modules+=("$line")
            done < "$DIR/intents/common.txt"
        fi

        # Include intent-specific modules
        if [[ "$INTENT" != "common" && -f "$DIR/intents/$INTENT.txt" ]]; then
            while IFS= read -r line; do
                [[ -n "$line" && ! "$line" =~ ^# ]] && modules+=("$line")
            done < "$DIR/intents/$INTENT.txt"
        fi
    fi

    # Remove duplicates while preserving order
    declare -A seen
    unique_modules=()
    for m in "${modules[@]}"; do
        if [[ -z "${seen[$m]}" ]]; then
            unique_modules+=("$m")
            seen[$m]=1
        fi
    done

    for module in "${unique_modules[@]}"; do
        run_module "$module"
    done

    log_success "Setup completed successfully!"
}

run_module() {
    local module_path="$DIR/modules/$1/script.sh"
    if [ -f "$module_path" ]; then
        log_step "Running module: $1"
        if [ "$DRY_RUN" = true ]; then
            log_info "[DRY-RUN] Would execute $1 module"
            return
        fi

        # Source the module script to access its functions
        # We use a subshell to avoid function name collisions
        (
            source "$DIR/lib/log.sh"
            source "$DIR/lib/env.sh"
            source "$DIR/lib/pkg.sh"
            source "$DIR/lib/util.sh"
            source "$DIR/lib/config.sh"
            load_config
            refresh_envs
            source "$module_path"

            if [ "$UPDATE" = true ]; then
                if declare -f update >/dev/null; then
                    update
                else
                    log_warn "Module $1 does not support update. Running install/configure instead."
                    install
                    configure
                fi
            else
                install
                configure
            fi
        )
    else
        log_error "Module script not found: $module_path"
    fi
}

main
