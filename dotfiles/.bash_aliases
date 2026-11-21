# Machine/work-specific aliases go in ~/.bash_aliases.local (untracked or from the private overlay).
[ -r ~/.bash_aliases.local ] && . ~/.bash_aliases.local

alias wez='flatpak run org.wezfurlong.wezterm'
alias lg='lazygit'
alias vh='> ~/.local/state/nvim/log && nvim .'
alias cls='clear'

alias g='git'
alias gf='git f'
alias gst='git status'

alias :q='exit'
