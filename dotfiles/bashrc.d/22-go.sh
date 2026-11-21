# Golang environment; each PATH entry is added only if its directory exists.
if [ -d "/usr/local/go/bin" ]; then
    export PATH="$PATH:/usr/local/go/bin"
fi
GO_PATH="${GOPATH:-$HOME/go}"
if [ -d "$GO_PATH/bin" ]; then
    export PATH="$PATH:$GO_PATH/bin"
fi
unset GO_PATH
