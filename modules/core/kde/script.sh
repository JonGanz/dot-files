#!/bin/bash

# KDE Plasma Customization (Gruvbox Icons & Krohnkite Tiling)

install() {
    # Skip if we are in WSL or headless
    if is_wsl; then
        log_info "Skipping KDE ricing in WSL environment."
        return 0
    fi

    install_icons
    install_plasma_theme
    install_wallpapers
    install_theme
    install_krohnkite
}

install_icons() {
    local icon_dir="$HOME/.local/share/icons/Gruvbox-Plus-Dark"
    if [ -d "$icon_dir" ]; then
        log_success "Gruvbox Plus icons already installed."
        return 0
    fi

    log_info "Installing Gruvbox Plus icon pack..."
    local tmp_dir
    tmp_dir=$(mktemp -d)
    local zip_file="$tmp_dir/gruvbox-icons.zip"
    # Updated to latest stable source URL
    local zip_url="https://github.com/SylEleuth/gruvbox-plus-icon-pack/archive/refs/tags/v6.4.0.zip"
    
    pkg_install curl unzip
    
    if curl -LSs "$zip_url" -o "$zip_file"; then
        mkdir -p "$HOME/.local/share/icons"
        log_info "Extracting icon pack..."
        unzip -q "$zip_file" -d "$tmp_dir"
        
        # Source zips from GitHub include a top-level directory (e.g., gruvbox-plus-icon-pack-6.4.0)
        # We need to find the actual icon folders inside it.
        local extracted_root=$(find "$tmp_dir" -maxdepth 1 -type d -name "gruvbox-plus-icon-pack*" | head -n 1)
        
        if [ -d "$extracted_root" ]; then
            # Move the icon folders to the local icons directory
            # We use 'Gruvbox-Plus-Dark' as the primary target
            if [ -d "$extracted_root/Gruvbox-Plus-Dark" ]; then
                cp -r "$extracted_root/Gruvbox-Plus-Dark" "$HOME/.local/share/icons/"
                log_success "Gruvbox Plus Dark icons installed."
            else
                # Fallback: if structure is different, try to find directories containing index.theme
                find "$extracted_root" -name "index.theme" -exec dirname {} \; | while read -r theme_path; do
                    cp -r "$theme_path" "$HOME/.local/share/icons/"
                done
                log_success "Gruvbox Plus icons installed via fallback."
            fi
        fi
    else
        log_error "Failed to download Gruvbox Plus icons."
    fi
    rm -rf "$tmp_dir"
}

install_plasma_theme() {
    local theme_dir="$HOME/.local/share/plasma/desktoptheme/gruvbox-plasma"
    if [ -d "$theme_dir" ]; then
        log_success "Gruvbox Plasma theme already installed."
        return 0
    fi

    log_info "Installing Gruvbox Plasma theme..."
    mkdir -p "$HOME/.local/share/plasma/desktoptheme"
    
    pkg_install git
    if git clone --depth 1 https://github.com/3ximus/gruvbox-plasma "$theme_dir"; then
        log_success "Gruvbox Plasma theme installed."
    else
        log_error "Failed to clone Gruvbox Plasma theme."
    fi
}

install_wallpapers() {
    log_info "Initializing wallpaper submodule..."
    # DIR is the root of the repo, inherited from setup.sh
    git -C "$DIR" submodule update --init --recursive config/wallpapers
    log_success "Wallpapers initialized."
}

install_theme() {
    local theme_src="$DIR/config/kde/color-schemes"
    local theme_dest="$HOME/.local/share/color-schemes"

    log_info "Setting up KDE color schemes symlink..."

    # Ensure local share directory exists
    mkdir -p "$HOME/.local/share"

    # If it's already a symlink, check if it's pointing to the right place
    if [ -L "$theme_dest" ]; then
        local current_link
        current_link=$(readlink "$theme_dest")
        if [ "$current_link" == "$theme_src" ]; then
            log_success "Color schemes already symlinked to repository."
            return 0
        fi
        log_warn "Removing existing symlink pointing to $current_link"
        rm "$theme_dest"
    fi

    # If it's a directory, move its content to the repo to preserve existing themes
    if [ -d "$theme_dest" ]; then
        log_info "Migrating existing themes from $theme_dest to repository..."
        mkdir -p "$theme_src"
        cp -rn "$theme_dest"/* "$theme_src/" 2>/dev/null || true
        rm -rf "$theme_dest"
    fi

    ln -s "$theme_src" "$theme_dest"
    log_success "Color schemes symlinked to repository."
}


install_krohnkite() {
    if has_cmd kpackagetool6 || has_cmd kpackagetool5; then
        log_info "Installing Krohnkite KWin script..."
        
        local ktool="kpackagetool6"
        has_cmd kpackagetool6 || ktool="kpackagetool5"
        
        if $ktool --list --type KWin/Script | grep -q "krohnkite"; then
            log_success "Krohnkite is already installed."
            return 0
        fi

        local tmp_dir
        tmp_dir=$(mktemp -d)
        # Using the latest release from anametologin
        local pkg_url="https://github.com/anametologin/krohnkite/releases/latest/download/krohnkite.kwinscript"
        
        if curl -LSs "$pkg_url" -o "$tmp_dir/krohnkite.kwinscript"; then
            $ktool --type KWin/Script --install "$tmp_dir/krohnkite.kwinscript"
            log_success "Krohnkite installed."
        else
            log_error "Failed to download Krohnkite."
        fi
        rm -rf "$tmp_dir"
    else
        log_warn "kpackagetool (5 or 6) not found. Skipping Krohnkite installation."
    fi
}

configure() {
    if is_wsl; then return 0; fi

    log_info "Configuring KDE settings..."
    
    # Identify configuration tools
    local kconfig=""
    local dbus=""
    local plasmaconfig="plasma-apply-colorscheme"
    
    if has_cmd kwriteconfig6; then
        kconfig="kwriteconfig6"
    elif has_cmd kwriteconfig5; then
        kconfig="kwriteconfig5"
    fi

    if has_cmd qdbus6; then
        dbus="qdbus6"
    elif has_cmd qdbus; then
        dbus="qdbus"
    fi

    if has_cmd plasma-apply-desktoptheme; then
        log_info "Applying Gruvbox Plasma theme..."
        plasma-apply-desktoptheme gruvbox-plasma
    fi

    if [ -n "$kconfig" ]; then
        log_info "Setting icon theme to Gruvbox-Plus-Dark..."
        $kconfig --file kdeglobals --group Icons --key Theme Gruvbox-Plus-Dark

        log_info "Setting animation speed to instant..."
        $kconfig --file kdeglobals --group KDE --key AnimationDurationFactor 0
        
        log_info "Enabling Krohnkite KWin script..."
        $kconfig --file kwinrc --group Plugins --key krohnkiteEnabled true

        if has_cmd "$plasmaconfig"; then
            log_info "Applying GruvboxColors theme via plasma-apply-colorscheme..."
            $plasmaconfig GruvboxColors
        else
            log_info "Applying GruvboxColors theme via kwriteconfig..."
            $kconfig --file kdeglobals --group General --key ColorScheme GruvboxColors
        fi
        
        # Move panel to left
        if [ -n "$dbus" ]; then
            log_info "Moving Plasma panel to the left..."
            $dbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "panels()[0].location='left';"
            
            log_info "Configuring wallpaper slideshow (1 minute interval)..."
            local wallpaper_dir=$(realpath "$DIR/config/wallpapers")
            $dbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
                var allDesktops = desktops();
                for (var i = 0; i < allDesktops.length; i++) {
                    var d = allDesktops[i];
                    d.wallpaperPlugin = 'org.kde.slideshow';
                    d.currentConfigGroup = Array('Wallpaper', 'org.kde.slideshow', 'General');
                    d.writeConfig('SlidePaths', '$wallpaper_dir');
                    d.writeConfig('Interval', 60);
                    d.writeConfig('Random', true);
                }
            "

            # Notify system of configuration changes
            $dbus org.kde.KWin /KWin reconfigure 2>/dev/null || true
        fi
    else
        log_warn "kwriteconfig not found. Could not apply KDE settings."
    fi
}

update() {
    if is_wsl; then return 0; fi
    install
    configure
}
