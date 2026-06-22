#!/bin/bash

install() {
    : # bash is always available
}

configure() {
    symlink_file "$DIR/config/bash/bash_aliases" "$HOME/.bash_aliases"
}
