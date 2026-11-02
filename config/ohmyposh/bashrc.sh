#!/bin/bash

# oh-my-posh prompt
if command -v oh-my-posh >/dev/null 2>&1; then
    eval "$(oh-my-posh init bash --config ~/.config/ohmyposh/theme.omp.json)"
fi
