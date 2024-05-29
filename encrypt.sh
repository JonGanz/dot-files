#! /bin/sh

ansible-vault encrypt --vault-password-file vault.cred ./vars/secret-vars.yml

