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
FAIL_FAST=false

# Per-module results, filled in by run_module and printed by print_summary
RESULT_MODULES=()
RESULT_STATUS=()

# Usage information
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --intent <name>    Set the intent (e.g., personal, work). Default: common"
    echo "  --update           Run update routines for existing modules"
    echo "  --only <module>    Run only a specific module"
    echo "  --reconfigure      Force a prompt for all configuration values"
    echo "  --dry-run          Show what would happen without executing"
    echo "  --fail-fast        Stop at the first module that fails (default: continue)"
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
        --fail-fast)
            FAIL_FAST=true
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
        reconfigure || exit 1
    else
        ensure_config || exit 1
    fi

    log_step "Starting setup with intent: $INTENT"
    if [ "$UPDATE" = true ]; then
        log_info "Mode: Update"
        if is_arch; then
            # Arch does not support partial upgrades: do one full -Syu up front.
            # Per-module pkg_update calls are then safe (pacman -S --needed).
            pkg_update
        else
            pkg_repo_update
        fi
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
        if ! run_module "$module" && [ "$FAIL_FAST" = true ]; then
            log_error "Stopping: --fail-fast is set and $module failed."
            break
        fi
    done

    print_summary
}

record_result() {
    RESULT_MODULES+=("$1")
    RESULT_STATUS+=("$2")
}

print_summary() {
    local i failed=0 width=0 name
    for name in "${RESULT_MODULES[@]}"; do
        (( ${#name} > width )) && width=${#name}
    done

    log_step "Summary"
    for i in "${!RESULT_MODULES[@]}"; do
        case "${RESULT_STATUS[$i]}" in
            ok)      printf "  %-*s  ${GREEN}ok${NC}\n" "$width" "${RESULT_MODULES[$i]}" ;;
            skipped*) printf "  %-*s  ${YELLOW}%s${NC}\n" "$width" "${RESULT_MODULES[$i]}" "${RESULT_STATUS[$i]}" ;;
            *)       printf "  %-*s  ${RED}%s${NC}\n" "$width" "${RESULT_MODULES[$i]}" "${RESULT_STATUS[$i]}"; failed=$((failed + 1)) ;;
        esac
    done

    if [ "$failed" -gt 0 ]; then
        log_error "$failed module(s) failed."
        exit 1
    fi
    log_success "Setup completed successfully!"
}

run_module() {
    local module_path="$DIR/modules/$1/script.sh"
    if [ ! -f "$module_path" ]; then
        log_error "Module script not found: $module_path"
        record_result "$1" "FAILED (script not found)"
        return 1
    fi

    log_step "Running module: $1"
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would execute $1 module"
        record_result "$1" "skipped (dry-run)"
        return 0
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

        # Prompt for anything the module needs that the intent-scoped prompting skipped
        if [ "${#CONFIG_REQUIRES[@]}" -gt 0 ]; then
            ensure_module_config || exit 1
        fi

        if [ "$UPDATE" = true ]; then
            if declare -f update >/dev/null; then
                update || exit 1
            else
                log_info "Module $1 has no update(); running install instead."
                install || exit 1
            fi
        else
            install || exit 1
        fi
        # configure() always runs, in update mode too, so config changes are applied.
        # A module may omit it; if it declares CONFIG_DEST, config/<name>/ is linked there.
        if declare -f configure >/dev/null; then
            configure || exit 1
        elif [ -n "${CONFIG_DEST:-}" ]; then
            symlink_config_dir "$(basename "$1")" "$CONFIG_DEST" || exit 1
        fi
    )
    local status=$?

    if [ "$status" -eq 0 ]; then
        record_result "$1" "ok"
    else
        log_error "Module $1 failed (exit $status)."
        record_result "$1" "FAILED (exit $status)"
    fi
    return "$status"
}

main
