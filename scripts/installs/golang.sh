#!/usr/bin/env bash

: "${GOLANG_VER:?GOLANG_VER not set}"
: "${SETUP_DIR:?SETUP_DIR not set}"

source "$SETUP_DIR/bash/ensure.sh"

# TODO: If we add the pipefail to this file, this won't go well...
CURR_GOLANG=$(go version | sed -E 's/go version go([0-9]+\.[0-9]+(\.[0-9]+)?).*/\1/g')

if [[ "$CURR_GOLANG" != "$GOLANG_VER" ]]; then
    echo "Found Golang $CURR_GOLANG; replacing with $GOLANG_VER"
    wget -O "/tmp/golang.$GOLANG_VER.tar.gz" "https://go.dev/dl/go$GOLANG_VER.linux-amd64.tar.gz"
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "/tmp/golang.$GOLANG_VER.tar.gz"
else
    echo -e "Current Golang version $GOLANG_VER detected... $partial"
fi

ensure_block_in_file "$HOME/.bashrc" "Include Go binaries" "$(cat <<EOF
export PATH=\$PATH:/usr/local/go/bin
EOF
)"
