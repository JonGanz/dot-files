#! /bin/sh

ansible-vault encrypt ./vars/secret-vars.yml
ansible-vault encrypt ./dotfiles/ssh/id_rsa

