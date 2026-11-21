# Node (nvm) environment; no-op when nvm isn't installed.
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    . "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
elif [ -s "/usr/share/nvm/init-nvm.sh" ]; then
    . "/usr/share/nvm/init-nvm.sh"
fi
