#!/bin/bash

# Configuration library for managing personal/secret variables

CONFIG_FILE="$DIR/.local.env"

# Define configuration items: KEY|DESCRIPTION|DEFAULT
# DEFAULT can be:
#   - A literal value
#   - "NONE" (no default, must be provided)
#   - "OPTIONAL" (can be empty)
CONFIG_ITEMS=(
    "git_username_personal|Git User Name (Personal)|NONE"
    "git_email_personal|Git User Email (Personal)|NONE"
    "work_git_dir|Work Git Directory (e.g. ~/work)|OPTIONAL"
    "git_username_work|Git User Name (Work)|OPTIONAL"
    "git_email_work|Git User Email (Work)|OPTIONAL"
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

prompt_config() {
    local force=$1
    
    for item in "${CONFIG_ITEMS[@]}"; do
        IFS='|' read -r key desc default <<< "$item"
        current_val="${!key}"
        
        if [[ -z "$current_val" || "$force" == true ]]; then
            local prompt_needed=true
            while [ "$prompt_needed" = true ]; do
                echo -n "Configure $desc"
                if [[ "$default" != "NONE" && "$default" != "OPTIONAL" ]]; then
                    echo -n " [$default]"
                elif [[ -n "$current_val" ]]; then
                    echo -n " (current: $current_val)"
                fi
                echo -n ": "
                
                read -r input
                
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
                        log_error "$desc is required."
                    fi
                else
                    new_val="$input"
                    prompt_needed=false
                fi
            done
            
            save_config "$key" "$new_val"
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
