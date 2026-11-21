# oh-my-posh prompt (no-op when oh-my-posh isn't on PATH).
# Note: the old setup rendered theme.omp.json to fill the path segment's
# mapped_locations from fleet's repos.yaml; the theme is now linked as a plain
# file with mapped_locations empty.
if command -v oh-my-posh >/dev/null 2>&1; then
    eval "$(oh-my-posh init bash --config ~/.config/ohmyposh/theme.omp.json)"
fi
