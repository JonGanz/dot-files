# Load ~/.bash_aliases (and the private ~/.bash_aliases.local). Ubuntu's stock
# .bashrc already does this, but Arch and NixOS don't, so do it here too.
# Re-defining an alias is harmless.
[ -r "$HOME/.bash_aliases" ] && . "$HOME/.bash_aliases"
[ -r "$HOME/.bash_aliases.local" ] && . "$HOME/.bash_aliases.local"
