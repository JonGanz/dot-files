# Nix environment. Loaded last (99-) so Nix tools go at the END of PATH and the
# SDK installs (nvm, cargo, go) and distro packages keep winning.
for _nix_sh in /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh \
               "$HOME/.nix-profile/etc/profile.d/nix.sh"; do
    if [ -r "$_nix_sh" ]; then . "$_nix_sh"; break; fi
done
unset _nix_sh
if [ -d "$HOME/.nix-profile/bin" ]; then
    PATH=":$PATH:"
    PATH="${PATH//:$HOME\/.nix-profile\/bin:/:}"
    PATH="${PATH#:}"; PATH="${PATH%:}:$HOME/.nix-profile/bin"
    export PATH
fi
