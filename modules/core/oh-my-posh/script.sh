#!/bin/bash

# oh-my-posh installation and configuration

POSH_VERSION="29.10.0"

install() {
    if is_arch; then
        pkg_install oh-my-posh-bin
    elif is_ubuntu; then
        install_ubuntu
    fi
}

install_ubuntu() {
    install_github_release oh-my-posh "$POSH_VERSION" \
        "https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v{version}/posh-linux-{arch_go}"
}

# fleet_repos_file prints the path to fleet's repos.yaml, honoring the same
# env var overrides fleet-task/fleet-run resolve it with (mirrors
# config/tmux/tmux-jump-picker.sh's fleet_repos_file()).
fleet_repos_file() {
    if [ -n "${FLEET_REPOS_FILE:-}" ]; then
        printf '%s' "$FLEET_REPOS_FILE"
        return
    fi
    local cfg_dir="${FLEET_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/fleet}"
    printf '%s/repos.yaml' "$cfg_dir"
}

# fleet_yaml_value <key> <file> prints a top-level scalar's value from
# repos.yaml, or nothing if the key/file is absent.
fleet_yaml_value() {
    local key="$1" file="$2"
    awk -v key="$key" '
        $0 ~ "^" key ":" {
            sub(/^[^:]*:[[:space:]]*/, "");
            sub(/[[:space:]]*#.*$/, "");
            gsub(/["'"'"']/, "");
            print;
            exit
        }
    ' "$file"
}

# render_fleet_theme renders theme.omp.json with the path segment's
# mapped_locations populated from fleet's repos.yaml (worktree_root /
# windows_worktree_root), so fleet ticket worktrees collapse to a fleet icon
# in the prompt. Falls back to an empty mapping (or a plain symlink, if jq is
# missing) when fleet isn't installed/configured — never fails configure().
render_fleet_theme() {
    local src="$1" dest="$2"

    if ! has_cmd jq; then
        log_warn "jq not found; skipping fleet path mapping."
        symlink_file "$src" "$dest"
        return
    fi

    local repos_file
    repos_file="$(fleet_repos_file)"

    local mapped_locations="{}"
    if [ -f "$repos_file" ]; then
        local worktree_root windows_worktree_root
        worktree_root="$(fleet_yaml_value worktree_root "$repos_file")"
        windows_worktree_root="$(fleet_yaml_value windows_worktree_root "$repos_file")"
        [[ "$worktree_root" == "~"* ]] && worktree_root="$HOME${worktree_root:1}"
        [[ "$windows_worktree_root" == "~"* ]] && windows_worktree_root="$HOME${windows_worktree_root:1}"

        mapped_locations=$(jq -n \
            --arg icon "󰳐 " \
            --arg linux "$worktree_root" \
            --arg windows "$windows_worktree_root" \
            '{}
             | if $linux != "" then .[$linux] = $icon else . end
             | if $windows != "" then .[$windows] = $icon else . end')
    fi

    local tmp_file
    tmp_file="$(mktemp)"
    jq --argjson mapped "$mapped_locations" \
        '(.blocks[0].segments[] | select(.type == "path") .properties.mapped_locations) = $mapped' \
        "$src" > "$tmp_file"
    mv "$tmp_file" "$dest"
}

configure() {
    local config_dir="$HOME/.config/ohmyposh"
    mkdir -p "$config_dir"

    local repo_theme="$DIR/config/ohmyposh/theme.omp.json"
    local dest_theme="$config_dir/theme.omp.json"

    if [ -f "$repo_theme" ]; then
        render_fleet_theme "$repo_theme" "$dest_theme"
    else
        log_warn "Theme file not found at $repo_theme"
    fi

    bashrc_d_link "$DIR/config/ohmyposh/bashrc.sh" oh-my-posh
}

update() {
    if is_arch; then
        pkg_update oh-my-posh-bin
    elif is_ubuntu; then
        install_ubuntu
    fi
}
