#!/bin/bash

install() {
    if is_arch; then
        pkg_install ansible
    elif is_ubuntu; then
        if ! has_cmd ansible; then
            sudo apt-get install -y software-properties-common
            sudo add-apt-repository --yes --update ppa:ansible/ansible
            sudo apt-get install -y ansible
        fi
    fi
}

configure() {
    :
}

update() {
    if is_arch; then
        pkg_update ansible
    elif is_ubuntu; then
        sudo apt-get install -y --only-upgrade ansible
    fi
}
