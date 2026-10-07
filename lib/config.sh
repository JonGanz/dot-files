#!/bin/bash

# Configuration library for managing personal/secret variables

CONFIG_FILE="$DIR/.local.env"

# Define configuration items: KEY|DESCRIPTION|DEFAULT|INTENTS
# DEFAULT can be:
#   - A literal value
#   - "NONE" (no default, must be provided)
#   - "OPTIONAL" (can be empty)
# INTENTS (optional) is a comma-separated list of intents the item is prompted for.
#   Empty means every intent. Modules can still demand an item regardless of
#   intent by listing its key in CONFIG_REQUIRES (see ensure_module_config).
# Anything reading these items with `IFS='|' read` must name all four fields,
# otherwise the last variable swallows the remainder.
CONFIG_ITEMS=(
    "git_username_personal|Git User Name (Personal)|NONE|"
    "git_email_personal|Git User Email (Personal)|NONE|"
    "work_git_dir|Work Git Directory (e.g. ~/work)|OPTIONAL|work"
    "own_projects_dir|Own Projects Directory (e.g. ~/projects)|~/projects|"
    "git_username_work|Git User Name (Work)|OPTIONAL|work"
    "git_email_work|Git User Email (Work)|OPTIONAL|work"
    "onedrive_work_dir|OneDrive work folder (e.g. /mnt/c/Users/you/OneDrive - Company)|NONE|work"
    "ssh_windows_username|Windows Username (for WSL work key import)|OPTIONAL|work"
    "ssh_work_key_name|Work SSH key filename — must match its name in Windows ~/.ssh (e.g. id_rsa)|OPTIONAL|work"
)

load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            # Only process lines that look like key=value
            if [[ "$line" =~ ^([a-zA-Z0-9_]+)=(.*)$ ]]; then
                local key="${BASH_REMATCH[1]}"
                local value="${BASH_REMATCH[2]}"

                # Strip leading/trailing quotes if they exist
                value="${value%\"}"
                value="${value#\"}"
                value="${value%\'}"
                value="${value#\'}"

                export "$key=$value"
            fi
        done < "$CONFIG_FILE"
    fi
}

save_config() {
    local key=$1
    local value=$2

    # Create file if it doesn't exist
    touch "$CONFIG_FILE"

    # Remove existing entry for the key
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "/^$key=/d" "$CONFIG_FILE"
    else
        sed -i "/^$key=/d" "$CONFIG_FILE"
    fi
    
    # Append new entry (WITHOUT quotes around value)
    echo "$key=$value" >> "$CONFIG_FILE"
    export "$key=$value"
}

# True when an item's INTENTS field covers the active intent (empty = all intents)
# Usage: config_item_applies <intents_field>
config_item_applies() {
    local intents="$1"
    [[ -z "$intents" ]] && return 0

    local intent
    local IFS=','
    for intent in $intents; do
        [[ "$intent" == "${INTENT:-common}" ]] && return 0
    done
    return 1
}

# Prompt for a single config item and persist the answer
# Usage: prompt_config_item <key> <description> <default> <force>
prompt_config_item() {
    local key="$1"
    local desc="$2"
    local default="$3"
    local force="$4"
    local current_val="${!key}"

    if [[ -n "$current_val" && "$force" != true ]]; then
        return 0
    fi

    local new_val
    local prompt_needed=true
    while [ "$prompt_needed" = true ]; do
        echo -n "Configure $desc"
        if [[ "$default" != "NONE" && "$default" != "OPTIONAL" ]]; then
            echo -n " [$default]"
        elif [[ -n "$current_val" ]]; then
            echo -n " (current: $current_val)"
        fi
        echo -n ": "

        local input=""
        local input_closed=false
        read -r input || input_closed=true

        if [[ -z "$input" ]]; then
            if [[ -n "$current_val" ]]; then
                # Keep current value
                new_val="$current_val"
                prompt_needed=false
            elif [[ "$default" != "NONE" && "$default" != "OPTIONAL" ]]; then
                new_val="$default"
                prompt_needed=false
            elif [[ "$default" == "OPTIONAL" ]]; then
                new_val=""
                prompt_needed=false
            else
                # Required but not provided
                echo
                log_error "$desc is required."
                # No more input is coming (non-interactive), so retrying would spin forever
                [[ "$input_closed" == true ]] && return 1
            fi
        else
            new_val="$input"
            prompt_needed=false
        fi
    done

    save_config "$key" "$new_val"
}

prompt_config() {
    local force=$1
    local item key desc default intents

    for item in "${CONFIG_ITEMS[@]}"; do
        IFS='|' read -r key desc default intents <<< "$item"
        config_item_applies "$intents" || continue
        prompt_config_item "$key" "$desc" "$default" "$force" || return 1
    done
}

# Prompt for the config items a module declares in CONFIG_REQUIRES, whatever the
# active intent is. Covers `--only <module>` runs that skip the upfront prompting.
ensure_module_config() {
    local required_key item key desc default intents

    for required_key in "${CONFIG_REQUIRES[@]}"; do
        [[ -n "${!required_key}" ]] && continue

        local found=false
        for item in "${CONFIG_ITEMS[@]}"; do
            IFS='|' read -r key desc default intents <<< "$item"
            [[ "$key" == "$required_key" ]] || continue

            found=true
            if ! prompt_config_item "$key" "$desc" "$default" false || [[ -z "${!key}" ]]; then
                log_error "Module requires config '$required_key' but no value was provided"
                return 1
            fi
        done

        if [[ "$found" == false ]]; then
            log_error "Module requires unknown config key '$required_key' (not in CONFIG_ITEMS)"
            return 1
        fi
    done
}

ensure_config() {
    load_config
    prompt_config false
}

reconfigure() {
    load_config
    prompt_config true
}
